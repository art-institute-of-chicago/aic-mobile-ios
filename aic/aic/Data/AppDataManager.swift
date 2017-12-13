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
        // Replace Common.swift values w/ values from Config.plist
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
					
					if let dataHubURL = DataConstants["dataHubURL"] {
						Common.DataConstants.dataHubURL = dataHubURL as! String
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
                self.downloadNewsFeeds()
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
					self.downloadNewsFeeds()
                }
        }
    }
    
    private func downloadNewsFeeds() {
        let newsFeedString = Common.DataConstants.NewsFeed.Featured
        lastModifiedStringsMatch(atURL: newsFeedString as URLConvertible, userDefaultsLastModifiedKey: Common.UserDefaults.onDiskNewsFeedLastModifiedString) { (stringsMatch) in
            if !stringsMatch {
                self.parseNews(fromFeed: Common.DataConstants.NewsFeed.Featured)
            }else{
                guard let cachedNewsFeed = self.loadFromDisk(fileName: Common.DataConstants.localNewsFeedFilename) else {
                    self.notifyLoadFailure(withMessage: "Failed to load news data.")
                    return
                }
                let newsItems = self.dataParser.parse(newsItemsData: cachedNewsFeed)
                self.exhibitions = newsItems
				
                self.updateDownloadProgress()
				self.downloadEvents()
            }
        }
    }
    
    private func parseNews(fromFeed feed:String) {
        
        let request = URLRequest(url: URL(string: feed)!) as URLRequestConvertible
        
        Alamofire.request(request)
            .validate()
            .responseData { response in
                if self.loadFailure == false {
                    switch response.result {
                    case .success(let value):
                        let newsItems = self.dataParser.parse(newsItemsData: value)
                        self.writeDataToDisk(data: value,
                                             fileName: Common.DataConstants.localNewsFeedFilename)
                        
						self.exhibitions = newsItems
                        
                    case .failure(let error):
                        guard let cachedNewsFeed = self.loadFromDisk(fileName: Common.DataConstants.localNewsFeedFilename) else {
                            // If there was an issue loading the news feed let the user know
                            self.notifyLoadFailure(withMessage: "Failed to load news data.")
                            print(error)
                            return
                        }
                        //We have a good cache of the news feed, continue on
                        let newsItems = self.dataParser.parse(newsItemsData: cachedNewsFeed)
                    
						self.exhibitions = newsItems
                    
                    }
                    
                    self.updateDownloadProgress()
					self.downloadEvents()
                }
        }
    }
	
	func downloadEvents() {
		let urlRequest = URLRequest(url: URL(string: Common.DataConstants.dataHubURL + "events/search?limit=99")!)
		let urlString = urlRequest.url?.absoluteString
		let parameters: [String: Any] = [
			"_source": true,
			"sort": ["start_at", "end_at"],
			"query": [
				"bool": [
					"must": [
						[
							"range": [
								"start_at": ["lte": "now+7d"]
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
    
    func getObject(forAudioGuideID id:Int) -> AICObjectModel? {
        let objectsWithAudioIDs = app.objects.filter({ $0.audioGuideIDs != nil })
        
        guard objectsWithAudioIDs.count > 0 else {
            return nil
        }
        
        return objectsWithAudioIDs.filter({ $0.audioGuideIDs!.contains(id) }).first
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
	
	func getEventsForEarliestDay() -> [AICEventModel] {
		// set earliest day to 1 year in the future
		var components = DateComponents()
		components.setValue(1, for: .year)
		let now: Date = Date()
		var earliestDate = Calendar.current.date(byAdding: components, to: now)!
		
		// find earliest day
		for event in self.events {
			if event.startDate < earliestDate {
				earliestDate = event.startDate
			}
		}
		
		return events.filter({ Calendar.current.compare($0.startDate, to: earliestDate, toGranularity: .day) == .orderedSame })
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
