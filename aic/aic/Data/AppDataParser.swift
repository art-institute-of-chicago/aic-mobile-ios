/*
 Abstract:
 Parses the main app data file
 */

import SwiftyJSON
import CoreLocation



class AppDataParser {
    enum ParseError: Error {
        case objectParseFailure
        case missingKey(key:String)
        case badURLString(string:String)
		case badFloatString(string:String)
        case badIntString(string:String)
        case badCLLocationString(string:String)
        case newsBadDateString(dateString:String)
        case audioFileNotFound(nid:Int)
        case objectNotFound(nid:Int)
        case galleryDisabled(galleryName:String)
        case galleryNotFound(galleryName:String)
        case tourStopsNotFound
        case jsonObjectNotFoundForKey(key:String)
        case noValidTourStops
		case searchAutocompleteFailure
    }
	
	private var galleries = [AICGalleryModel]()
	private var audioFiles = [AICAudioFileModel]()
	private var objects = [AICObjectModel]()
    
    // MARK: Exhibitions
    func parse(newsItemsData itemsData:Data) -> [AICExhibitionModel] {
        let json = JSON(data: itemsData)
        
        var newsItems:[AICExhibitionModel] = []
        for newsItem in json {
            do {
                try handleParseError({
                    let newsItem = try self.parse(newsItemData: newsItem.1)
                    newsItems.append(newsItem)
                })
            }
            catch {
                if Common.Testing.printDataErrors {
                    print("could not parse AIC News Item Data:\n\(newsItem.1)\n")
                }
            }
        }
		
		// Order by recently opened
		newsItems = newsItems.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        return newsItems
    }
    
    private func parse(newsItemData itemData:JSON) throws -> AICExhibitionModel {
        let title = try getString(fromJSON: itemData, forKey: "title")
        var description = try getString(fromJSON: itemData, forKey: "body")
        
        // Remove any leading whitespace, currently a bug in JSON
        if description.count > 1 && description.first == " " {
			description = String(description[description.index(description.startIndex, offsetBy: 1)...])
        }
        
        let thumbnailURL = try getURL(fromJSON: itemData, forKey: "thumbnail")
        let imageURL = try getURL(fromJSON: itemData, forKey: "feature_image_mobile")
        let imageCropRect: CGRect? = try? getRect(fromJSON: itemData, forKey: "large_image_crop_rect")
        
        // Parse out first gallery listed for exhibition
        var location:CoordinateWithFloor? = nil
        
        let galleries = try getString(fromJSON: itemData, forKey: "exhibition_location")
        let firstGallery = galleries.components(separatedBy: ", ").first
        
        if let firstGalleryName = firstGallery {
            let gallery = try getGallery(forGalleryName: firstGalleryName)
            location = gallery.location
        } else {
            throw ParseError.galleryNotFound(galleryName: galleries)
        }
        
        // Get date exibition ends
        let dateString = try getString(fromJSON: itemData, forKey: "date")
		guard let startDateString = dateString.components(separatedBy: " to ").first else {
			throw ParseError.newsBadDateString(dateString: dateString)
		}
		guard let endDateString = dateString.components(separatedBy: " to ").last else {
            throw ParseError.newsBadDateString(dateString: dateString)
        }
        
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-d h:m:s"
		
		guard let startDate: Date = dateFormatter.date(from: startDateString) else {
			throw ParseError.newsBadDateString(dateString: dateString)
		}
		guard let endDate: Date = dateFormatter.date(from: endDateString) else {
			throw ParseError.newsBadDateString(dateString: dateString)
		}
        
        //Don't throw if the isFeatured flag isn't set, it is only set for new items
        let bannerString = try? getString(fromJSON: itemData, forKey: "tour_banner")

        // Return news item
        return AICExhibitionModel(title: title,
                                shortDescription: description,
                                longDescription: description,
                                imageUrl: imageURL,
                                imageCropRect: imageCropRect,
								thumbnailUrl: thumbnailURL,
								startDate: startDate,
								endDate: endDate,
                                location: location!,
                                bannerString: bannerString
        )
    }
	
	// MARK: Events
	
	func parse(eventsData data: Data) -> [AICEventModel] {
		var eventItems:[AICEventModel] = []
		
		let json = JSON(data: data)
		
		do {
			try handleParseError({ [unowned self] in
				
				let dataJson: JSON = json["data"]
				for eventJson: JSON in dataJson.arrayValue {
					let eventItem = try self.parse(eventJson: eventJson)
					eventItems.append(eventItem)
				}
			})
		}
		catch {
			if Common.Testing.printDataErrors {
				print("Could not parse AIC Event Items:\n\(json)\n")
			}
		}
		
		return eventItems
	}
	
	func parse(eventJson: JSON) throws -> AICEventModel {
		let title = try getString(fromJSON: eventJson, forKey: "title")
		let longDescription = try getString(fromJSON: eventJson, forKey: "description")
		let shortDescription = try getString(fromJSON: eventJson, forKey: "short_description")
		let imageURL = try getURL(fromJSON: eventJson, forKey: "image")
		
		// Get date exibition ends
		let startDateString = try getString(fromJSON: eventJson, forKey: "start_at")
		let endDateString = try getString(fromJSON: eventJson, forKey: "end_at")
		
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		
		// TODO: fix the timezone
		
		guard let startDate: Date = dateFormatter.date(from: startDateString) else {
			throw ParseError.newsBadDateString(dateString: startDateString)
		}
		guard let endDate: Date = dateFormatter.date(from: endDateString) else {
			throw ParseError.newsBadDateString(dateString: endDateString)
		}
		
		// Return news item
		return AICEventModel(title: title,
							 shortDescription: shortDescription,
							 longDescription: longDescription,
							 imageUrl: imageURL,
							 startDate: startDate,
							 endDate: endDate
		)
	}
    
    // MARK: App Data
    func parse(appData data:Data) -> AICAppDataModel {
        let appDataJson = JSON(data: data)
		
		let museumInfo: AICMuseumInfoModel	= parse(museumInfoJSON: appDataJson["general_info"])
		self.galleries	= parse(galleriesJSON: appDataJson["galleries"])
		self.audioFiles = parse(audioFilesJSON: appDataJson["audio_files"])
        self.objects 	= parse(objectsJSON: appDataJson["objects"])
		let tours: [AICTourModel]	 = parse(toursJSON: appDataJson["tours"])
		
		let appData = AICAppDataModel(museumInfo: museumInfo,
							   galleries: self.galleries,
							   objects: self.objects,
							   audioFiles: self.audioFiles,
							   tours: tours)
		
		return appData
    }
	
	// Museum Info
	func parse(museumInfoJSON: JSON) -> AICMuseumInfoModel {
		do {
			let nid         = try getInt(fromJSON: museumInfoJSON, forKey: "nid")
			let title       = try getString(fromJSON: museumInfoJSON, forKey: "title")
			let museumHours	= try getString(fromJSON: museumInfoJSON, forKey: "museum_hours")
			
			return AICMuseumInfoModel(nid: nid,
									  title: title,
									  museumHours: museumHours
			)
		}
		catch {
			print("Could not parse AIC Museum Info Data:\n\(museumInfoJSON)\n")
		}
		
		return AICMuseumInfoModel(nid: 0, title: Common.Info.museumInformationTitle, museumHours: Common.Info.museumInformationHours)
	}
    
    // Galleries
    private func parse(galleriesJSON: JSON) -> [AICGalleryModel] {
        print(galleriesJSON.dictionaryValue.count)
		var galleries = [AICGalleryModel]()
        for (_, galleryJSON):(String, JSON) in galleriesJSON.dictionaryValue {
            do {
                try handleParseError({ [unowned self] in
                    let gallery = try self.parse(galleryJSON: galleryJSON)
                    galleries.append(gallery)
                    })
            }
                
            catch {
                if Common.Testing.printDataErrors {
                    print("Could not parse AIC Gallery Data:\n\(galleryJSON)\n")
                }
            }
        }
		return galleries
    }
    
    func parse(galleryJSON: JSON?) throws -> AICGalleryModel {
        let nid         = try getInt(fromJSON: galleryJSON!, forKey: "nid")
        let title       = try getString(fromJSON: galleryJSON!, forKey: "title")
        
        var displayTitle = title.replacingOccurrences(of: "Gallery ", with: "")
        displayTitle = displayTitle.replacingOccurrences(of: "Galleries ", with: "")
        
        //Check for gallery disabled
        let isOpen:Bool = !(try getBool(fromJSON: galleryJSON!, forKey:"closed"))
        
        let location = try getCLLocation2d(fromJSON: galleryJSON!, forKey: "location")
        
        // Floor 0 comes through as LL, so parse that out
        let lowerLevel = try? getString(fromJSON: galleryJSON!, forKey: "floor")
        let floorNumber:Int! = lowerLevel == "LL" ? 0 : try getInt(fromJSON: galleryJSON!, forKey: "floor")
        
        let gallery = AICGalleryModel(id: nid,
                                      title: title,
                                      displayTitle: displayTitle,
                                      location: CoordinateWithFloor(coordinate: location, floor: floorNumber),
                                      isOpen: isOpen
        )
        
        return gallery
    }
    
    // Objects
    fileprivate func parse(objectsJSON: JSON) -> [AICObjectModel] {
		var objects = [AICObjectModel]()
        for (_,objectData):(String, JSON) in objectsJSON.dictionaryValue {
            do {
                try handleParseError({ [unowned self] in
                    let object = try self.parse(objectJSON: objectData)
                    objects.append(object)
				})
            }
                
            catch {
                if Common.Testing.printDataErrors {
                    print("Could not parse AIC Object Data:\n\(objectData)\n")
                }
            }
        }
		return objects
    }
    
    fileprivate func parse(objectJSON: JSON) throws -> AICObjectModel {
        let nid             = try getInt(fromJSON:objectJSON, forKey: "nid")
		let objectId        = try getInt(fromJSON:objectJSON, forKey: "object_id")
        let location        = try getCLLocation2d(fromJSON: objectJSON, forKey:"location")
        
        let galleryName     = try getString(fromJSON: objectJSON, forKey: "gallery_location")
        let floorNumber     = try getGallery(forGalleryName: galleryName).location.floor
        
        let title           = try getString(fromJSON: objectJSON, forKey: "title")
        
        // Optional Fields
        var tombstone:String?  = nil
        do {
            tombstone = try getString(fromJSON: objectJSON, forKey: "artist_culture_place_delim").replacingOccurrences(of: "|", with: "\r")
        } catch {}
        
        var credits:String? = nil
        do {
            credits = try getString(fromJSON: objectJSON, forKey: "credit_line")
        } catch {}
        
        var audioGuideID:Int? = nil
        do {
            audioGuideID = try getInt(fromJSON: objectJSON, forKey: "object_selector_number")
        } catch {}
        
        var audioGuideIDs = try? getIntArray(fromJSON: objectJSON, forArrayKey: "object_selector_numbers")
        
        //While migrating data move single audioGuideID ints into the array if the array is nil. This can be removed later. [JB]
        if audioGuideIDs == nil && audioGuideID != nil{
            audioGuideIDs = [audioGuideID!]
        }
        
        var imageCopyright:String? = nil
        do {
            imageCopyright = try getString(fromJSON: objectJSON, forKey: "copyright_notice")
        } catch {}
        
        // Get images
        var image: URL! = nil
        var thumbnail: URL! = nil
        var imageHasBeenOverridden = false
        
        do {
            // Try to load override images
            image           = try getURL(fromJSON: objectJSON, forKey: "image_url")
            thumbnail       = image
            imageHasBeenOverridden = true
        } catch {
            // Try loading from cms default images
            image           = try getURL(fromJSON: objectJSON, forKey: "large_image_full_path")
            thumbnail       = try getURL(fromJSON: objectJSON, forKey: "thumbnail_full_path")
        }
        
        // Get Image Crop Rects if they exist
        var thumbnailCropRect: CGRect? = try? getRect(fromJSON: objectJSON, forKey: "thumbnail_crop_rect")
        var imageCropRect: CGRect? = try? getRect(fromJSON: objectJSON, forKey: "large_image_crop_rect")
        
        if imageHasBeenOverridden || !Common.DataConstants.ignoreOverrideImageCrop {
            //Feature #886 - Ignore / Allow crops for overriden images
            thumbnailCropRect = nil
            imageCropRect = nil
        }
        
        // Ingest all audio IDs
        var audioFiles = [AICAudioFileModel]()
        let audioIDs  = try getIntArray(fromJSON: objectJSON, forArrayKey: "audio")
        for audioID in audioIDs {
            let audioFile = try getAudioFile(forNID:audioID)
            audioFiles.append(audioFile)
        }
        
        return AICObjectModel(nid: nid,
							  objectId: objectId,
                              thumbnailUrl: thumbnail,
                              thumbnailCropRect: thumbnailCropRect,
                              imageUrl: image,
                              imageCropRect: imageCropRect,
                              title: title,
                              audioFiles: audioFiles,
                              audioGuideIDs: audioGuideIDs,
                              tombstone: tombstone,
                              credits: credits,
                              imageCopyright: imageCopyright,
                              location: CoordinateWithFloor(coordinate: location, floor: floorNumber)
        )
    }
    
    // Audio Files
	fileprivate func parse(audioFilesJSON: JSON) -> [AICAudioFileModel] {
		var audioFiles = [AICAudioFileModel]()
		for (_,audioFileData):(String, JSON) in audioFilesJSON.dictionaryValue {
            do {
                try handleParseError({
                    let audioFile = try self.parse(audioFileJSON: audioFileData)
                    audioFiles.append(audioFile)
                })
            }
                
            catch {
                if Common.Testing.printDataErrors {
                    print("Could not parse Audio File Data:\n\(audioFileData)\n")
                }
            }
        }
		return audioFiles
    }
    
    fileprivate func parse(audioFileJSON: JSON) throws -> AICAudioFileModel {
        let nid         = try getInt(fromJSON: audioFileJSON, forKey: "nid")
        let title       = try getString(fromJSON: audioFileJSON, forKey: "title")
        let url         = try getURL(fromJSON: audioFileJSON, forKey: "audio_file_url")
        let transcript  = try getString(fromJSON: audioFileJSON, forKey: "audio_transcript")
        
        return AICAudioFileModel(nid:nid,
                                 title:title,
                                 url: url,
                                 transcript: transcript
        )
    }
    
    
    // Parse tours
	fileprivate func parse(toursJSON:JSON) -> [AICTourModel] {
		var tours = [AICTourModel]()
        print(toursJSON.arrayValue.count)
        for tourJSON in toursJSON.arrayValue {
            do {
                try handleParseError({
                    let tour = try self.parse(tourJSON: tourJSON)
                    tours.append(tour)
                })
            }
                
            catch {
                if Common.Testing.printDataErrors {
                    print("Could not parse Tour Data:\n\(tourJSON)\n")
                }
            }
        }
		return tours
    }
    
    fileprivate func parse(tourJSON: JSON) throws -> AICTourModel {
        let nid                 = try getInt(fromJSON: tourJSON, forKey: "nid")
        let title               = try getString(fromJSON: tourJSON, forKey: "title")
        let imageUrl            = try getURL(fromJSON: tourJSON, forKey: "image_url")
        let shortDescription        = try getString(fromJSON: tourJSON, forKey: "description")
        
        var longDescription     = try getString(fromJSON: tourJSON, forKey: "intro")
        longDescription = "\(shortDescription)\r\r\(longDescription)"
        
        let audioFileID         = try getInt(fromJSON: tourJSON, forKey: "tour_audio")
        let audioFile           = try getAudioFile(forNID:audioFileID)
        
        // Create overview
        let overview = AICTourOverviewModel(title: "Tour Overview",
                                            description: longDescription,
                                            imageUrl: imageUrl,
                                            audio: audioFile,
                                            credits: "Copyright 2016 Art Institue of Chicago"
        )
        
        // Create Stops
        var stops:[AICTourStopModel] = []
        guard let stopsData = tourJSON["stops"].array else {
            throw ParseError.tourStopsNotFound
        }
        
        var stop = 0
        for stopData in stopsData {
            do {
                try handleParseError({
                    let order       = try self.getInt(fromJSON: stopData, forKey: "sort")
                    
                    let audioFileID = try self.getInt(fromJSON: stopData, forKey: "audio")
                    let audioFile   = try self.getAudioFile(forNID:audioFileID)
                    
                    let objectID    = try self.getInt(fromJSON: stopData, forKey: "object")
                    let object      = try self.getObject(forNID: objectID)
                    
                    let stop = AICTourStopModel(order: order,
                                                object: object,
                                                audio:audioFile
                    )
                    
                    stops.append(stop)
                })
            } catch {
                if Common.Testing.printDataErrors {
                    print("Could not parse stop data:\n\(stopData) in Tour \(nid)\n")
                }
            }
            
            stop = stop + 1
        }
        
        if stops.count == 0 {
            throw ParseError.noValidTourStops
        }
        

        let bannerString = try? getString(fromJSON: tourJSON, forKey: "tour_banner")
		
		let durationInMinutes = try? getString(fromJSON: tourJSON, forKey: "tour_duration")
        
        return AICTourModel(nid:nid,
                            title: title,
                            shortDescription: shortDescription,
                            longDescription: longDescription,
                            imageUrl: imageUrl,
                            overview: overview,
                            stops: stops,
                            bannerString: bannerString,
							durationInMinutes: durationInMinutes
        )
    }
	
	// MARK: Search data
	
	func parse(autocompleteData: Data) -> [String] {
		var autocompleteStrings = [String]() // TODO: create model for autocomplete and add score
		
		let json = JSON(data: autocompleteData)
		
		do {
			try handleParseError({ [unowned self] in
				
				let optionsJson: JSON = json["suggest"]["autocomplete"][0]["options"]
				
				for optionJson: JSON in optionsJson.arrayValue {
					let text = try self.getString(fromJSON: optionJson, forKey: "text")
					autocompleteStrings.append(text)
				}
			})
		}
		catch {
			if Common.Testing.printDataErrors {
				print("Could not parse AIC Search Autocomplete:\n\(json)\n")
			}
		}
		
		// TODO: sort results by score and return only the first 3
		
		return autocompleteStrings
	}
	
	func parse(searchedArtworksData: Data) -> [AICSearchedArtworkModel] {
		var searchedArtworks = [AICSearchedArtworkModel]()
		let json = JSON(data: searchedArtworksData)
		do {
			try handleParseError({ [unowned self] in
				let dataJson: JSON = json["data"]
				for resultson: JSON in dataJson.arrayValue {
					let objectId = try self.getInt(fromJSON: resultson, forKey: "id")
					let apiLink = try self.getURL(fromJSON: resultson, forKey: "api_link")
					let score = try getFloat(fromJSON: resultson, forKey: "_score")
					let searchedArtwork = AICSearchedArtworkModel(objectId: objectId, apiLink: apiLink, score: score)
					searchedArtworks.append(searchedArtwork)
				}
			})
		}
		catch {
			if Common.Testing.printDataErrors {
				print("Could not parse AIC Search Autocomplete:\n\(json)\n")
			}
		}
		return searchedArtworks
	}
	
	func parse(searchedToursData: Data) -> [AICSearchedTourModel] {
		var searchedTours = [AICSearchedTourModel]()
		let json = JSON(data: searchedToursData)
		do {
			try handleParseError({ [unowned self] in
				let dataJson: JSON = json["data"]
				for resultson: JSON in dataJson.arrayValue {
					let tourId = try self.getInt(fromJSON: resultson, forKey: "id")
					let apiLink = try self.getURL(fromJSON: resultson, forKey: "api_link")
					let score = try getFloat(fromJSON: resultson, forKey: "_score")
					let searchedTour = AICSearchedTourModel(tourId: tourId, apiLink: apiLink, score: score)
					searchedTours.append(searchedTour)
				}
			})
		}
		catch {
			if Common.Testing.printDataErrors {
				print("Could not parse AIC Search Autocomplete:\n\(json)\n")
			}
		}
		return searchedTours
	}
	
//	func parse(searchedArtworkData: Data) -> AICSearchedArtworkModel {
//		
//	}
    
    // MARK: Error-Throwing data parsing functions
    
    // Try to unwrap a string from JSON
    private func getString(fromJSON json:JSON, forKey key:String) throws -> String {
        guard let str = json[key].string else {
            throw ParseError.missingKey(key: key)
        }
        
        return str
    }
    
    private func getBool(fromJSON json:JSON, forKey key:String) throws -> Bool {
        
        guard let bool = json[key].bool else {
            
            let bool = try getString(fromJSON: json, forKey: key)
            
            return bool == "True"
            
        }
        
        return bool
        
    }
	
	// Try to parse an float from a JSON string
	private func getFloat(fromJSON json:JSON, forKey key:String) throws -> CGFloat {
		guard let float = json[key].float else {
			
			let str = try getString(fromJSON: json, forKey: key)
			let float = Float(str)
			
			if float == nil  {
				throw ParseError.badFloatString(string: str)
			}
			
			return CGFloat(float!)
		}
		
		return CGFloat(float)
	}
    
    // Try to parse an int from a JSON string
    private func getInt(fromJSON json:JSON, forKey key:String) throws -> Int {
        guard let int = json[key].int else {
            
            let str = try getString(fromJSON: json, forKey: key)
            let int = Int(str)
            
            if int == nil  {
                throw ParseError.badIntString(string: str)
            }
            
            return int!
        }
        
        return int
    }
    
    
    private func getIntArray(fromJSON json: JSON, forArrayKey key:String) throws -> [Int]{
        
        guard let jsonArray = json[key].array else {
            throw ParseError.missingKey(key: key)
        }
        
        var intArray = [Int]()
        
        for index in 0 ..< jsonArray.count {
                let arrayInt = try self.getInt(fromJSON: json, forArrayKey: key, atIndex: index)
                intArray.append(arrayInt)
        }
        
        return intArray
    }
    
    private func getRect(fromJSON json: JSON, forKey key: String) throws -> CGRect{
        guard let cropDict = json[key].dictionary else {
            throw ParseError.missingKey(key: key)
        }
        
        guard let x = cropDict["x"]?.intValue else {
            throw ParseError.missingKey(key: "x")
        }
        guard let y = cropDict["y"]?.intValue else {
            throw ParseError.missingKey(key: "y")
        }
        guard let width = cropDict["width"]?.intValue else {
            throw ParseError.missingKey(key: "width")
        }
        guard let height = cropDict["height"]?.intValue else {
            throw ParseError.missingKey(key: "height")
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // Try to get a URL from a string
    private func getURL(fromJSON json:JSON, forKey key:String) throws -> URL {
        // Get string val and replace URL with public URL (needs to be fixed in data)
        var stringVal   = try getString(fromJSON: json, forKey: key)
        stringVal = stringVal.replacingOccurrences(of: Common.DataConstants.appDataInternalPrefix, with: Common.DataConstants.appDataExternalPrefix)
		stringVal = stringVal.replacingOccurrences(of: Common.DataConstants.appDataLocalPrefix, with: Common.DataConstants.appDataExternalPrefix)
        
        var url = URL(string: stringVal)
        
        // If we couldn't load the URL, try to parse it out from junk
        // (Again, needs to be fixed in data, news feeds namely)
        if url == nil {
            // Find URL in string
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: stringVal, options: [], range: NSMakeRange(0, stringVal.count))
            
            if matches.count != 1 {
                throw ParseError.badURLString(string: stringVal)
            }
            
            // Get the URL from the string
            var matchString = (stringVal as NSString).substring(with: matches[0].range)
            
            // MARK: This shouldn't be necessary
            // Take out backslashes, replace URLs
            matchString = matchString.replacingOccurrences(of: "\\", with: "")
            
            // Create NSURL
            url = URL(string: matchString)
            
            // No URL here, throw an error
            if url == nil {
                throw ParseError.badURLString(string: stringVal)
            }
            
            return url!
        } else {
            return url!
        }
    }
    
    // Try to Parse out the lat + long from a CMS location string,
    // i.e. "location": "41.879225,-87.622289"
    private func getCLLocation2d(fromJSON json:JSON, forKey key:String) throws -> CLLocationCoordinate2D {
        let stringVal   = try getString(fromJSON: json, forKey: key)
        
        let latLongString = stringVal.replacingOccurrences(of: " ", with: "")
        let latLong:[String] = latLongString.components(separatedBy: ",")
        if latLong.count == 2 {
            let latitude    = CLLocationDegrees(latLong[0])
            let longitude   = CLLocationDegrees(latLong[1])
            
            if latitude != nil && longitude != nil {
                return CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            }
        }
        
        throw ParseError.badCLLocationString(string: stringVal)
    }
    
    private func getInt(fromJSON json:JSON, forArrayKey arrayKey:String, atIndex index:Int) throws -> Int {
        
        let array = json[arrayKey]
        
        if array != JSON.null {
            
            if let int = array[index].int {
                return int
            } else {
                if let stringValue = array[index].string {
                    if let intValue = Int(stringValue) {
                        return intValue
                    } else {
                        throw ParseError.badIntString(string: stringValue)
                    }
                }
            }
        }
        
        throw ParseError.missingKey(key: arrayKey)
        
    }
    
    private func getAudioFile(forNID nid:Int) throws -> AICAudioFileModel {
        for audioFile in self.audioFiles {
            if audioFile.nid == nid {
                return audioFile
            }
        }
        
        throw ParseError.audioFileNotFound(nid: nid)
    }
    
    private func getObject(forNID nid:Int) throws -> AICObjectModel {
        guard let object = self.objects.filter({ $0.nid == nid}).first else {
            throw ParseError.objectNotFound(nid: nid)
        }
        
        return object
    }
    
    private func getGallery(forGalleryName galleryName:String) throws -> AICGalleryModel {
		guard let gallery = self.galleries.filter({$0.title == galleryName && $0.isOpen == true}).first else {
			throw ParseError.galleryNotFound(galleryName: galleryName)
		}
        
        return gallery
    }
    
    
    // Print messages for errors
    private func handleParseError(_ closure: () throws -> Void) throws {
        let errorMessage:String?
        
        do {
            try closure()
            return
        }
            
        catch ParseError.missingKey(let key) {
            errorMessage = "The key \"\(key)\" trying to be retrieved does not exist."
        }
            
        catch ParseError.badIntString(let string) {
            errorMessage = "Could not cast string \"\(string)\" to Int"
        }
            
        catch ParseError.badURLString(let string) {
            errorMessage = "Could not create NSURL from string \"\(string)\""
        }
            
        catch ParseError.badCLLocationString(let string) {
            errorMessage = "Could not create CLLocationCoordinate2D from string \"\(string)\""
        }
            
        catch ParseError.audioFileNotFound(let nid) {
            errorMessage = "Could not find Audio File for nid \(nid)"
        }
            
        catch ParseError.objectNotFound(let nid) {
            errorMessage = "Could not find Object for nid \(nid)"
        }
            
        catch ParseError.galleryDisabled(let galleryName) {
            errorMessage = "Gallery '\(galleryName)' is disabled, ignoring."
        }
            
        catch ParseError.galleryNotFound(let galleryName) {
            errorMessage = "Could not find gallery for gallery name '\(galleryName)'"
        }
            
        catch ParseError.jsonObjectNotFoundForKey(let key) {
            errorMessage = "Could not find Json object for key '\(key)'"
        }
        
        if errorMessage != nil && Common.Testing.printDataErrors {
            print(errorMessage!)
        }
        
        throw ParseError.objectParseFailure
    }
}
