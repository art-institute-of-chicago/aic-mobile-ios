/*
 Abstract:
 Parses the main app data file
 */

import SwiftyJSON
import CoreLocation
import Kingfisher


class AppDataParser {
    enum ParseError: Error {
        case objectParseFailure
        case missingKey(key:String)
        case badURLString(string:String)
		case badBoolString(string:String)
		case badFloatString(string:String)
        case badIntString(string:String)
        case badCLLocationString(string:String)
		case badPointString(string:String)
        case newsBadDateString(dateString:String)
        case audioFileNotFound(nid:Int)
        case objectNotFound(nid:Int)
        case galleryDisabled(galleryName:String)
        case galleryNameNotFound(galleryName:String)
		case galleryIdNotFound(galleryId:Int)
        case tourStopsNotFound
        case jsonObjectNotFoundForKey(key:String)
        case noValidTourStops
		case searchAutocompleteFailure
    }
	
	private var galleries = [AICGalleryModel]()
	private var audioFiles = [AICAudioFileModel]()
	private var objects = [AICObjectModel]()
	
	private var mapFloors: [FloorplanOverlay] = []
    
    // MARK: Exhibitions
    func parse(exhibitionsData data: Data) -> [AICExhibitionModel] {
		var exhibitionItems: [AICExhibitionModel] = []
		
		let json = JSON(data: data)
		let dataJSON: JSON = json["data"]
		for exhibitionJSON: JSON in dataJSON.arrayValue {
			do {
				try handleParseError({ [unowned self] in
					let exhibitionItem = try self.parse(exhibitionJSON: exhibitionJSON)
					exhibitionItems.append(exhibitionItem)
				})
			}
			catch {
				if Common.Testing.printDataErrors {
					print("Could not parse AIC Exhibition:\n\(exhibitionJSON)\n")
				}
			}
		}
		
		// Order by recently opened
//		newsItems = newsItems.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
		
		return exhibitionItems
    }
    
    private func parse(exhibitionJSON: JSON) throws -> AICExhibitionModel {
		let id = try getInt(fromJSON: exhibitionJSON, forKey: "id")
        let title = try getString(fromJSON: exhibitionJSON, forKey: "title")
		
		// optional description
		let description: String = try getString(fromJSON: exhibitionJSON, forKey: "short_description", optional: true)
		
		// optional image
		var imageURL: URL? = try getURL(fromJSON: exhibitionJSON, forKey: "legacy_image_mobile_url", optional: true)
		if imageURL == nil {
			imageURL = try getURL(fromJSON: exhibitionJSON, forKey: "legacy_image_desktop_url", optional: true)
		}
		
		// optional location
        var location: CoordinateWithFloor? = nil
		do {
			let galleryId = try getInt(fromJSON: exhibitionJSON, forKey: "gallery_id")
			let gallery = try getGallery(forGalleryId: galleryId)
			location = gallery.location
		}
		catch{}
		
		// optional weburl
		let webURL = try getURL(fromJSON: exhibitionJSON, forKey: "web_url", optional: true)
        
		// Get date exibition ends
		let startDateString = try getString(fromJSON: exhibitionJSON, forKey: "aic_start_at")
		let endDateString = try getString(fromJSON: exhibitionJSON, forKey: "aic_end_at")
		
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
		return AICExhibitionModel(id: id,
								  title: title,
								  shortDescription: description,
								  imageUrl: imageURL,
								  startDate: startDate,
								  endDate: endDate,
								  webUrl: webURL,
								  location: location
        )
    }
	
	// MARK: Events
	
	func parse(eventsData data: Data) -> [AICEventModel] {
		var eventItems:[AICEventModel] = []
		
		let json = JSON(data: data)
		let dataJson: JSON = json["data"]
		for eventJson: JSON in dataJson.arrayValue {
			do {
				try handleParseError({ [unowned self] in
					let eventItem = try self.parse(eventJson: eventJson)
					eventItems.append(eventItem)
				})
			}
			catch {
				if Common.Testing.printDataErrors {
					print("Could not parse AIC Event:\n\(json)\n")
				}
			}
		}
		
		return eventItems
	}
	
	func parse(eventJson: JSON) throws -> AICEventModel {
		let eventId = try getInt(fromJSON: eventJson, forKey: "id")
		let title = try getString(fromJSON: eventJson, forKey: "title")
		let longDescription = try getString(fromJSON: eventJson, forKey: "description")
		let shortDescription = try getString(fromJSON: eventJson, forKey: "short_description")
		let imageUrl: URL = try getURL(fromJSON: eventJson, forKey: "image")!
		let eventUrl = try getURL(fromJSON: eventJson, forKey: "button_url", optional: true)
		let buttonText = try getString(fromJSON: eventJson, forKey: "button_text", optional: true)
		
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
		return AICEventModel(eventId: eventId,
							 title: title,
							 shortDescription: shortDescription,
							 longDescription: longDescription,
							 imageUrl: imageUrl,
							 startDate: startDate,
							 endDate: endDate,
							 eventUrl: eventUrl,
							 buttonText: buttonText
		)
	}
    
    // MARK: App Data
    func parse(appData data:Data) -> AICAppDataModel {
        let appDataJson = JSON(data: data)
		
		let generalInfo: AICGeneralInfoModel	= parse(generalInfoJSON: appDataJson["general_info"])
		self.galleries	= parse(galleriesJSON: appDataJson["galleries"])
		self.audioFiles = parse(audioFilesJSON: appDataJson["audio_files"])
        self.objects 	= parse(objectsJSON: appDataJson["objects"])
		let tours: [AICTourModel]	 = parse(toursJSON: appDataJson["tours"])
		let map: AICMapModel = parse(mapFloorsJSON: appDataJson["map_floors"], mapAnnotationsJSON: appDataJson["annontations"])
		let featuredTours = parseFeaturedItems(dashboardJSON: appDataJson["dashboard"], arrayKey: "featured_tours")
		let featuredExhibitions = parseFeaturedItems(dashboardJSON: appDataJson["dashboard"], arrayKey: "featured_exhibitions")
		let exhibitionOptionalImages = parse(exhibitionImagesJSON: appDataJson["exhibitions"])
		let dataSettings = parse(dataSettingsJSON: appDataJson["data"])
		
		let appData = AICAppDataModel(generalInfo: generalInfo,
									  galleries: self.galleries,
									  objects: self.objects,
									  audioFiles: self.audioFiles,
									  tours: tours,
									  map: map,
									  featuredTours: featuredTours,
									  featuredExhibitions: featuredExhibitions,
									  exhibitionOptionalImages: exhibitionOptionalImages,
									  dataSettings: dataSettings
		)
		
		return appData
    }
	
	// MARK: Featured Tours and Exhibitis
	func parseFeaturedItems(dashboardJSON: JSON, arrayKey: String) -> [Int] {
		var featuredItems: [Int] = []
		do {
			featuredItems = try getIntArray(fromJSON: dashboardJSON, forArrayKey: arrayKey)
		}
		catch {
			if Common.Testing.printDataErrors {
				print("Could not parse Featured Items list for key '\(arrayKey)':\n\(dashboardJSON)\n")
			}
		}
		return featuredItems
	}
	
	// MARK: General Info
	func parse(generalInfoJSON: JSON) -> AICGeneralInfoModel {
		do {
			let nid         = try getInt(fromJSON: generalInfoJSON, forKey: "nid")
			
			var translations: [Common.Language : AICGeneralInfoTranslationModel] = [:]
			let translationsJSON = generalInfoJSON["translations"].array
			
			let translationEng = try parseTranslation(generalInfoJSON: generalInfoJSON, optional: true)
			translations[.english] = translationEng
			
			for translationJSON in translationsJSON! {
				do {
					let language = try getLanguageFor(translationJSON: translationJSON)
					let translation = try parseTranslation(generalInfoJSON: translationJSON)
					translations[language] = translation
				} catch {
					if Common.Testing.printDataErrors {
						print("Could not parse General Info translation:\n\(translationJSON)\n")
					}
				}
			}
			
			return AICGeneralInfoModel(nid: nid, translations: translations)
		}
		catch {
			if Common.Testing.printDataErrors {
				print("Could not parse AIC General Info Data:\n\(generalInfoJSON)\n")
			}
		}
		
		return AICGeneralInfoModel(nid: 0, translations: [Common.Language : AICGeneralInfoTranslationModel]())
	}
	
	func parseTranslation(generalInfoJSON: JSON, optional: Bool = false) throws -> AICGeneralInfoTranslationModel {
		let museumHours	= try getString(fromJSON: generalInfoJSON, forKey: "museum_hours", optional: optional)
		let homeMemberPrompt = try getString(fromJSON: generalInfoJSON, forKey: "home_member_prompt_text", optional: optional)
		let audioTitle = try getString(fromJSON: generalInfoJSON, forKey: "audio_title", optional: optional)
		let audioSubtitle = try getString(fromJSON: generalInfoJSON, forKey: "audio_subtitle", optional: optional)
		let mapTitle = try getString(fromJSON: generalInfoJSON, forKey: "map_title", optional: optional)
		let mapSubtitle = try getString(fromJSON: generalInfoJSON, forKey: "map_subtitle", optional: optional)
		let infoTitle = try getString(fromJSON: generalInfoJSON, forKey: "info_title", optional: optional)
		let infoSubtitle = try getString(fromJSON: generalInfoJSON, forKey: "info_subtitle", optional: optional)
		
		return AICGeneralInfoTranslationModel(museumHours: museumHours,
								   homeMemberPrompt: homeMemberPrompt,
								   audioTitle: audioTitle,
								   audioSubtitle: audioSubtitle,
								   mapTitle: mapTitle,
								   mapSubtitle: mapSubtitle,
								   infoTitle: infoTitle,
								   infoSubtitle: infoSubtitle
		)
	}
	
	// MARK: Galleries
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
		
		let galleryId	= try getInt(fromJSON: galleryJSON!, forKey: "gallery_id")
		
        var displayTitle = title.replacingOccurrences(of: "Gallery ", with: "")
        displayTitle = displayTitle.replacingOccurrences(of: "Galleries ", with: "")
        
        //Check for gallery disabled
		let isOpen: Bool = !(try getBool(fromJSON: galleryJSON!, forKey:"closed"))
        
        let location = try getCLLocation2d(fromJSON: galleryJSON!, forKey: "location")
        
        // Floor 0 comes through as LL, so parse that out
        let lowerLevel = try? getString(fromJSON: galleryJSON!, forKey: "floor")
        let floorNumber:Int! = lowerLevel == "LL" ? 0 : try getInt(fromJSON: galleryJSON!, forKey: "floor")
        
        let gallery = AICGalleryModel(id: nid,
									  galleryId: galleryId,
                                      title: title,
                                      displayTitle: displayTitle,
                                      location: CoordinateWithFloor(coordinate: location, floor: floorNumber),
                                      isOpen: isOpen
        )
        
        return gallery
    }
    
	// MARK: Objects
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
		let objectId        = try getInt(fromJSON:objectJSON, forKey: "id")
        let location        = try getCLLocation2d(fromJSON: objectJSON, forKey:"location")
        
        let galleryName     = try getString(fromJSON: objectJSON, forKey: "gallery_location")
        let gallery     	= try getGallery(forGalleryName: galleryName)
		let floorNumber		= gallery.location.floor
        
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
        var thumbnailCropRect: CGRect? = try? getRect(fromJSON: objectJSON, forKey: "thumbnail_crop_v2")
        var imageCropRect: CGRect? = try? getRect(fromJSON: objectJSON, forKey: "large_image_crop_v2")
        
        if imageHasBeenOverridden || !Common.DataConstants.ignoreOverrideImageCrop {
            //Feature #886 - Ignore / Allow crops for overriden images
            thumbnailCropRect = nil
            imageCropRect = nil
        }
        
        // Ingest all audio IDs
        var audioCommentaries = [AICAudioCommentaryModel]()
		if let audioCommentariesJSON = objectJSON["audio_commentary"].array {
			for audioCommentaryJSON in audioCommentariesJSON {
				do {
					let audioCommentary = try parse(audioCommentaryJSON: audioCommentaryJSON)
					audioCommentaries.append(audioCommentary)
				}
				catch {
					if Common.Testing.printDataErrors {
						print("Could not parse AIC AUdio Commentary Data:\n\(audioCommentaryJSON)\n")
					}
				}
			}
		}
        
        return AICObjectModel(nid: nid,
							  objectId: objectId,
                              thumbnailUrl: thumbnail,
                              thumbnailCropRect: thumbnailCropRect,
                              imageUrl: image,
                              imageCropRect: imageCropRect,
                              title: title,
                              audioCommentaries: audioCommentaries,
                              tombstone: tombstone,
                              credits: credits,
                              imageCopyright: imageCopyright,
                              location: CoordinateWithFloor(coordinate: location, floor: floorNumber),
							  gallery: gallery
        )
    }
	
	// MARK: Audio Commentary
	func parse(audioCommentaryJSON: JSON) throws -> AICAudioCommentaryModel {
		// Selector number is optional
		var selectorNumber: Int?  = nil
		do {
			selectorNumber = try getInt(fromJSON: audioCommentaryJSON, forKey: "object_selector_number")
		} catch {}
		
		let audioID	= try getInt(fromJSON: audioCommentaryJSON, forKey: "audio")
		let audioFile = try getAudioFile(forNID: audioID)
		
		return AICAudioCommentaryModel(selectorNumber: selectorNumber,
									   audioFile: audioFile
		)
	}
    
	// MARK: Audio Files
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
        let nid 	= try getInt(fromJSON: audioFileJSON, forKey: "nid")
		let title	= try getString(fromJSON: audioFileJSON, forKey: "title")
		
		var translations: [Common.Language : AICAudioFileTranslationModel] = [:]
		let translationsJSON = audioFileJSON["translations"].array
		
		var translationEng = try parseTranslation(audioFileJSON: audioFileJSON)
		// default to the title of the Audio File if English track title is not provided
		if translationEng.trackTitle.isEmpty {
			translationEng.trackTitle = title
		}
		translations[.english] = translationEng
		
		for translationJSON in translationsJSON! {
			do {
				let language = try getLanguageFor(translationJSON: translationJSON)
				var translation = try parseTranslation(audioFileJSON: translationJSON)
				
				// default to English track title or if a Spanish/Chinese track title is not provided
				if translation.trackTitle.isEmpty {
					translation.trackTitle = translationEng.trackTitle
				}
				
				translations[language] = translation
			} catch {
				if Common.Testing.printDataErrors {
					print("Could not parse Audio translation:\n\(translationJSON)\n")
				}
			}
		}
		
		return AICAudioFileModel(nid:nid,
								 translations: translations,
								 language: .english
		)
	}
	
	func parseTranslation(audioFileJSON: JSON) throws -> AICAudioFileTranslationModel {
		let url: URL    = try getURL(fromJSON: audioFileJSON, forKey: "audio_file_url")!
		let transcript  = try getString(fromJSON: audioFileJSON, forKey: "audio_transcript")
		let trackTitle = try getString(fromJSON: audioFileJSON, forKey: "track_title", optional: true)
		
		return AICAudioFileTranslationModel(trackTitle: trackTitle,
											url: url,
											transcript: transcript
		)
	}
	
	// MARK: Parse tours
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
		let imageUrl: URL       = try getURL(fromJSON: tourJSON, forKey: "image_url")!
        
        let audioFileID         = try getInt(fromJSON: tourJSON, forKey: "tour_audio")
        let audioFile           = try getAudioFile(forNID:audioFileID)
        
        // Create Stops
        var stops:[AICTourStopModel] = []
        guard let stopsData = tourJSON["tour_stops"].array else {
            throw ParseError.tourStopsNotFound
        }
        
        var stop = 0
        for stopData in stopsData {
            do {
                try handleParseError({
                    let order       = try self.getInt(fromJSON: stopData, forKey: "sort")
					
					let objectID    = try self.getInt(fromJSON: stopData, forKey: "object")
					let object      = try self.getObject(forNID: objectID)
                    
                    let audioFileID = try self.getInt(fromJSON: stopData, forKey: "audio_id")
                    let audioFile   = try self.getAudioFile(forNID: audioFileID)
					
					// Selector number is optional
					var audioBumper: AICAudioFileModel?
					do {
						let audioBumperID	= try getInt(fromJSON: stopData, forKey: "audio_bumper")
						audioBumper			= try self.getAudioFile(forNID: audioBumperID)
					} catch {
						audioBumper = nil
					}
                    
                    let stop = AICTourStopModel(order: order,
                                                object: object,
                                                audio:audioFile,
												audioBumper: audioBumper
                    )
                    
                    stops.append(stop)
                })
            } catch {
                if Common.Testing.printDataErrors {
                    //print("Could not parse stop data:\n\(stopData) in Tour \(nid)\n")
                }
            }
            
            stop = stop + 1
        }
        
        if stops.count == 0 {
            throw ParseError.noValidTourStops
        }
		
		let location = try getCLLocation2d(fromJSON: tourJSON, forKey: "location")
		
		var floor: Int? = nil
		do {
			floor = try getInt(fromJSON: tourJSON, forKey: "floor")
		}
		catch {
			floor = stops.first!.object.location.floor
		}
		
		let coordinate = CoordinateWithFloor(coordinate: location, floor: floor!)
		
		var translations: [Common.Language : AICTourTranslationModel] = [:]
		let translationsJSON = tourJSON["translations"].array
		
		let translationEng = try parseTranslation(tourJSON: tourJSON, imageUrl: imageUrl, audioFile: audioFile)
		translations[.english] = translationEng
		
		for translationJSON in translationsJSON! {
			do {
				let language = try getLanguageFor(translationJSON: translationJSON)
				let translation = try parseTranslation(tourJSON: translationJSON, imageUrl: imageUrl, audioFile: audioFile)
				translations[language] = translation
			} catch {
				if Common.Testing.printDataErrors {
					print("Could not parse General Info translation:\n\(translationJSON)\n")
				}
			}
		}
        
        return AICTourModel(nid:nid,
							imageUrl: imageUrl,
							location: coordinate,
                            stops: stops,
							translations: translations,
							language: .english
        )
    }
	
	func parseTranslation(tourJSON: JSON, imageUrl: URL, audioFile: AICAudioFileModel) throws -> AICTourTranslationModel {
		let title				= try getString(fromJSON: tourJSON, forKey: "title")
		let shortDescription	= try getString(fromJSON: tourJSON, forKey: "description")
		
		var longDescription		= try getString(fromJSON: tourJSON, forKey: "intro")
		longDescription = "\(shortDescription)\r\r\(longDescription)"
		
		let durationInMinutes = try? getString(fromJSON: tourJSON, forKey: "tour_duration")
		
		// Create overview
		let overview = AICTourOverviewModel(title: title,
											description: longDescription,
											imageUrl: imageUrl,
											audio: audioFile,
											credits: "Copyright 2016 Art Institue of Chicago"
		)
		
		return AICTourTranslationModel(title: title,
									   shortDescription: shortDescription,
									   longDescription: longDescription,
									   durationInMinutes: durationInMinutes,
									   overview: overview
		)
	}
	
	// MARK: Map
	
	func parse(mapFloorsJSON: JSON, mapAnnotationsJSON: JSON) -> AICMapModel {
		// Background
		let backgroundPdfUrl = Bundle.main.url(forResource: "map_bg", withExtension: "pdf", subdirectory:Common.Map.mapsDirectory)!
		
		let backgroundOverlay = FloorplanOverlay(floorplanUrl: backgroundPdfUrl, withPDFBox: CGPDFBox.trimBox, andAnchors: Common.Map.anchorPair)
		
		do {
			var floorOverlays: [FloorplanOverlay] = []
			var floorGalleryAnnotations: [Int : [MapTextAnnotation]] = [:]
			var floorObjectAnnotations: [Int : [MapObjectAnnotation]] = [:]
			
			// Floors
			for floorNumber in 0..<Common.Map.totalFloors {
				let mapFloorJSON = mapFloorsJSON["map_floor\(floorNumber)"]
				
				let floorPdfURL: URL = try getURL(fromJSON: mapFloorJSON, forKey: "floor_plan")!
				let anchorPixel1 = try getPoint(fromJSON: mapFloorJSON, forKey: "anchor_pixel_1")
				let anchorPixel2 = try getPoint(fromJSON: mapFloorJSON, forKey: "anchor_pixel_2")
				let anchorLocation1 = try getCLLocation2d(fromJSON: mapFloorJSON, forKey: "anchor_location_1")
				let anchorLocation2 = try getCLLocation2d(fromJSON: mapFloorJSON, forKey: "anchor_location_2")
				let anchor1 = GeoAnchor(latitudeLongitudeCoordinate: anchorLocation1, pdfPoint: anchorPixel1)
				let anchor2 = GeoAnchor(latitudeLongitudeCoordinate: anchorLocation2, pdfPoint: anchorPixel2)
				
				let floorOverlay = FloorplanOverlay(floorplanUrl: floorPdfURL,
											 withPDFBox: CGPDFBox.trimBox,
											 andAnchors: GeoAnchorPair(fromAnchor: anchor1, toAnchor: anchor2))
				floorOverlays.append(floorOverlay)
				
				// Galleries
				let galleryAnnotations = getGalleryAnnotations(forFloorNumber: floorNumber)
				floorGalleryAnnotations[floorNumber] = galleryAnnotations
				
				// Artworks
				let floorObjects = self.objects.filter( { $0.location.floor == floorNumber })
				var objectAnnotations: [MapObjectAnnotation] = []
				for object in floorObjects {
					objectAnnotations.append(MapObjectAnnotation(object: object))
				}
				floorObjectAnnotations[floorNumber] = objectAnnotations
				
			}
			
			// Annotations
			var imageAnnotations: [MapImageAnnotation] = []
			var landmarkAnnotations: [MapTextAnnotation] = []
			var gardenAnnotations: [MapTextAnnotation] = []
			var floorAmenityAnnotations: [Int : [MapAmenityAnnotation]] = [
				0 : [MapAmenityAnnotation](),
				1 : [MapAmenityAnnotation](),
				2 : [MapAmenityAnnotation](),
				3 : [MapAmenityAnnotation]()
			]
			var floorDepartmentAnnotations: [Int : [MapDepartmentAnnotation]] = [
				0 : [MapDepartmentAnnotation](),
				1 : [MapDepartmentAnnotation](),
				2 : [MapDepartmentAnnotation](),
				3 : [MapDepartmentAnnotation]()
			]
			var floorSpaceAnnotations: [Int : [MapTextAnnotation]] = [
				0 : [MapTextAnnotation](),
				1 : [MapTextAnnotation](),
				2 : [MapTextAnnotation](),
				3 : [MapTextAnnotation]()
			]
			for (_, annotationJSON):(String, JSON) in mapAnnotationsJSON.dictionaryValue {
				do {
					var floorNumber: Int? = nil
					do {
						floorNumber = try getInt(fromJSON: annotationJSON, forKey: "floor")
					}
					catch {}
					
					let type = try getString(fromJSON: annotationJSON, forKey: "annotation_type")
					
					if type == "Amenity" && floorNumber != nil {
						let amenityAnnotation = try parse(amenityAnnotationJSON: annotationJSON)
						floorAmenityAnnotations[floorNumber!]!.append(amenityAnnotation)
					}
					else if type == "Text" {
						let textType = try getString(fromJSON: annotationJSON, forKey: "text_type")
						if textType == MapTextAnnotation.AnnotationType.Space.rawValue && floorNumber != nil {
							let textAnnotation = try parse(textAnnotationJSON: annotationJSON, type: MapTextAnnotation.AnnotationType.Space)
							floorSpaceAnnotations[floorNumber!]!.append(textAnnotation)
						}
						else if textType == MapTextAnnotation.AnnotationType.Landmark.rawValue {
							let textAnnotation = try parse(textAnnotationJSON: annotationJSON, type: MapTextAnnotation.AnnotationType.Landmark)
							landmarkAnnotations.append(textAnnotation)
						}
						else if textType == MapTextAnnotation.AnnotationType.Garden.rawValue {
							let textAnnotation = try parse(textAnnotationJSON: annotationJSON, type: MapTextAnnotation.AnnotationType.Garden)
							gardenAnnotations.append(textAnnotation)
						}
					}
					else if type == "Department" && floorNumber != nil {
						let departmentAnnotation = try parse(departmentAnnotationJSON: annotationJSON)
						floorDepartmentAnnotations[floorNumber!]!.append(departmentAnnotation)
					}
//					else if type == "Image" {
//						let imageAnnotation = try parse(imageAnnotationJSON: annotationJSON)
//						imageAnnotations.append(imageAnnotation)
//					}
				}
				catch {
					if Common.Testing.printDataErrors {
						print("Could not parse AIC Map Annotations for node: \(annotationJSON)\n")
					}
				}
			}
			
			// Lions
			let lion1 = MapImageAnnotation(coordinate: CLLocationCoordinate2DMake(41.879678006591391, -87.624091248446064), image: #imageLiteral(resourceName: "Lion1"), identifier: "Lion1")
			let lion2 = MapImageAnnotation(coordinate: CLLocationCoordinate2DMake(41.879491568164525, -87.624089977901931), image: #imageLiteral(resourceName: "Lion2"), identifier: "Lion2")
			imageAnnotations.append(lion1)
			imageAnnotations.append(lion2)
			
			var floors: [AICMapFloorModel] = []
			for floorNumber in 0..<Common.Map.totalFloors {
				let floor = AICMapFloorModel(floorNumber: floorNumber,
											 overlay: floorOverlays[floorNumber],
											 objects: floorObjectAnnotations[floorNumber]!,
											 amenities: floorAmenityAnnotations[floorNumber]!,
											 departments: floorDepartmentAnnotations[floorNumber]!,
											 galleries: floorGalleryAnnotations[floorNumber]!,
											 spaces: floorSpaceAnnotations[floorNumber]!
				)
				floors.append(floor)
			}
			
			return AICMapModel(backgroundOverlay: backgroundOverlay,
							   imageAnnotations: imageAnnotations,
							   landmarkAnnotations: landmarkAnnotations,
							   gardenAnnotations: gardenAnnotations,
							   floors: floors)
		}
		catch {
			if Common.Testing.printDataErrors {
				print("Could not parse AIC Map\n")
			}
		}
		
		return AICMapModel(backgroundOverlay: backgroundOverlay,
						   imageAnnotations: [MapImageAnnotation](),
						   landmarkAnnotations: [MapTextAnnotation](),
						   gardenAnnotations: [MapTextAnnotation](),
						   floors: [AICMapFloorModel]())
		
		// Global Annotations
//		lionAnnotations     = getImageAnnotations(fromSvgImages: svgParser.lions)
//		landmarkAnnotations = getTextAnnotations(fromSVGTextLabels: svgParser.landmarks, type: MapTextAnnotation.AnnotationType.LandmarkGarden)
//		gardenAnnotations   = getTextAnnotations(fromSVGTextLabels: svgParser.gardens, type: MapTextAnnotation.AnnotationType.LandmarkGarden)
		
		// Floors
//		for i in 0..<Common.Map.totalFloors {
//			let svgFloor = svgParser.floors[i]
//
//			// Get the gallery annotations for this floor
//			let galleryAnnotations = getGalleryAnnotations(forFloorNumber: i)
//
//			//            // Convert SVG Annotations for this floor (amenities, departments, spaces) to map annotations
//			//            let amenityAnnotations:[MapAmenityAnnotation]           = getAmenityAnnotations(fromSVGAmenities: svgFloor.amenities)
//			//            let departmentAnnotations:[MapDepartmentAnnotation]     = getDepartmentAnnotations(fromSVGDepartments: svgFloor.departments)
//			//            let spaceAnnotations:[MapTextAnnotation]                = getTextAnnotations(fromSVGTextLabels: svgFloor.spaces, type: MapTextAnnotation.AnnotationType.Space)
//
//
//			// Create annotations for objects on this floor from app data
//			var objectAnnotations:[MapObjectAnnotation] = []
//			for object in AppDataManager.sharedInstance.getObjects(forFloor: i) {
//				objectAnnotations.append(MapObjectAnnotation(object: object))
//			}
//
//			// Load Floorplan Overlay (Part of Apple Footprint) from PDF
//			let pdfUrl = Bundle.main.url(forResource: Common.Map.floorplanFileNamePrefix + String(i), withExtension: "pdf", subdirectory:Common.Map.mapsDirectory)!
//
//			let overlay = FloorplanOverlay(floorplanUrl: pdfUrl, withPDFBox: CGPDFBox.trimBox, andAnchors: Common.Map.anchorPair)
//
//			// Create this floor
//			let floor = AICMapFloorModel(floorNumber: i,
//										 overlay: overlay,
//										 objects:objectAnnotations,
//										 amenities: [MapAmenityAnnotation](),
//										 departments: [MapDepartmentAnnotation](),
//										 galleries: [MapTextAnnotation](),
//										 spaces: [MapTextAnnotation]()
//			)
//
//			floors.append(floor)
//		}
	}
	
	// Gallery annotations
	private func getGalleryAnnotations(forFloorNumber floorNumber: Int) -> [MapTextAnnotation] {
		var galleryAnnotations: [MapTextAnnotation] = []
		
		let galleriesForThisFloor = self.galleries.filter( { $0.location.floor == floorNumber })
		for gallery in galleriesForThisFloor {
			galleryAnnotations.append(MapTextAnnotation(coordinate: gallery.location.coordinate, text: gallery.displayTitle, type: MapTextAnnotation.AnnotationType.Gallery))
		}
		
		return galleryAnnotations
	}
	
	// Amenity Annotations
	private func parse(amenityAnnotationJSON: JSON) throws -> MapAmenityAnnotation {
		let coordinate = try getCLLocation2d(fromJSON: amenityAnnotationJSON, forKey: "location")
		
		let typeString = try getString(fromJSON: amenityAnnotationJSON, forKey: "amenity_type")
		let type: MapAmenityAnnotationType = MapAmenityAnnotationType(rawValue: typeString)!
		
		return MapAmenityAnnotation(coordinate: coordinate, type: type)
	}
	
	// Department Annotations
	private func parse(departmentAnnotationJSON: JSON) throws -> MapDepartmentAnnotation {
		let coordinate = try getCLLocation2d(fromJSON: departmentAnnotationJSON, forKey: "location")
		let title = try getString(fromJSON: departmentAnnotationJSON, forKey: "label")
		
		return MapDepartmentAnnotation(coordinate: coordinate, title: title, imageName: "islamic")
	}
	
	// Text Annotations
	private func parse(textAnnotationJSON: JSON, type: MapTextAnnotation.AnnotationType) throws -> MapTextAnnotation {
		let coordinate = try getCLLocation2d(fromJSON: textAnnotationJSON, forKey: "location")
		let text = try getString(fromJSON: textAnnotationJSON, forKey: "label")
		
		return MapTextAnnotation(coordinate: coordinate, text: text, type: type)
	}
	
	// Image Annotations
	private func parse(imageAnnotationJSON: JSON) throws -> MapImageAnnotation {
		let coordinate = try getCLLocation2d(fromJSON: imageAnnotationJSON, forKey: "location")
		let imageUrl = try getURL(fromJSON: imageAnnotationJSON, forKey: "image_url")!
		
		return MapImageAnnotation(coordinate: coordinate, imageUrl: imageUrl)
	}
	
	// MARK: Exhibition Images
	
	func parse(exhibitionImagesJSON: JSON) -> [Int : URL] {
		var exhibitionImages = [Int : URL]()
		for (exhibitionId, exhibitionImageJSON):(String, JSON) in exhibitionImagesJSON.dictionaryValue {
			do {
				try handleParseError({
					let imageUrl: URL = try getURL(fromJSON: exhibitionImageJSON, forKey: "image_url")!
					exhibitionImages[Int(exhibitionId)!] = imageUrl
				})
			}
			catch {
				if Common.Testing.printDataErrors {
					print("Could not parse Exhibition Images:\n\(exhibitionImagesJSON)\n")
				}
			}
		}
		return exhibitionImages
	}
	
	// MARK: Data Settings
	
	func parse(dataSettingsJSON: JSON) -> [Common.DataSetting : String] {
		var dataSettings = [Common.DataSetting : String]()
		do {
			dataSettings[.imageServerUrl] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.imageServerUrl.rawValue)
			dataSettings[.dataApiUrl] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.dataApiUrl.rawValue)
			dataSettings[.exhibitionsEndpoint] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.exhibitionsEndpoint.rawValue)
			dataSettings[.artworksEndpoint] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.artworksEndpoint.rawValue)
			dataSettings[.galleriesEndpoint] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.galleriesEndpoint.rawValue)
			dataSettings[.imagesEndpoint] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.imagesEndpoint.rawValue)
			dataSettings[.eventsEndpoint] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.eventsEndpoint.rawValue)
			dataSettings[.autocompleteEndpoint] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.autocompleteEndpoint.rawValue)
			dataSettings[.toursEndpoint] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.toursEndpoint.rawValue)
			dataSettings[.ticketsUrl] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.ticketsUrl.rawValue)
		}
		catch {
			if Common.Testing.printDataErrors {
				print("Could not parse Data Settings:\n\(dataSettingsJSON)\n")
			}
		}
		return dataSettings
	}
	
	// MARK: Search
	
	func parse(autocompleteData: Data) -> [String] {
		var autocompleteStrings = [String]()
		
		do {
			try handleParseError({ [unowned self] in
				
				let json = JSON(data: autocompleteData)
				if let jsonArray: [JSON] = json.array {
					if jsonArray.count == 0 {
						return
					}
					for index in 0...jsonArray.count-1 {
						let autocompleteString = jsonArray[index].string
						autocompleteStrings.append(autocompleteString!)
					}
				}
			})
		}
		catch {
			if Common.Testing.printDataErrors {
				print("Could not parse AIC Search Autocomplete\n")
			}
		}
		
		return autocompleteStrings
	}
	
	func parse(searchedArtworksData: Data) -> [AICSearchedArtworkModel] {
		var searchedArtworks = [AICSearchedArtworkModel]()
		
		let json = JSON(data: searchedArtworksData)
		
		let dataJSON: JSON = json["data"]
		for resultJSON: JSON in dataJSON.arrayValue {
			do {
				try handleParseError({ [unowned self] in
					let artworkId = try self.getInt(fromJSON: resultJSON, forKey: "id")
					let isOnView = try self.getBool(fromJSON: resultJSON, forKey: "is_on_view")
					
					// If this artwork is also in the mobile CMS,
					// we get the data correspondent data from the AICObjectModel
					if let object = AppDataManager.sharedInstance.getObject(forObjectID: artworkId) {
						var artistDisplay = ""
						if let tombstone = object.tombstone {
							artistDisplay = tombstone
						}
						let searchedArtwork = AICSearchedArtworkModel(artworkId: artworkId,
																	  audioObject: object,
																	  title: object.title,
																	  thumbnailUrl: object.thumbnailUrl,
																	  imageUrl: object.imageUrl,
																	  artistDisplay: artistDisplay,
																	  location: object.location,
																	  gallery: object.gallery)
						searchedArtworks.append(searchedArtwork)
					}
					// Otherwise we parse from the data api
					else if isOnView {
						let audioObject: AICObjectModel? = nil
						let title: String = try getString(fromJSON: resultJSON, forKey: "title")
						let artistDisplay: String = try getString(fromJSON: resultJSON, forKey: "artist_display")
						
						// optional
						var thumbnailUrl: URL? = nil
						var imageUrl: URL? = nil
						do {
							let imageId = try getString(fromJSON: resultJSON, forKey: "image_id")
							let iiifString = AppDataManager.sharedInstance.app.dataSettings[.imageServerUrl]! + "/" + imageId
							let thumbnailString: String = iiifString + "/full/!200,200/0/default.jpg"
							let imageString: String = iiifString + "/full/!800,800/0/default.jpg"
							thumbnailUrl = URL(string: thumbnailString)
							imageUrl = URL(string: imageString)
						}
						catch {}
						
						if thumbnailUrl == nil {
							thumbnailUrl = URL(string: "http://aic-mobile-tours.artic.edu/sites/default_staging/files/object-images/AIC_ImagePlaceholder_25.png")!
						}
						if imageUrl == nil {
							imageUrl = URL(string: "http://aic-mobile-tours.artic.edu/sites/default_staging/files/object-images/AIC_ImagePlaceholder_25.png")!
						}
						
						let galleryId 		= try getInt(fromJSON: resultJSON, forKey: "gallery_id")
						let gallery     	= try getGallery(forGalleryId: galleryId)
						
						var location: CoordinateWithFloor? = nil
						do {
							let coreLocation = try getCLLocation2d(fromJSON: resultJSON, forKey: "latlon")
							let floorNumber		= gallery.location.floor
							location = CoordinateWithFloor(coordinate: coreLocation, floor: floorNumber)
						}
						catch{}
						
						if location == nil {
							location = gallery.location
						}
						
						let searchedArtwork = AICSearchedArtworkModel(artworkId: artworkId,
																	  audioObject: audioObject,
																	  title: title,
																	  thumbnailUrl: thumbnailUrl!,
																	  imageUrl: imageUrl!,
																	  artistDisplay: artistDisplay,
																	  location: location!,
																	  gallery: gallery)
						searchedArtworks.append(searchedArtwork)
					}
				})
			}
			catch {
				if Common.Testing.printDataErrors {
					print("Could not parse AIC Search Autocomplete:\n\(json)\n")
				}
			}
		}
		
		return searchedArtworks
	}
	
	/// Parse Searched Tours
	///
	/// Returns an array of tourIds to match with the tours in the appData.json
	func parse(searchedToursData: Data) -> [Int] {
		var searchedTours = [Int]()
		let json = JSON(data: searchedToursData)
		do {
			try handleParseError({ [unowned self] in
				let dataJson: JSON = json["data"]
				for resultson: JSON in dataJson.arrayValue {
					let tourId = try self.getInt(fromJSON: resultson, forKey: "id")
					searchedTours.append(tourId)
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
    
    // MARK: Error-Throwing data parsing functions
    
    // Try to unwrap a string from JSON
	private func getString(fromJSON json:JSON, forKey key:String, optional: Bool = false) throws -> String {
        guard let str = json[key].string else {
			if optional == false {
            	throw ParseError.missingKey(key: key)
			}
			else {
				return ""
			}
        }
        
        return str
    }
    
	private func getBool(fromJSON json:JSON, forKey key:String, optional: Bool = false, optionalValue: Bool = false) throws -> Bool {
        guard let bool = json[key].bool else {
			if optional == false {
				let str = try getString(fromJSON: json, forKey: key)
				throw ParseError.badBoolString(string: str)
			}
			else {
				return optionalValue
			}
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
	private func getURL(fromJSON json:JSON, forKey key:String, optional: Bool = false) throws -> URL? {
		var stringVal = json[key].string
		if stringVal == nil {
			if optional == false {
				throw ParseError.badURLString(string: "null")
			}
			else {
				return nil
			}
		}
		
		// Get string val and replace URL with public URL (needs to be fixed in data)
        stringVal = stringVal!.replacingOccurrences(of: Common.DataConstants.appDataInternalPrefix, with: Common.DataConstants.appDataExternalPrefix)
		stringVal = stringVal!.replacingOccurrences(of: Common.DataConstants.appDataLocalPrefix, with: Common.DataConstants.appDataExternalPrefix)
        
		guard let url: URL = URL(string: stringVal!) else {
			if optional == false {
				throw ParseError.badURLString(string: stringVal!)
			}
			else {
				return nil
			}
		}
		
		return url
    }
    
    // Try to Parse out the lat + long from a CMS location string,
    // i.e. "location": "41.879225,-87.622289"
    private func getCLLocation2d(fromJSON json: JSON, forKey key: String) throws -> CLLocationCoordinate2D {
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
	
	private func getPoint(fromJSON json: JSON, forKey key: String) throws -> CGPoint {
		var stringVal = try getString(fromJSON: json, forKey: key)
		
		stringVal = stringVal.replacingOccurrences(of: " ", with: "")
		let xyStrings: [String] = stringVal.components(separatedBy: ",")
		if xyStrings.count == 2 {
			let x = CGFloat(Float(xyStrings[0])!)
			let y = CGFloat(Float(xyStrings[1])!)
			
			return CGPoint(x: x, y: y)
		}
		
		throw ParseError.badPointString(string: stringVal)
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
    
    private func getGallery(forGalleryName galleryName: String) throws -> AICGalleryModel {
		guard let gallery = self.galleries.filter({$0.title == galleryName && $0.isOpen == true}).first else {
			throw ParseError.galleryNameNotFound(galleryName: galleryName)
		}
        
        return gallery
    }
	
	private func getGallery(forGalleryId galleryId: Int) throws -> AICGalleryModel {
		guard let gallery = AppDataManager.sharedInstance.app.galleries.filter({$0.galleryId == galleryId && $0.isOpen == true}).first else {
			throw ParseError.galleryIdNotFound(galleryId: galleryId)
		}
		return gallery
	}
	
	private func getLanguageFor(translationJSON: JSON) throws -> Common.Language {
		do {
			let language = try getString(fromJSON: translationJSON, forKey: "language")
			if language.hasPrefix("es") {
				return .spanish
			}
			else if language.hasPrefix("zh") {
				return .chinese
			}
		}
		catch  {
			if Common.Testing.printDataErrors {
				print("Could not parse Translation language:\n\(translationJSON)\n")
			}
		}
		return .english
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
			
		catch ParseError.badBoolString(let string) {
			errorMessage = "Could not cast string \"\(string)\" to Bool"
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
			
		catch ParseError.badPointString(let string) {
			errorMessage = "Could not create CGPoint from string \"\(string)\""
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
            
        catch ParseError.galleryNameNotFound(let galleryName) {
            errorMessage = "Could not find gallery for gallery name '\(galleryName)'"
        }
			
		catch ParseError.galleryIdNotFound(let galleryId) {
			errorMessage = "Could not find gallery for gallery Id '\(galleryId)'"
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
