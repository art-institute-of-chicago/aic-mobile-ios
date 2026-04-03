/*
Abstract:
Manager class that handles loading and manipulating the apps data sources
*/

import Alamofire
import Demark
import UIKit

@objc protocol AppDataManagerDelegate: AnyObject {
	func downloadProgress(withPctCompleted: Float)
	func downloadFailure(withMessage: String)
    @objc optional func didFinishLoadingData()
}

final class AppDataManager {
	static let sharedInstance = AppDataManager()

	weak var delegate: AppDataManagerDelegate?
    private(set) var app = AICAppDataModel(generalInfo: .init(translations: [:]), map: .init(floors: []))
	private(set) var exhibitions = [AICExhibitionModel]()
	private(set) var events = [AICEventModel]()
    private(set) var mapFloorURLs = [Int: URL]() // local path to map floor pdf files
    private(set) var isLoaded = false

	private var appData: Data?
	private var loadFailure = false
    private let dataParser: AppDataParser
    private let configuration: ConfigurationResources
    private let markdownOptions = DemarkOptions(engine: .htmlToMd, ignoreTags: ["span", "br"])

    private init() {
        dataParser = AppDataParser(
            crashlyticsManager: CrashlyticsManager(
                service: FirebaseCrashlyticsService(),
                properties: [
                    AnalyticsProperty.make(by: .appLanguage),
                    AnalyticsProperty.make(by: .deviceLanguage),
                    AnalyticsProperty.make(by: .membership)
                ]
            )
        )

        configuration = ConfigurationResources(
            plistFile: PlistFile(
                name: "Config"
            )
        )
    }

	func load(forceAppDataDownload: Bool = false) {
        setupCommonConfigurations()

        Task {
            // Determine if the appData response has been updated
            let appDataIsCurrent = try! await lastModifiedStringsMatch()
            
            // Download appData (CMS bundle)
            if appDataIsCurrent == false || forceAppDataDownload {
                await self.downloadAppData()
            }
            
            // Download PDFs
            // TODO: Pass in URLs from appData
            try! await self.downloadThePDFs(urls: [])
            
            // Parse CMS data. This needs to happen after floor PDFs have been downloaded/verified, and before Events & Exhibitions are fetched from the API.
            if let appData {
                print("PARSE START")
                self.app = self.dataParser.parse(appData: appData)
                print("PARSE END")
            }
            
            // Get Events from API
            await self.downloadEvents()
            
            // Get Exhibitions from API
            await self.downloadExhibitions()

            // Get Member Card Info
            fetchMemberCard()
            
            // Continue on to Home screen
            // This is not implemented anywhere :(
            //                self.delegate?.didFinishLoadingData?()
            await MainActor.run {
                self.delegate?.downloadProgress(withPctCompleted: 1.0)
            }
        }
    }

    private func setupCommonConfigurations() {
        Common.Testing.printDataErrors = configuration.enableErrorConsoleOutput()
        Common.Constants.ignoreOverrideImageCrop = configuration.enableIgnoreOverrideImageCrop()

        if let appDataURL = configuration.appDataURL() {
            Common.Constants.appDataJSON = appDataURL
        }

        if let memberCardSOAPRequestURL = configuration.memberCardSOAPRequestURL() {
            Common.Constants.memberCardSOAPRequestURL = memberCardSOAPRequestURL
        }
    }

    
	// MARK: - Downloading data for app startup
    private func downloadAppData() async {
        do {
            let (data, response) = try await URLSession.shared.data(from: URL(string: Common.Constants.appDataJSON)!)
            
            self.appData = data
            
            //Save the data to disk in case the server is down at some point in the future [JB]
            let headersDictionary = (response as? HTTPURLResponse)?.allHeaderFields
            if let lastModifiedString = headersDictionary?["Last-Modified"] as? String {
                self.writeDataToDisk(
                    data: data,
                    lastModifiedString: lastModifiedString,
                    lastModifiedUserDefaultsKey: Common.UserDefaults.onDiskAppDataLastModifiedStringKey,
                    fileName: Common.Constants.localAppDataFilename
                )
            }
        } catch {
            // Load cached app data from disk
            self.appData = self.loadFromDisk(fileName: Common.Constants.localAppDataFilename)
        }
	}

    private func downloadThePDFs(urls: [URL]) async throws {
        // TEST: Override to help test the new CMS /appData-v3 endpoint
        let floorURLs = [
            URL(string: "http://aic-mobile-tours.artic.edu/sites/default/files/floor-maps/20180323_map_floor0_0.pdf")!,
            URL(string: "http://aic-mobile-tours.artic.edu/sites/default/files/floor-maps/G3_App_Map_Adjustments_20251216%20%281%29.pdf")!,
            URL(string: "http://aic-mobile-tours.artic.edu/sites/default/files/floor-maps/G1_Caillebotte_Regenstein%20Map_AIC%20App_XD_20250608_0.pdf")!,
            URL(string: "http://aic-mobile-tours.artic.edu/sites/default/files/floor-maps/20180323_map_floor3.pdf")!
        ]
        
        await withThrowingTaskGroup(of: Void.self) { group in
            // Add a task for each URL
            for (index, url) in floorURLs.enumerated() {
                // Skip download if a file already exists at the location.
                // TODO: How can we tell if the PDF is out of date?
                let fileURL = URL.applicationSupportDirectory.appending(path: "aicFloor\(index)").appending(path: url.lastPathComponent)
                guard FileManager.default.fileExists(atPath: fileURL.relativePath) == false else {
                    mapFloorURLs[index] = fileURL
                    continue
                }
                
                group.addTask {
                    try await self.fetchPDF(from: url, floorNumber: index)
                }
            }
        }
    }

    private func fetchPDF(from url: URL, floorNumber: Int) async throws {
        let folderURL = URL.applicationSupportDirectory
        let floorFolderURL = folderURL.appendingPathComponent("aicFloor\(floorNumber)/")
        let floorDestinationURL = floorFolderURL.appendingPathComponent(url.lastPathComponent)
        
        try! FileManager.default.createDirectory(at: floorFolderURL, withIntermediateDirectories: true)
        
        do {
            let (fileURL, _) = try await URLSession.shared.download(from: url)
            
            try await MainActor.run {
                _ = try FileManager.default.replaceItemAt(floorDestinationURL, withItemAt: fileURL)
                print("PDF moved to \(floorDestinationURL)")
                mapFloorURLs[floorNumber] = floorDestinationURL
            }
        } catch {
            print("Error downloading PDF files: \(error)")
            self.notifyLoadFailure(withMessage: "Failed to load application data.")
        }
    }

	private func downloadExhibitions() async {
		var url: String = app.dataSettings[.dataApiUrl]! + app.dataSettings[.exhibitionsEndpoint]!
        
		if url.range(of: "/search") == nil {
			url.append("/search")
		}
		url.append("?limit=99")
		let parameters: [String: Any] = [
			"fields": [
				"id",
				"title",
				"short_description",
				"image_url",
				"gallery_id",
				"web_url",
				"aic_start_at",
				"aic_end_at",
                "position"
			],
			"query": [
				"bool": [
					"must": [
						[
							"range": [
								"aic_start_at": ["lte": "now"]
							]
						],
						[
							"term": [
								"is_featured": true
							]
						]
					]
				]
			]
		]
        
        var myRequest = try! URLRequest(url: url, method: .post)
        myRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        myRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        let (data, _) = try! await URLSession.shared.data(for: myRequest)

        // TODO: Switch to Codable
        self.exhibitions = self.dataParser.parse(exhibitionsData: data).sorted(by: { $0.position < $1.position })
	}

	func downloadEvents() async {
		var url: String = app.dataSettings[.dataApiUrl]! + app.dataSettings[.eventsEndpoint]!
        
		if url.range(of: "/search") == nil {
			url.append("/search")
		}
		url.append("?limit=100")
		let parameters: [String: Any] = [
			"fields": [
				"id",
				"title",
                "title_display",
				"description",
				"short_description",
				"image_url",
				"location",
				"start_at",
				"end_at",
				"button_text",
                "button_caption",
                "is_ticketed",
				"button_url",
				"is_private",
                "is_sales_button_hidden",
                "on_sale_at",
                "off_sale_at"
			],
			"sort": ["start_at", "end_at"],
			"query": [
				"bool": [
					"must": [
						[
							"range": [
								"start_at": ["lte": "now+2w"]
							]
						],
						[
							"range": [
								"end_at": ["gte": "now"]
							]
						],
						[
							"term": [
								"is_private": false
							]
						]
					]
				]
			]
		]
        
        
        var myRequest = try! URLRequest(url: url, method: .post)
        myRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        myRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        let (data, _) = try! await URLSession.shared.data(for: myRequest)

        // TODO: Switch to Codable
        self.events = self.dataParser.parse(eventsData: data)
                                    }

	private func fetchMemberCard() {
		if let member = MemberDataManager.sharedInstance.getSavedMember() {
			MemberDataManager.sharedInstance.validateMember(memberID: member.memberID, zipCode: member.memberZip)
		}
	}

	private func notifyLoadFailure(withMessage message: String) {
		if self.loadFailure == false {
			delegate?.downloadFailure(withMessage: message)
			self.loadFailure = true
		}
	}

	// MARK: - Data Getters
	func getObjects(forFloor floor: Int) -> [AICObjectModel] {
		return app.objects.filter({ $0.location.floor == floor })
	}

	func getObject(forSelectorNumber number: Int) -> AICObjectModel? {
		return app.objects.filter({ $0.audioCommentaries.contains(where: { (audioCommentary) -> Bool in
			if let selectorNumber = audioCommentary.selectorNumber {
				return selectorNumber == number
			}
			return false
		}) }).first
	}

	func getTour(forSelectorNumber number: Int) -> AICTourModel? {
		return app.tours.filter({ $0.audioCommentary.selectorNumber == number }).first
	}

	func getAudioFile(forObject object: AICObjectModel, selectorNumber: Int?) -> AICAudioFileModel {
		// If a selectorNumber is specified, check that the object has it in its list
		if let number = selectorNumber {
			let audioCommentariesWithNumber = object.audioCommentaries.filter({ $0.selectorNumber == number  })
			if audioCommentariesWithNumber.count > 0 {
				return audioCommentariesWithNumber.first!.audioFile
			}
		}
		// Otherwise return first audio file
		return object.audioCommentaries.first!.audioFile
	}

	func getObject(forID id: Int) -> AICObjectModel? {
		return app.objects.filter({ $0.nid == id }).first
	}

	func getObject(forObjectID id: Int) -> AICObjectModel? {
		return app.objects.filter({ $0.objectId == id }).first
	}

	func getTour(forID id: Int) -> AICTourModel? {
		return app.tours.filter({ $0.nid == id }).first
	}

	func getRestaurant(forID id: Int) -> AICRestaurantModel? {
		return app.restaurants.filter({ $0.nid == id }).first
	}

	func getEventsForEarliestDay() -> [AICEventModel] {
		var dayEvents: [AICEventModel] = []

		// set earliest day to 1 year in the future
		var components = DateComponents()
		components.setValue(1, for: .year)
		let now: Date = Date()
		var earliestDate = Calendar.current.date(byAdding: components, to: now)!

		// find earliest day
		for event in self.events {
			if event.startDate < earliestDate && event.startDate > now {
				earliestDate = event.startDate
			}
		}

		let eventsForEarliestDate = events.filter({ Calendar.current.compare($0.startDate, to: earliestDate, toGranularity: .day) == .orderedSame })

		for event in eventsForEarliestDate {
			let now = Date()
			if event.startDate > now {
				dayEvents.append(event)
			}
			if dayEvents.count == 6 {
				break
			}
		}

		if dayEvents.isEmpty {
			if let lastEventOfEarliestDay = eventsForEarliestDate.last {
				dayEvents.append(lastEventOfEarliestDay)
			}
		}

		return dayEvents
	}

	func getToursForHome() -> [AICTourModel] {
		var result: [AICTourModel] = []
		let toursOrdered = self.app.tours.sorted(by: { (A, B) -> Bool in
			return A.order < B.order
		})
		for tour in toursOrdered {
			result.append(tour)
			if result.count == Common.Home.maxNumberOfTours {
				break
			}
		}
		return result
	}

	func getExhibitionsForHome() -> [AICExhibitionModel] {
		var result: [AICExhibitionModel] = []
		for exhibition in self.exhibitions {
			result.append(exhibition)
			if result.count == Common.Home.maxNumberOfExhibitions {
				break
			}
		}
		return result
	}

	func getEventsForHome() -> [AICEventModel] {
		var eventItems: [AICEventModel] = []
		let now: Date = Date()
		for event in self.events {
			if event.startDate > now {
				eventItems.append(event)
			}
			if eventItems.count == Common.Home.maxNumberOfEvents {
				break
			}
		}
		return eventItems
	}

	func shouldUseCategoriesForTours() -> Bool {
		var result: Bool = true
		for tour in self.app.tours {
			if tour.category == nil {
				result = false
			}
		}
		return result
	}

	func getToursForSeeAll() -> [AICTourModel] {
		return self.app.tours.sorted(by: { (A, B) -> Bool in
			return A.order < B.order
		})
	}

	func getToursByCategoryForSeeAll() -> [AICTourCategoryModel: [AICTourModel]] {
		var result = [AICTourCategoryModel: [AICTourModel]]()
		for category in self.app.tourCategories {
			var tours: [AICTourModel] = []
			for tour in self.app.tours {
				if let tourCategory = tour.category {
					if category.id == tourCategory.id {
						tours.append(tour)
					}
				}
			}
			if tours.count > 0 {
				result[category] = tours.sorted(by: { (A, B) -> Bool in
					return A.order < B.order
				})
			}
		}
		return result
	}

	func getExhibitionsForSeeAll() -> [AICExhibitionModel] {
		return self.exhibitions
	}

	func getCroppedImageForEvent(image: UIImage, viewSize: CGSize) -> UIImage {
		let imageSize = image.size
		let imageAspect = imageSize.width / imageSize.height
		let viewAspect = viewSize.width / viewSize.height

		if imageAspect < viewAspect {
			let cropRect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.width * (viewSize.height / viewSize.width))
			let croppedImage = UIImage(cgImage: (image.cgImage!.cropping(to: cropRect))!)

			return croppedImage
		}
		return image
	}

	func getCroppedImage(image: UIImage, viewSize: CGSize, cropRect: CGRect) -> UIImage {
		// create image crop from cropRect which is in percentages based on the original image size
		var imageCropRect = CGRect(x: floor(cropRect.origin.x * image.size.width), y: floor(cropRect.origin.y * image.size.height), width: floor(cropRect.size.width * image.size.width), height: floor(cropRect.size.height * image.size.height))
		let imageCropAspect = imageCropRect.width / imageCropRect.height
		let viewAspect = viewSize.width / viewSize.height
		let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

		// if image is more landscape than the view frame, compensate for the height
		if imageCropAspect > viewAspect {
			let finalHeight = imageCropRect.width * (1.0 / viewAspect)
			var finalOriginY = imageCropRect.origin.y
			if imageCropRect.origin.y + finalHeight > image.size.height {
				finalOriginY = image.size.height - finalHeight
			}
			imageCropRect.origin = CGPoint(x: imageCropRect.origin.x, y: finalOriginY)
			imageCropRect.size = CGSize(width: imageCropRect.width, height: finalHeight)
		}

		if imageRect.contains(imageCropRect) {
			if let cgImage = image.cgImage!.cropping(to: imageCropRect) {
				return UIImage(cgImage: cgImage)
			}
		}
		return image
	}

	// Find the tours this object is on, and filter out a tour if sepecified
	func getRelatedTours(forObject object: AICObjectModel, excludingTour: AICTourModel? = nil) -> [AICTourModel] {
		var relatedTours: [AICTourModel] = []
		for tour in app.tours {
			// Skip excluding tour
			if excludingTour != nil && tour.nid == excludingTour!.nid {
				continue
			}

			// Check the tours stops for the object, add if if found
			let stopForObject = tour.stops.filter({ $0.object.nid == object.nid}).first
			if stopForObject != nil {
				relatedTours.append(tour)
			}
		}

		return relatedTours.sorted(by: { (A, B) -> Bool in
			return A.order < B.order
		})
	}

	func getGallery(with galleryId: Int) -> AICGalleryModel? {
		return app.galleries
			.filter { $0.galleryId == galleryId }
			.first
	}

	func getGalleries(forFloorNumber floorNumber: Int) -> [AICGalleryModel] {
		return app.galleries.filter({ $0.location.floor == floorNumber })
	}

	func getMessagesToDisplayOnLaunch() -> [AICMessageModel] {
		let seenMessageNids =
			Set(UserDefaults.standard.stringArray(forKey: Common.UserDefaults.messagesViewedNidsUserDefaultsKey) ?? [])

		return app.messages.filter { (message) in
			switch message.messageType {
			case .launch(isPersistent: let isPersistent):
				guard !isPersistent else { return true }
				guard let nid = message.nid else { return false }
				return !seenMessageNids.contains(nid)
			case .memberExpiration(isPersistent: let isPersistent, threshold: let threshold):
				guard let expirationDate = MemberDataManager.sharedInstance.currentMemberCard?.expirationDate,
					expirationDate.timeIntervalSinceNow < TimeInterval(threshold)
					else { return false }
				guard !isPersistent else { return true }
				guard let nid = message.nid else { return false }
				return !seenMessageNids.contains(nid)
			default:
				return false
			}
		}
	}

	func getTourExitMessages(for nid: String) -> [AICMessageModel] {
		let seenMessageNids =
			Set(UserDefaults.standard.stringArray(forKey: Common.UserDefaults.messagesViewedNidsUserDefaultsKey) ?? [])

		return app.messages.filter { (message) in
			switch message.messageType {
			case .tourExit(isPersistent: let isPersistent, tourNid: let tourNid):
				guard tourNid == nid, let messageNid = message.nid else { return false }
				guard !isPersistent else { return true }
				return !seenMessageNids.contains(messageNid)
			default:
				return false
			}
		}
	}

	func markMessagesAsSeen(messages: [AICMessageModel]) {
		var seenMessageNids =
			Set(UserDefaults.standard.stringArray(forKey: Common.UserDefaults.messagesViewedNidsUserDefaultsKey) ?? [])
		seenMessageNids = seenMessageNids.union(messages.compactMap { $0.nid })
		UserDefaults.standard.set(Array(seenMessageNids), forKey: Common.UserDefaults.messagesViewedNidsUserDefaultsKey)
	}

	// MARK: Cached App Data Methods

    private func lastModifiedStringsMatch() async throws -> Bool {
        let url = Common.Constants.appDataJSON
        let key = Common.UserDefaults.onDiskAppDataLastModifiedStringKey
        
        //Make a request to check the appData Last-Modified header
        let request = try URLRequest(url: url, method: .head)
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // If we can't read the headers, something is wrong, try downloading and failover from there
        guard let headerDictionary = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any] else {
            return false
        }

        guard let lastModifiedString = headerDictionary["Last-Modified"] as? String else {
            return false
        }

        guard let localLastModifiedString = UserDefaults.standard.object(forKey: key) as? String else {
            return false
        }

        return localLastModifiedString == lastModifiedString
    }

	private func writeDataToDisk(data: Data, fileName: String) {
		guard let fileURL = self.localFileURL(forFileName: fileName) else { return }
		do {
			try data.write(to: fileURL, options: .atomic)
		} catch let writeError {
			debugPrint("Error writing data : \(writeError)")
		}
	}

    private func writeDataToDisk(
        data: Data,
        lastModifiedString: String,
        lastModifiedUserDefaultsKey: String,
        fileName: String
    ) {
		writeDataToDisk(data: data, fileName: fileName)
		UserDefaults.standard.set(lastModifiedString, forKey: lastModifiedUserDefaultsKey)
	}

	private func loadFromDisk(fileName: String) -> Data? {
		guard let fileURL = self.localFileURL(forFileName: fileName) else { return nil }
		do {
			let cachedData = try Data(contentsOf: fileURL)
			return cachedData
		} catch let readError {
			debugPrint("Error loading data from disk : \(readError)")
			return nil
		}
	}

	private func localFileURL(forFileName fileName: String) -> URL? {
		guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
		return directory.appendingPathComponent(fileName)
	}
}
