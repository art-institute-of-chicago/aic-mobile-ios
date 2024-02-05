/*
Abstract:
Manager class that handles loading and manipulating the apps data sources
*/

import UIKit
import Alamofire

@objc protocol AppDataManagerDelegate: AnyObject {
	func downloadProgress(withPctCompleted: Float)
	@objc optional func didFinishLoadingData()
	func downloadFailure(withMessage: String)
}

class AppDataManager {
	static let sharedInstance = AppDataManager()

	weak var delegate: AppDataManagerDelegate?

	private (set) var app: AICAppDataModel! = nil
	private (set) var exhibitions: [AICExhibitionModel] = []
	private (set) var events: [AICEventModel] = []

	private let dataParser = AppDataParser()

	private var dataFilesRetrieved = 0
	var pctComplete: Float = 0.0

	private var appData: Data?
	private var numberMapFloorsLoaded: Int = 0
	var mapFloorURLs: [Int: URL] = [:] // local path to map floor pdf files

	private (set) var isLoaded = false
	private var loadFailure = false

	func load(forceAppDataDownload: Bool = false) {
		var downloadDataEvenIfCached: Bool = forceAppDataDownload

		// Save software version number
		if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {

			// Force AppData download if the last software version is older
			if downloadDataEvenIfCached == false {
				if let lastVersion = UserDefaults.standard.object(forKey: Common.UserDefaults.lastVersionNumberKey) as? String {
					if version.compare(lastVersion, options: .numeric) == .orderedDescending {
						downloadDataEvenIfCached = true
					}
				} else {
					downloadDataEvenIfCached = true
				}
			}

			UserDefaults.standard.set(version, forKey: Common.UserDefaults.lastVersionNumberKey)
		}

		if let url = Bundle.main.url(forResource: "Config", withExtension: "plist") {
			do {
				let data = try Data(contentsOf: url)
				guard let config = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
					return
				}

				if let testing = config["Testing"] as! [String: Any]? {

					if let printDataErrors = testing["printDataErrors"] {
						Common.Testing.printDataErrors = printDataErrors as! Bool
					}

				}

				if let dataConstants = config["DataConstants"] as! [String: Any]? {

					if let appDataJSON = dataConstants["appDataJSON"] {
						Common.Constants.appDataJSON = appDataJSON as! String
					}

					if let memberCardSOAPRequestURL = dataConstants["memberCardSOAPRequestURL"] as? String {
						Common.Constants.memberCardSOAPRequestURL = memberCardSOAPRequestURL
					}

					if let ignoreOverrideImageCrop = dataConstants["ignoreOverrideImageCrop"] {
						Common.Constants.ignoreOverrideImageCrop = ignoreOverrideImageCrop as! Bool
					}

				}

			} catch {
				debugPrint(error)
			}
		}

		loadFailure = false
		dataFilesRetrieved = 0
		pctComplete = 0.0
		appData = nil
		mapFloorURLs = [:]
		numberMapFloorsLoaded = 0
		lastModifiedStringsMatch(atURL: Common.Constants.appDataJSON,
                             userDefaultsLastModifiedKey: Common.UserDefaults.onDiskAppDataLastModifiedStringKey) { stringsMatch in
			if !stringsMatch || downloadDataEvenIfCached {
				//Try to download new app data
				//If there is an issue with the server or reachability
				//then fall back to the older local data, unless no local data
				//exists, then fail.
				self.downloadAppData()
			} else {
				//If the appData json that is on disk is the same as
				//the server provided json then just use our local data
				self.appData = self.loadFromDisk(fileName: Common.Constants.localAppDataFilename)

				//We have good cached app data, continue on
				self.loadAppData()
			}

		}
	}

	// MARK: Download App Data

	private func downloadAppData() {
		// App Data
		AF.request(Common.Constants.appDataJSON)
			.validate()
			.responseData { response in
				if self.loadFailure == false {
					switch response.result {
					case .success(let value):

						self.appData = value

						//Save the data to disk in case the server is down at some point in the future [JB]
						let headersDictionary = response.response?.allHeaderFields
						if let lastModifiedString = headersDictionary?["Last-Modified"] as? String {
							self.writeDataToDisk(data: value,
												 lastModifiedString: lastModifiedString,
												 lastModifiedUserDefaultsKey: Common.UserDefaults.onDiskAppDataLastModifiedStringKey,
												 fileName: Common.Constants.localAppDataFilename)
						}
					case .failure:
						// Load cached app data from disk
						self.appData = self.loadFromDisk(fileName: Common.Constants.localAppDataFilename)
					}

					self.loadAppData()
				}
		}
	}

	private func loadAppData() {
		if let appData = self.appData {
			// We have good app data, continue on
			updateDownloadProgress()
			downloadMapFloorsPdfs(appData: appData)

			fetchMemberCard()
		} else {
			// If we couldn't load any app data from url or disk let the user know
			notifyLoadFailure(withMessage: "Failed to load application data.")
		}
	}

	// MARK: Download Map Floors Pdfs

	private func downloadMapFloorsPdfs(appData: Data) {
		// URLs to download Floor Pdfs
		let floorsURLs = dataParser.parseMapFloorsURLs(fromAppData: appData)

		guard floorsURLs.count == Common.Map.totalFloors else {
			// If we couldn't parse all floor pdfs urls let the user know
			self.notifyLoadFailure(withMessage: "Failed to load application data.")
			return
		}

		for floorNumber in 0..<Common.Map.totalFloors {
			let floorSourceURL = floorsURLs[floorNumber]

			// Create destination URL for this floor
			let cachesFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first!
			let floorFolderURL = cachesFolderURL.appendingPathComponent("aicFloor\(floorNumber)/")
			let floorDestinationURL = floorFolderURL.appendingPathComponent(floorSourceURL.lastPathComponent)

			// If a pdf file already exists with the same name, load from caches folder
			if FileManager.default.fileExists(atPath: floorDestinationURL.path) {
				self.numberMapFloorsLoaded += 1
				self.addMapFloorURL(floorDestinationURL, floorNumber: floorNumber)
			}
				// If the file is new, download pdf from CMS
			else {
				// Clean up floder of previous pdf files for this floor
				var isDirectory: ObjCBool = true
				if FileManager.default.fileExists(atPath: floorFolderURL.path, isDirectory: &isDirectory) {
					do {
						try FileManager.default.removeItem(atPath: floorFolderURL.path)
					} catch {
					}
				}

				// Download new pdf file
				let destination: DownloadRequest.Destination = { _, _ in (floorDestinationURL, [.removePreviousFile, .createIntermediateDirectories]) }

				AF.download(floorSourceURL, to: destination).response { response in
					self.numberMapFloorsLoaded += 1

					if let floorURL = response.fileURL {
						self.addMapFloorURL(floorURL, floorNumber: floorNumber)
					} else {
						// If we could not load this floor pdf let the user know
						self.notifyLoadFailure(withMessage: "Failed to load application data.")
						return
					}
				}
			}
		}
	}

	private func addMapFloorURL(_ url: URL, floorNumber: Int) {
		self.mapFloorURLs[floorNumber] = url

		// If we loaded all floors and we succesfully downloaded all of them
		if self.numberMapFloorsLoaded == Common.Map.totalFloors {
			if self.mapFloorURLs.count == Common.Map.totalFloors, let appData = self.appData {

				self.app = self.dataParser.parse(appData: appData)
				self.updateDownloadProgress()
				self.downloadExhibitions()
			} else {
				// If we couldn't load some floor pdfs let the user know
				self.notifyLoadFailure(withMessage: "Failed to load application data.")
				return
			}
		}
	}

	// MARK: Download Exhibitions

	private func downloadExhibitions() {
		var url: String = app.dataSettings[.dataApiUrl]! + app.dataSettings[.exhibitionsEndpoint]!
		if url.range(of: "/search") == nil {
			url.append("/search")
		}
		url.append("?limit=99")
		let urlRequest = URLRequest(url: URL(string: url)!)
		let urlString = urlRequest.url?.absoluteString
		let parameters: [String: Any] = [
			"fields": [
				"id",
				"title",
				"short_description",
				"image_url",
				"gallery_id",
				"web_url",
				"aic_start_at",
				"aic_end_at"
			],
			"sort": ["aic_start_at", "aic_end_at"],
			"query": [
				"bool": [
					"must": [
						[
							"range": [
								"aic_start_at": ["lte": "now"]
							]
						],
						[
							"range": [
								"aic_end_at": ["gte": "now"]
							]
						]
					],
					"must_not": [
						[
							"term": [
								"status": "Closed"
							]
						]
					]
				]
			]
		]

		AF.request(urlString!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					self.exhibitions = self.dataParser.parse(exhibitionsData: value)

				case .failure(let error):
					debugPrint(error)
				}

				self.updateDownloadProgress()
				self.downloadEvents()
		}
	}

	// MARK: Download Events

	func downloadEvents() {
		var url: String = app.dataSettings[.dataApiUrl]! + app.dataSettings[.eventsEndpoint]!
		if url.range(of: "/search") == nil {
			url.append("/search")
		}
		url.append("?limit=100")
		let urlRequest = URLRequest(url: URL(string: url)!)
		let urlString = urlRequest.url?.absoluteString
		let parameters: [String: Any] = [
			"fields": [
				"id",
				"title",
				"description",
				"short_description",
				"image_url",
				"location",
				"start_at",
				"end_at",
				"button_text",
				"button_url",
				"is_private"
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

		AF.request(urlString!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					self.events = self.dataParser.parse(eventsData: value)
				case .failure(let error):
					debugPrint(error)
				}
				self.updateDownloadProgress()
		}
	}

	// MARK: Fetch Member Card if Needed

	private func fetchMemberCard() {
		if let member = MemberDataManager.sharedInstance.getSavedMember() {
			MemberDataManager.sharedInstance.delegate = self
			MemberDataManager.sharedInstance.validateMember(memberID: member.memberID, zipCode: member.memberZip)
		} else {
			updateDownloadProgress()
		}
	}

	// MARK: Update Download State

	private func updateDownloadProgress() {
		DispatchQueue.main.async {
			self.dataFilesRetrieved = self.dataFilesRetrieved + 1
			self.pctComplete = Float(self.dataFilesRetrieved) / Float(Common.Constants.totalDataFeeds)
			self.delegate?.downloadProgress(withPctCompleted: self.pctComplete)

			if self.dataFilesRetrieved == Common.Constants.totalDataFeeds {
				// We're finished
				self.delegate?.didFinishLoadingData?()
			}
		}
	}

	private func notifyLoadFailure(withMessage message: String) {
		if self.loadFailure == false {
			delegate?.downloadFailure(withMessage: message)
			self.loadFailure = true
		}
	}

	// MARK: Data Getters

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

	private func lastModifiedStringsMatch(atURL url: URLConvertible, userDefaultsLastModifiedKey key: String, completion: @escaping (Bool) -> Void) {
		//Make a request to check the appData Last-Modified header
		AF.request(url, method: .head, parameters: Parameters(), encoding: URLEncoding.default, headers: HTTPHeaders())
			.validate()
			.responseData { (response) in
				// If we can't read the headers, something is wrong, try downloading and failover from there
				guard let headerDictionary = response.response?.allHeaderFields as? [String: Any] else {
					completion(false)
					return
				}

				guard let lastModifiedString = headerDictionary["Last-Modified"] as? String else {
					completion(false)
					return
				}

				guard let localLastModifiedString = UserDefaults.standard.object(forKey: key) as? String else {
					completion(false)
					return
				}

				completion(localLastModifiedString == lastModifiedString)
		}
	}

	private func writeDataToDisk(data: Data, fileName: String) {
		guard let fileURL = self.localFileURL(forFileName: fileName) else { return }
		do {
			try data.write(to: fileURL, options: .atomic)
		} catch let writeError {
			debugPrint("Error writing data : \(writeError)")
		}
	}

	private func writeDataToDisk(data: Data, lastModifiedString: String, lastModifiedUserDefaultsKey: String, fileName: String) {
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

// MARK: MemberDataManagerDelegate Adoption
extension AppDataManager: MemberDataManagerDelegate {
	func memberCardDidLoadForMember(memberCard: AICMemberCardModel) {
		updateDownloadProgress()
	}

	func memberCardDataLoadingFailed() {
		updateDownloadProgress()
	}
}
