/*
 Abstract:
 Manager class that handles loading and manipulating the apps data sources
 */

import UIKit
import Alamofire

@objc protocol AppDataManagerDelegate : class {
    func downloadProgress(withPctCompleted:Float)
    @objc optional func didFinishLoadingData()
    func downloadFailure(withMessage:String)
}

class AppDataManager {
    static let sharedInstance = AppDataManager()
    
    weak var delegate:AppDataManagerDelegate?
    
    private (set) var app: AICAppDataModel! = nil
	private (set) var exhibitions: [AICExhibitionModel] = []
	private (set) var events: [AICEventModel] = []
	
    private let dataParser = AppDataParser()
    
    private var dataFilesRetrieved = 0
    var pctComplete:Float = 0.0
    
    private (set) var isLoaded = false
    private var loadFailure = false
    
    func load() {
        
        // TODO: Refactor this
		// A lot of urls and strings not needed in v2.0
        if let url = Bundle.main.url(forResource:"Config", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                guard let config = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:Any] else {
                    return
                }
                
                if let Testing = config["Testing"] as! [String : Any]? {
                    
                    if let printDataErrors = Testing["printDataErrors"] {
                        Common.Testing.printDataErrors = printDataErrors as! Bool
                    }
                    
                }
                
                if let DataConstants = config["DataConstants"] as! [String : Any]? {
                    
                    if let feedFeaturedExhibitions = DataConstants["feedFeaturedExhibitions"] {
                        Common.DataConstants.NewsFeed.Featured = feedFeaturedExhibitions as! String
                    }
                    
                    if let appDataJSON = DataConstants["appDataJSON"] {
                        Common.DataConstants.appDataJSON = appDataJSON as! String
                    }
                    
                    if let appDataExternalPrefix = DataConstants["appDataExternalPrefix"] {
                        Common.DataConstants.appDataExternalPrefix = appDataExternalPrefix as! String
                    }
                    
                    if let appDataInternalPrefix = DataConstants["appDataInternalPrefix"] {
                        Common.DataConstants.appDataInternalPrefix = appDataInternalPrefix as! String
                    }
					
					if let appDataLocalPrefix = DataConstants["appDataLocalPrefix"] {
						Common.DataConstants.appDataLocalPrefix = appDataLocalPrefix as! String
					}
                    
                    if let memberCardSOAPRequestURL = DataConstants["memberCardSOAPRequestURL"] as? String {
                        Common.DataConstants.memberCardSOAPRequestURL = memberCardSOAPRequestURL
                    }
                    
                    if let ignoreOverrideImageCrop = DataConstants["ignoreOverrideImageCrop"] {
                        Common.DataConstants.ignoreOverrideImageCrop = ignoreOverrideImageCrop as! Bool
                    }
                    
                }

                
            } catch {
                print(error)
            }
        }
                
        loadFailure = false
        dataFilesRetrieved = 0
        pctComplete = 0.0
        lastModifiedStringsMatch(atURL: Common.DataConstants.appDataJSON, userDefaultsLastModifiedKey: Common.UserDefaults.onDiskAppDataLastModifiedString) { (stringsMatch) in
            if !stringsMatch {
                //Try tp download new app data
                //If there is an issue with the server or reachability
                //then fall back to the older local data, unless no local data
                //exists, then fail.
                self.downloadAppData()
            }else{
                //If the appData json that is on disk is the same as
                //the server provided json then just use our local data
                guard let cachedAppData = self.loadFromDisk(fileName: Common.DataConstants.localAppDataFilename) else {
                    //If we couldn't load any app data from disk let the user know
                    self.notifyLoadFailure(withMessage: "Failed to load application data.")
                    return
                }
                //We have good cached app data, continue on
                self.app = self.dataParser.parse(appData: cachedAppData)
                self.updateDownloadProgress()
                self.downloadExhibitions()
            }
            
        }
    }
    
    private func downloadAppData() {
        
        // App Data
        Alamofire.request(Common.DataConstants.appDataJSON)
            .validate()
            .responseData { response in
                if self.loadFailure == false {
                    switch response.result {
                    case .success(let value):
                        self.app = self.dataParser.parse(appData: value)
						
                        //Save the data to disk incase the server is down at some point in the future [JB]
                        let headersDictionary = response.response?.allHeaderFields
                        if let lastModifiedString = headersDictionary?["Last-Modified"] as? String {
                            self.writeDataToDisk(data: value,
                                                 lastModifiedString: lastModifiedString,
                                                 lastModifiedUserDefaultsKey: Common.UserDefaults.onDiskAppDataLastModifiedString,
                                                 fileName: Common.DataConstants.localAppDataFilename)
                        }
                    case .failure(let error):
                        //Attempt to fall back to cached data
                        guard let cachedAppData = self.loadFromDisk(fileName: Common.DataConstants.localAppDataFilename) else {
                            //If we couldn't load any app data from disk let the user know
                            self.notifyLoadFailure(withMessage: "Failed to load application data.")
                            print(error)
                            return
                        }
                        //We have good cached app data, continue on
                        self.app = self.dataParser.parse(appData: cachedAppData)
                    }
					self.updateDownloadProgress()
					self.downloadExhibitions()
                }
        }
    }
	
	private func downloadExhibitions() {
		let urlRequest = URLRequest(url: URL(string: app.dataSettings[.dataApiUrl]! + app.dataSettings[.exhibitionsEndpoint]! + "/search?limit=99")!)
		let urlString = urlRequest.url?.absoluteString
		let parameters: [String: Any] = [
			"fields": [
				"id",
				"title",
				"short_description",
				"legacy_image_mobile_url",
				"legacy_image_desktop_url",
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
		
		Alamofire.request(urlString!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					self.exhibitions = self.dataParser.parse(exhibitionsData: value)
					
				case .failure(let error):
					print(error)
				}
				
				self.updateDownloadProgress()
				self.downloadEvents()
		}
	}
	
	func downloadEvents() {
		let urlRequest = URLRequest(url: URL(string: app.dataSettings[.dataApiUrl]! + app.dataSettings[.eventsEndpoint]! + "/search?limit=500")!)
		let urlString = urlRequest.url?.absoluteString
		let parameters: [String: Any] = [
			"fields": [
				"id",
				"title",
				"description",
				"short_description",
				"image",
				"location",
				"start_at",
				"end_at",
				"button_text",
				"button_url"
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
						]
					]
				]
			]
		]
		
		Alamofire.request(urlString!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					self.events = self.dataParser.parse(eventsData: value)
				case .failure(let error):
					print(error)
				}
				self.updateDownloadProgress()
		}
	}
    
    private func updateDownloadProgress() {
        DispatchQueue.main.async {
            self.dataFilesRetrieved = self.dataFilesRetrieved + 1
            self.pctComplete = Float(self.dataFilesRetrieved) / Float(Common.DataConstants.totalDataFeeds)
            self.delegate?.downloadProgress(withPctCompleted: self.pctComplete)
            
            if self.dataFilesRetrieved == Common.DataConstants.totalDataFeeds {
                // We're finished
                self.delegate?.didFinishLoadingData?()
            }
        }
    }
    
    private func notifyLoadFailure(withMessage message:String) {
        if self.loadFailure == false {
            delegate?.downloadFailure(withMessage: message)
            self.loadFailure = true
        }
    }
    
    func getObjects(forFloor floor:Int) -> [AICObjectModel] {
        return app.objects.filter( { $0.location.floor == floor })
    }
    
    func getObject(forSelectorNumber number: Int) -> AICObjectModel? {
        return app.objects.filter({ $0.audioCommentaries.contains(where: { (audioCommentary) -> Bool in
			if let selectorNumber = audioCommentary.selectorNumber  {
				return selectorNumber == number
			}
			return false
		}) }).first
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
    
    func getObject(forID id:Int) -> AICObjectModel? {
        return app.objects.filter({ $0.nid == id }).first
    }
	
	func getObject(forObjectID id:Int) -> AICObjectModel? {
		return app.objects.filter({ $0.objectId == id }).first
	}
    
    func getTour(forID id:Int) -> AICTourModel? {
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
		var tourItems: [AICTourModel] = []
		for tour in self.app.tours {
			tourItems.append(tour)
			if tourItems.count == Common.Home.maxNumberOfTours {
				break
			}
		}
		return tourItems
	}
	
	func getExhibitionsForHome() -> [AICExhibitionModel] {
		var exhibitionItems: [AICExhibitionModel] = []
		for exhibition in self.exhibitions {
			exhibitionItems.append(exhibition)
			if exhibitionItems.count == Common.Home.maxNumberOfExhibitions {
				break
			}
		}
		return exhibitionItems
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
    func getRelatedTours(forObject object:AICObjectModel, excludingTour:AICTourModel? = nil) -> [AICTourModel] {
        var relatedTours:[AICTourModel] = []
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
        
        return relatedTours
    }
    
    func getGalleries(forFloorNumber floorNumber:Int) -> [AICGalleryModel] {
        return app.galleries.filter( { $0.location.floor == floorNumber })
    }
    
    
    //MARK: Cached App Data Methods
    
    private func lastModifiedStringsMatch(atURL url: URLConvertible, userDefaultsLastModifiedKey key: String, completion: @escaping (Bool) -> ()) {
        //Make a request to check the appData Last-Modified header
        Alamofire.request(url, method: .head, parameters: Parameters(), encoding: URLEncoding.default, headers: HTTPHeaders())
            .validate()
            .responseData { (response) in
                // If we can't read the headers, something is wrong, try downloading and failover from there
                guard let headerDictionary = response.response?.allHeaderFields as? [String : Any] else {
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
    
    private func writeDataToDisk(data: Data, fileName: String){
        guard let fileURL = self.localFileURL(forFileName: fileName) else { return }
        do {
            try data.write(to: fileURL, options: .atomic)
        }catch (let writeError){
            debugPrint("Error writing data : \(writeError)")
        }
    }
    
    private func writeDataToDisk(data: Data, lastModifiedString: String, lastModifiedUserDefaultsKey: String, fileName: String){
        writeDataToDisk(data: data, fileName: fileName)
        UserDefaults.standard.set(lastModifiedString, forKey: lastModifiedUserDefaultsKey)
    }
    
    private func loadFromDisk(fileName: String) -> Data?{
        guard let fileURL = self.localFileURL(forFileName: fileName) else { return nil }
        do {
            let cachedData = try Data(contentsOf: fileURL)
            return cachedData
        }catch (let readError){
            debugPrint("Error loading data from disk : \(readError)")
            return nil
        }
    }
    
    private func localFileURL(forFileName fileName: String) -> URL?{
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return directory.appendingPathComponent(fileName)
    }
}
