/*
Abstract:
Parses the main app data file
*/

import SwiftyJSON
import MapKit

final class AppDataParser {
	private var galleries = [AICGalleryModel]()
	private var audioFiles = [AICAudioFileModel]()
	private var objects = [AICObjectModel]()
	private var restaurants = [AICRestaurantModel]()
	private var tourCategories = [AICTourCategoryModel]()
	private var searchArtworks = [AICObjectModel]()
	private var mapFloorsURLs = [URL]()
    private let crashlyticsManager: CrashlyticsManager

    init(crashlyticsManager: CrashlyticsManager) {
        self.crashlyticsManager = crashlyticsManager
    }

	func parse(appData data: Data) -> AICAppDataModel {
		let appDataJson = try! JSON(data: data)

		let generalInfo = parse(generalInfoJSON: appDataJson["general_info"])
		galleries = parse(galleriesJSON: appDataJson["galleries"])
		audioFiles = parse(audioFilesJSON: appDataJson["audio_files"])
		objects = parse(objectsJSON: appDataJson["objects"])
		tourCategories = parse(tourCategoriesJSON: appDataJson["tour_categories"])
		let tours = parse(toursJSON: appDataJson["tours"])
		let dataSettings = parse(dataSettingsJSON: appDataJson["data"])
		let searchStrings = parse(searchStringsJSON: appDataJson["search"]["search_strings"])
		searchArtworks = parse(searchArtworks: appDataJson["search"])
        let map = parse(
            mapFloorsJSON: appDataJson["map_floors"],
            mapAnnotationsJSON: appDataJson["map_annontations"]
        )
		let messages = parse(messagesJSON: appDataJson["messages"])

		let appData = AICAppDataModel(
			generalInfo: generalInfo,
			galleries: galleries,
			objects: objects,
			audioFiles: audioFiles,
			tours: tours,
			tourCategories: tourCategories,
			map: map,
			restaurants: restaurants,
			dataSettings: dataSettings,
			searchStrings: searchStrings,
			searchArtworks: searchArtworks,
			messages: messages
		)

        cleanUpDataUsedForParsingOnly()
		return appData
	}

    private func cleanUpDataUsedForParsingOnly() {
        galleries.removeAll()
        audioFiles.removeAll()
        objects.removeAll()
        restaurants.removeAll()
        searchArtworks.removeAll()
        tourCategories.removeAll()
    }

	// MARK: General Info

	func parse(generalInfoJSON: JSON) -> AICGeneralInfoModel {
        var translations = [Common.Language: AICGeneralInfoTranslationModel]()

		do {
			let translationEng = try parseTranslation(generalInfoJSON: generalInfoJSON)
			translations[.english] = translationEng

            let translationsJSON = generalInfoJSON["translations"].array
			for translationJSON in translationsJSON! {
				do {
					let language = try getLanguageFor(translationJSON: translationJSON)
					let translation = try parseTranslation(generalInfoJSON: translationJSON)
					translations[language] = translation

                } catch ParseError.languageNotFound(let key, let data) {
                    let error = ParseError.languageNotFound(key: key, data: data)
                    logNonFatalError(error)

				} catch ParseError.translationNotFound(let key, let data) {
                    let error = ParseError.languageNotFound(key: key, data: data)
                    logNonFatalError(error)
				}
			}

			return AICGeneralInfoModel(translations: translations)

		} catch {
            let error = ParseError.generalInfoNotFound(data: generalInfoJSON.description)
            logNonFatalError(error)
        }
		return AICGeneralInfoModel(translations: translations)
	}

	func parseTranslation(generalInfoJSON: JSON) throws -> AICGeneralInfoTranslationModel {
		do {
            let museumHours = try getString(fromJSON: generalInfoJSON, forKey: "museum_hours", optional: true)
            let homeMemberPrompt = try getString(fromJSON: generalInfoJSON, forKey: "home_member_prompt_text", optional: true)
            let seeAllToursIntro = try getString(fromJSON: generalInfoJSON, forKey: "see_all_tours_intro", optional: true)
            let audioTitle = try getString(fromJSON: generalInfoJSON, forKey: "audio_title", optional: true)
            let audioSubtitle = try getString(fromJSON: generalInfoJSON, forKey: "audio_subtitle", optional: true)
            let mapTitle = try getString(fromJSON: generalInfoJSON, forKey: "map_title", optional: true)
            let mapSubtitle = try getString(fromJSON: generalInfoJSON, forKey: "map_subtitle", optional: true)
            let infoTitle = try getString(fromJSON: generalInfoJSON, forKey: "info_title", optional: true)
            let infoSubtitle = try getString(fromJSON: generalInfoJSON, forKey: "info_subtitle", optional: true)
            let giftShopsTitle = try getString(fromJSON: generalInfoJSON, forKey: "gift_shops_title", optional: true)
            let giftShopsText = try getString(fromJSON: generalInfoJSON, forKey: "gift_shops_text", optional: true)
            let membersLoungeTitle = try getString(fromJSON: generalInfoJSON, forKey: "members_lounge_title", optional: true)
            let membersLoungeText = try getString(fromJSON: generalInfoJSON, forKey: "members_lounge_text", optional: true)
            let restroomsTitle = try getString(fromJSON: generalInfoJSON, forKey: "restrooms_title", optional: true)
            let restroomsText = try getString(fromJSON: generalInfoJSON, forKey: "restrooms_text", optional: true)

            return AICGeneralInfoTranslationModel(
                museumHours: museumHours.stringByDecodingHTMLEntities,
                homeMemberPrompt: homeMemberPrompt.stringByDecodingHTMLEntities,
                seeAllToursIntro: seeAllToursIntro,
                audioTitle: audioTitle.stringByDecodingHTMLEntities,
                audioSubtitle: audioSubtitle.stringByDecodingHTMLEntities,
                mapTitle: mapTitle.stringByDecodingHTMLEntities,
                mapSubtitle: mapSubtitle.stringByDecodingHTMLEntities,
                infoTitle: infoTitle.stringByDecodingHTMLEntities,
                infoSubtitle: infoSubtitle.stringByDecodingHTMLEntities,
                giftShopsTitle: giftShopsTitle.stringByDecodingHTMLEntities,
                giftShopsText: giftShopsText.stringByDecodingHTMLEntities,
                membersLoungeTitle: membersLoungeTitle.stringByDecodingHTMLEntities,
                membersLoungeText: membersLoungeText.stringByDecodingHTMLEntities,
                restroomsTitle: restroomsTitle.stringByDecodingHTMLEntities,
                restroomsText: restroomsText.stringByDecodingHTMLEntities
            )
        } catch ParseError.missingKey(let key) {
            throw ParseError.translationNotFound(key: key, data: generalInfoJSON.description)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

	// MARK: Galleries
	private func parse(galleriesJSON: JSON) -> [AICGalleryModel] {
        var galleries = [AICGalleryModel]()

        galleriesJSON.dictionaryValue.values.forEach {
            do {
                let gallery = try parse(galleryJSON: $0)
                galleries.append(gallery)
            } catch {
                let error = ParseError.galleryNotFound(data: $0.description)
                logNonFatalError(error)
            }
        }
		return galleries
	}

	func parse(galleryJSON: JSON) throws -> AICGalleryModel {
		let nid = try getInt(fromJSON: galleryJSON, forKey: "nid")
		let title = try getString(fromJSON: galleryJSON, forKey: "title")
		let galleryId = try getInt(fromJSON: galleryJSON, forKey: "gallery_id")
		var displayTitle = title.replacingOccurrences(of: "Gallery ", with: "")
		displayTitle = displayTitle.replacingOccurrences(of: "Galleries ", with: "")

		//Check for gallery disabled
		let closed = try getBool(fromJSON: galleryJSON, forKey: "closed")
		let location = try getCLLocation2d(fromJSON: galleryJSON, forKey: "location")

		// Floor 0 comes through as LL, so parse that out
		let lowerLevel = try? getString(fromJSON: galleryJSON, forKey: "floor")
		let floorNumber: Int! = lowerLevel == "LL" ? 0 : try getInt(fromJSON: galleryJSON, forKey: "floor")

        let gallery = AICGalleryModel(
            id: nid,
            galleryId: galleryId,
            title: title,
            displayTitle: displayTitle,
            location: CoordinateWithFloor(coordinate: location, floor: floorNumber),
            closed: closed
        )

		return gallery
	}

	// MARK: Objects
	fileprivate func parse(objectsJSON: JSON) -> [AICObjectModel] {
		var objects = [AICObjectModel]()
        objectsJSON.dictionaryValue.values.forEach {
            do {
                let object = try parse(objectJSON: $0)
                objects.append(object)
            } catch ParseError.invalidObject(let message, let data) {
                let error = ParseError.invalidObject(message: message, data: data)
                logNonFatalError(error)
            } catch {
                fatalError(error.localizedDescription)
            }
        }

		return objects
	}

	fileprivate func parse(objectJSON: JSON) throws -> AICObjectModel {
		do {
            let nid = try getInt(fromJSON: objectJSON, forKey: "nid")
            let location = try getCLLocation2d(fromJSON: objectJSON, forKey: "location")
            let galleryName = try getString(fromJSON: objectJSON, forKey: "gallery_location")
            let gallery = try getGallery(forGalleryName: galleryName)
            let floorNumber = gallery.location.floor
            let title = try getString(fromJSON: objectJSON, forKey: "title")

            // Optional Fields
            let objectId = try? getInt(fromJSON: objectJSON, forKey: "id")
            let tombstone = try? getString(
                fromJSON: objectJSON,
                forKey: "artist_culture_place_delim"
            ).replacingOccurrences(of: "|", with: "\r")

            let credits = try? getString(
                fromJSON: objectJSON,
                forKey: "credit_line"
            ).stringByDecodingHTMLEntities

            let imageCopyright = try? getString(
                fromJSON: objectJSON,
                forKey: "copyright_notice"
            ).stringByDecodingHTMLEntities

            // Get images
            var image: URL! = nil
            var thumbnail: URL! = nil

            // Try to load override images
            if let imageURL = try? getURL(fromJSON: objectJSON, forKey: "image_url") {
                image = imageURL
                thumbnail = image
            } else {
                // Try loading from cms default images
                image = try getURL(fromJSON: objectJSON, forKey: "large_image_full_path")
                thumbnail = try getURL(fromJSON: objectJSON, forKey: "thumbnail_full_path")
            }

            // Get Image Crop Rects if they exist
            let thumbnailCropRect: CGRect? = try? getRect(fromJSON: objectJSON, forKey: "thumbnail_crop_v2")
            let imageCropRect: CGRect? = try? getRect(fromJSON: objectJSON, forKey: "large_image_crop_v2")

            // Ingest all audio IDs
            var audioCommentaries = [AICAudioCommentaryModel]()
            objectJSON["audio_commentary"].array?
                .forEach {
                    do {
                        let audioCommentary = try parse(audioCommentaryJSON: $0)
                        audioCommentaries.append(audioCommentary)
                    } catch ParseError.invalidAudioCommentary(let message, let data) {
                        let error = ParseError.invalidAudioCommentary(message: message, data: data)
                        logNonFatalError(error)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }

            return AICObjectModel(
                nid: nid,
                objectId: objectId,
                thumbnailUrl: thumbnail,
                thumbnailCropRect: thumbnailCropRect,
                imageUrl: image,
                imageCropRect: imageCropRect,
                title: title.stringByDecodingHTMLEntities,
                audioCommentaries: audioCommentaries,
                tombstone: tombstone,
                credits: credits,
                imageCopyright: imageCopyright,
                location: CoordinateWithFloor(
                    coordinate: location,
                    floor: floorNumber
                ),
                gallery: gallery
            )
        } catch ParseError.missingKey(let key) {
            throw ParseError.invalidObject(
                message: ParseError.missingKey(key: key).errorDescription!,
                data: objectJSON.description
            )

        } catch ParseError.badIntString(let string) {
            throw ParseError.invalidObject(
                message: ParseError.badIntString(string: string).errorDescription!,
                data: objectJSON.description
            )

        } catch ParseError.badCLLocationString(let string) {
            throw ParseError.invalidObject(
                message: ParseError.badCLLocationString(string: string).errorDescription!,
                data: objectJSON.description
            )

        } catch ParseError.galleryNameNotFound(let galleryName) {
            throw ParseError.invalidObject(
                message: ParseError.galleryNameNotFound(galleryName: galleryName).errorDescription!,
                data: objectJSON.description
            )
        } catch ParseError.badURLString(let string) {
            throw ParseError.invalidObject(
                message: ParseError.badURLString(string: string).errorDescription!,
                data: objectJSON.description
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }

	// MARK: Audio Commentary
	func parse(audioCommentaryJSON: JSON) throws -> AICAudioCommentaryModel {
		let selectorNumber = try? getInt(fromJSON: audioCommentaryJSON, forKey: "object_selector_number")

		do {
            let audioID = try getInt(fromJSON: audioCommentaryJSON, forKey: "audio")
            let audioFile = try getAudioFile(forNID: audioID)

            return AICAudioCommentaryModel(
                selectorNumber: selectorNumber,
                audioFile: audioFile
            )
        } catch ParseError.badIntString(let string) {
            throw ParseError.invalidAudioCommentary(
                message: ParseError.badIntString(string: string).errorDescription!,
                data: audioCommentaryJSON.description
            )

        } catch ParseError.audioFileNotFound(let nid) {
            throw ParseError.invalidAudioCommentary(
                message: ParseError.audioFileNotFound(nid: nid).errorDescription!,
                data: audioCommentaryJSON.description
            )

        } catch {
            fatalError(error.localizedDescription)
        }
	}

	// MARK: Audio Files

	fileprivate func parse(audioFilesJSON: JSON) -> [AICAudioFileModel] {
		var audioFiles = [AICAudioFileModel]()
        audioFilesJSON.dictionaryValue.values.forEach {
            do {
                let audioFile = try parse(audioFileJSON: $0)
                audioFiles.append(audioFile)
            } catch ParseError.badIntString(let string) {
                let error = ParseError.invalidAudioFile(
                    message: ParseError.badIntString(string: string).errorDescription!,
                    data: $0.description
                )
                logNonFatalError(error)

            } catch ParseError.missingKey(let key) {
                let error = ParseError.invalidAudioFile(
                    message: ParseError.missingKey(key: key).errorDescription!,
                    data: $0.description
                )
                logNonFatalError(error)

            } catch {
                fatalError(error.localizedDescription)
            }
        }

		return audioFiles
	}

    fileprivate func parse(audioFileJSON: JSON) throws -> AICAudioFileModel {
        let nid = try getInt(fromJSON: audioFileJSON, forKey: "nid")
        let title = try getString(fromJSON: audioFileJSON, forKey: "title")

        var translationEng = try parseTranslation(audioFileJSON: audioFileJSON)
        // default to the title of the Audio File if English track title is not provided
        if translationEng.trackTitle.isEmpty {
            translationEng.trackTitle = title
        }

        var translations = [Common.Language: AICAudioFileTranslationModel]()
        translations[.english] = translationEng

        audioFileJSON["translations"].array?.forEach {
            do {
                let language = try getLanguageFor(translationJSON: $0)
                var translation = try parseTranslation(audioFileJSON: $0)

                // default to English track title or if a Spanish/Chinese track title is not provided
                if translation.trackTitle.isEmpty {
                    translation.trackTitle = translationEng.trackTitle
                }

                translations[language] = translation
            } catch ParseError.languageNotFound(let key, let data) {
                let error = ParseError.invalidAudioFile(
                    message: ParseError.languageNotFound(key: key, data: data).errorDescription!,
                    data: audioFileJSON.description
                )
                logNonFatalError(error)

            } catch ParseError.invalidTranslation(let message, let data) {
                let error = ParseError.invalidTranslation(message: message, data: data)
                logNonFatalError(error)
            } catch {
                fatalError(error.localizedDescription)
            }
        }

        return AICAudioFileModel(
            nid: nid,
            translations: translations,
            language: .english
        )
    }

	func parseTranslation(audioFileJSON: JSON) throws -> AICAudioFileTranslationModel {
		do {
            let url = try getURL(fromJSON: audioFileJSON, forKey: "audio_file_url")!
            let transcript = try getString(fromJSON: audioFileJSON, forKey: "audio_transcript", optional: true)
            let trackTitle = try getString(fromJSON: audioFileJSON, forKey: "track_title", optional: true)

            return AICAudioFileTranslationModel(
                trackTitle: trackTitle.stringByDecodingHTMLEntities,
                url: url,
                transcript: transcript.stringByDecodingHTMLEntities
            )
        } catch ParseError.badURLString(let string) {
            throw ParseError.invalidTranslation(
                message: ParseError.badURLString(string: string).errorDescription!,
                data: audioFileJSON.description
            )

        } catch ParseError.missingKey(let key) {
            throw ParseError.invalidTranslation(
                message: ParseError.missingKey(key: key).errorDescription!,
                data: audioFileJSON.description
            )

        } catch {
            fatalError(error.localizedDescription)
        }
	}

	// MARK: Tours

	fileprivate func parse(tourCategoriesJSON: JSON) -> [AICTourCategoryModel] {
		var categories = [AICTourCategoryModel]()

        tourCategoriesJSON.dictionaryValue.values.forEach {
			do {
				let categoryID = try getString(fromJSON: $0, forKey: "category")
				var titles: [Common.Language: String] = [.english: categoryID]

				let translationsJSON = $0["translations"]
				for translationJSON in translationsJSON.arrayValue {
					let language = try getLanguageFor(translationJSON: translationJSON)
					let title = try getString(fromJSON: translationJSON, forKey: "category")
					titles[language] = title
				}

				let category = AICTourCategoryModel(
					id: categoryID,
					title: titles
				)
				categories.append(category)

            } catch ParseError.languageNotFound(let key, let data) {
                let error = ParseError.invalidTourCategory(
                    message: ParseError.languageNotFound(key: key, data: data).errorDescription!,
                    data: $0.description
                )
                logNonFatalError(error)

			} catch ParseError.missingKey(let key) {
                let error = ParseError.invalidTourCategory(
                    message: ParseError.missingKey(key: key).errorDescription!,
                    data: $0.description
                )
                logNonFatalError(error)
            } catch {
                fatalError(error.localizedDescription)
            }
		}

		return categories
	}

	fileprivate func parse(toursJSON: JSON) -> [AICTourModel] {
		var tours = [AICTourModel]()

		for tourJSON in toursJSON.arrayValue {
			do {
                let tour = try parse(tourJSON: tourJSON)
                tours.append(tour)

            } catch ParseError.invalidTour(let message, let data) {
                let error = ParseError.invalidTour(message: message, data: data)
                logNonFatalError(error)
            } catch {
                fatalError(error.localizedDescription)
            }
		}
		return tours
	}

	fileprivate func parse(tourJSON: JSON) throws -> AICTourModel {
		do {
            let nid = try getInt(fromJSON: tourJSON, forKey: "nid")
            let imageUrl: URL = try getURL(fromJSON: tourJSON, forKey: "image_url")!
            let audioFileID = try getInt(fromJSON: tourJSON, forKey: "tour_audio")
            let audioFile = try getAudioFile(forNID: audioFileID)
            let order = try getInt(fromJSON: tourJSON, forKey: "weight")

            // Selector number (optional)
            let selectorNumber = try? getInt(fromJSON: tourJSON, forKey: "selector_number")
            let audioCommentary = AICAudioCommentaryModel(selectorNumber: selectorNumber, audioFile: audioFile)

            // Category
            var category: AICTourCategoryModel?
            let categoryID = try getString(fromJSON: tourJSON, forKey: "category", optional: true)
            if categoryID.isEmpty == false {
                for tourCategory in self.tourCategories {
                    if tourCategory.id == categoryID {
                        category = tourCategory
                    }
                }
            }

            // Create Stops
            guard let stopsData = tourJSON["tour_stops"].array else {
                throw ParseError.invalidTour(
                    message: ParseError.tourStopsNotFound(tourId: nid).errorDescription!,
                    data: tourJSON.description
                )
            }

            var stops: [AICTourStopModel] = []
            var stop = 0
            for stopData in stopsData {
                do {
                    let order = try getInt(fromJSON: stopData, forKey: "sort")
                    let objectID = try getInt(fromJSON: stopData, forKey: "object")
                    let object = try getObject(forNID: objectID)
                    let audioFileID = try getInt(fromJSON: stopData, forKey: "audio_id")
                    let audioFile = try getAudioFile(forNID: audioFileID)

                    // Selector number is optional
                    var audioBumper: AICAudioFileModel?
                    do {
                        let audioBumperID = try getInt(fromJSON: stopData, forKey: "audio_bumper")
                        audioBumper = try getAudioFile(forNID: audioBumperID)
                    } catch {
                        audioBumper = nil
                    }

                    let stop = AICTourStopModel(
                        order: order,
                        object: object,
                        audio: audioFile,
                        audioBumper: audioBumper
                    )

                    stops.append(stop)

                } catch ParseError.badIntString(let string) {
                    let error = ParseError.invalidTour(
                        message: ParseError.badIntString(string: string).errorDescription!,
                        data: tourJSON.description
                    )
                    logNonFatalError(error)

                } catch ParseError.objectNotFound(let nid) {
                    let error = ParseError.invalidTour(
                        message: ParseError.objectNotFound(nid: nid).errorDescription!,
                        data: tourJSON.description
                    )
                    logNonFatalError(error)

                } catch ParseError.audioFileNotFound(let nid) {
                    let error = ParseError.invalidTour(
                        message: ParseError.audioFileNotFound(nid: nid).errorDescription!,
                        data: tourJSON.description
                    )

                    logNonFatalError(error)
                } catch {
                    fatalError(error.localizedDescription)
                }

                stop += 1
            }

            if stops.count == 0 {
                throw ParseError.invalidTour(
                    message: ParseError.noValidTourStops.errorDescription!,
                    data: tourJSON.description
                )
            }

            let location = try getCLLocation2d(fromJSON: tourJSON, forKey: "location")
            var floor: Int?
            do {
                floor = try getInt(fromJSON: tourJSON, forKey: "floor")
            } catch {
                floor = stops.first!.object.location.floor
            }

            let coordinate = CoordinateWithFloor(coordinate: location, floor: floor!)
            var translations: [Common.Language: AICTourTranslationModel] = [:]
            let translationsJSON = tourJSON["translations"].array

            let translationEng = try parseTranslation(tourJSON: tourJSON, imageUrl: imageUrl, audioFile: audioFile)
            translations[.english] = translationEng

            for translationJSON in translationsJSON! {
                do {
                    let language = try getLanguageFor(translationJSON: translationJSON)
                    let translation = try parseTranslation(tourJSON: translationJSON, imageUrl: imageUrl, audioFile: audioFile)
                    translations[language] = translation

                } catch ParseError.languageNotFound(let key, let data) {
                    let error = ParseError.languageNotFound(key: key, data: data)
                    logNonFatalError(error)

                } catch ParseError.missingKey(let key) {
                    let error = ParseError.invalidTour(
                        message: ParseError.missingKey(key: key).errorDescription!,
                        data: tourJSON.description
                    )
                    logNonFatalError(error)

                } catch {
                    fatalError(error.localizedDescription)
                }
            }

            return AICTourModel(
                nid: nid,
                audioCommentary: audioCommentary,
                order: order,
                category: category,
                imageUrl: imageUrl,
                location: coordinate,
                allStops: stops,
                translations: translations,
                language: .english
            )

        } catch ParseError.badURLString(let string) {
            throw ParseError.invalidTour(
                message: ParseError.badURLString(string: string).errorDescription!,
                data: tourJSON.description
            )

        } catch ParseError.missingKey(let key) {
            throw ParseError.invalidTour(
                message: ParseError.missingKey(key: key).errorDescription!,
                data: tourJSON.description
            )
        } catch ParseError.badIntString(let string) {
            throw ParseError.invalidTour(
                message: ParseError.badIntString(string: string).errorDescription!,
                data: tourJSON.description
            )
        } catch ParseError.audioFileNotFound(let nid) {
            throw ParseError.invalidTour(
                message: ParseError.audioFileNotFound(nid: nid).errorDescription!,
                data: tourJSON.description
            )
        } catch ParseError.badCLLocationString(let string) {
            throw ParseError.invalidTour(
                message: ParseError.badCLLocationString(string: string).errorDescription!,
                data: tourJSON.description
            )
        } catch ParseError.invalidTour(let message, let data) {
            throw ParseError.invalidTour(message: message, data: data)
        }

        catch {
            fatalError(error.localizedDescription)
        }
	}

	func parseTranslation(tourJSON: JSON, imageUrl: URL, audioFile: AICAudioFileModel) throws -> AICTourTranslationModel {
		let title = try getString(fromJSON: tourJSON, forKey: "title")
		let shortDescription = try getString(fromJSON: tourJSON, forKey: "description")
		var longDescription = try getString(fromJSON: tourJSON, forKey: "intro")
		longDescription = "\(shortDescription)\r\r\(longDescription)"

		let durationInMinutes = try? getString(fromJSON: tourJSON, forKey: "tour_duration")

        return AICTourTranslationModel(
            title: title.stringByDecodingHTMLEntities,
            shortDescription: shortDescription.stringByDecodingHTMLEntities,
            longDescription: longDescription.stringByDecodingHTMLEntities,
            durationInMinutes: durationInMinutes,
            credits: "Copyright 2016 Art Institue of Chicago"
        )
	}

	// MARK: Map
	func parseMapFloorsURLs(fromAppData: Data) -> [URL] {
		var result: [URL] = []

		do {
			let appDataJSON = try JSON(data: fromAppData)
			let mapFloorsJSON = appDataJSON["map_floors"]

			for floorNumber in 0..<Common.Map.totalFloors {
                let mapFloorKey = "map_floor\(floorNumber)"
				let mapFloorJSON = mapFloorsJSON[mapFloorKey]
				let floorPdfURL: URL = try getURL(fromJSON: mapFloorJSON, forKey: "floor_plan")!
				result.append(floorPdfURL)
			}
		} catch {

		}

		return result
	}

	func parse(mapFloorsJSON: JSON, mapAnnotationsJSON: JSON) -> AICMapModel {
		do {
			var floorOverlays: [FloorplanOverlay] = []
			var floorGalleryAnnotations: [Int: [MapTextAnnotation]] = [:]
			var floorObjectAnnotations: [Int: [MapObjectAnnotation]] = [
				0: [MapObjectAnnotation](),
				1: [MapObjectAnnotation](),
				2: [MapObjectAnnotation](),
				3: [MapObjectAnnotation]()
			]

			// Floors
			for floorNumber in 0..<Common.Map.totalFloors {
                let mapFloorKey = "map_floor\(floorNumber)"
				let mapFloorJSON = mapFloorsJSON[mapFloorKey]

				let floorPdfURL: URL = AppDataManager.sharedInstance.mapFloorURLs[floorNumber]!
				let anchorPixel1 = try getPoint(fromJSON: mapFloorJSON, forKey: "anchor_pixel_1")
				let anchorPixel2 = try getPoint(fromJSON: mapFloorJSON, forKey: "anchor_pixel_2")
				let anchorLocation1 = try getCLLocation2d(fromJSON: mapFloorJSON, forKey: "anchor_location_1")
				let anchorLocation2 = try getCLLocation2d(fromJSON: mapFloorJSON, forKey: "anchor_location_2")
				let anchor1 = GeoAnchor(latitudeLongitudeCoordinate: anchorLocation1, pdfPoint: anchorPixel1)
				let anchor2 = GeoAnchor(latitudeLongitudeCoordinate: anchorLocation2, pdfPoint: anchorPixel2)

                let floorOverlay = FloorplanOverlay(
                    floorplanUrl: floorPdfURL,
                    withPDFBox: CGPDFBox.trimBox,
                    andAnchors: GeoAnchorPair(fromAnchor: anchor1, toAnchor: anchor2)
                )
				floorOverlays.append(floorOverlay)

				// Galleries
				let galleryAnnotations = getGalleryAnnotations(forFloorNumber: floorNumber)
				floorGalleryAnnotations[floorNumber] = galleryAnnotations

				// Artworks
				let floorObjects = self.objects.filter({ $0.location.floor == floorNumber })
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
			var floorAmenityAnnotations: [Int: [MapAmenityAnnotation]] = [
				0: [MapAmenityAnnotation](),
				1: [MapAmenityAnnotation](),
				2: [MapAmenityAnnotation](),
				3: [MapAmenityAnnotation]()
			]
			var floorDepartmentAnnotations: [Int: [MapDepartmentAnnotation]] = [
				0: [MapDepartmentAnnotation](),
				1: [MapDepartmentAnnotation](),
				2: [MapDepartmentAnnotation](),
				3: [MapDepartmentAnnotation]()
			]
			var floorSpaceAnnotations: [Int: [MapTextAnnotation]] = [
				0: [MapTextAnnotation](),
				1: [MapTextAnnotation](),
				2: [MapTextAnnotation](),
				3: [MapTextAnnotation]()
			]
            mapAnnotationsJSON.dictionaryValue.values.forEach { annotationJSON in
				do {
					let floorNumber = try? getInt(fromJSON: annotationJSON, forKey: "floor")
					let type = try getString(fromJSON: annotationJSON, forKey: "annotation_type")

					if type == "Amenity" && floorNumber != nil {
						let amenityAnnotation = try parse(amenityAnnotationJSON: annotationJSON, floorNumber: floorNumber!)
						floorAmenityAnnotations[floorNumber!]!.append(amenityAnnotation)
					} else if type == "Text" {
						let textType = try getString(fromJSON: annotationJSON, forKey: "text_type")
						if textType == MapTextAnnotation.AnnotationType.Space.rawValue && floorNumber != nil {
							let textAnnotation = try parse(textAnnotationJSON: annotationJSON, type: MapTextAnnotation.AnnotationType.Space)
							floorSpaceAnnotations[floorNumber!]!.append(textAnnotation)
						} else if textType == MapTextAnnotation.AnnotationType.Landmark.rawValue {
							let textAnnotation = try parse(textAnnotationJSON: annotationJSON, type: MapTextAnnotation.AnnotationType.Landmark)
							landmarkAnnotations.append(textAnnotation)
						} else if textType == MapTextAnnotation.AnnotationType.Garden.rawValue {
							let textAnnotation = try parse(textAnnotationJSON: annotationJSON, type: MapTextAnnotation.AnnotationType.Garden)
							gardenAnnotations.append(textAnnotation)
						}
					} else if type == "Department" && floorNumber != nil {
						let departmentAnnotation = try parse(departmentAnnotationJSON: annotationJSON)
						floorDepartmentAnnotations[floorNumber!]!.append(departmentAnnotation)
					}

					// Restaurant Model
					if type == "Amenity" && floorNumber != nil {
						let amenityType = try getString(fromJSON: annotationJSON, forKey: "amenity_type")
						if amenityType == "Dining" {
							let restaurant = try parse(restaurantJSON: annotationJSON, floorNumber: floorNumber!)
							self.restaurants.append(restaurant)
						}
					}
				} catch ParseError.missingKey(let key) {
                    let error = ParseError.invalidMapAnnotation(
                        message: ParseError.missingKey(key: key).errorDescription!,
                        data: annotationJSON.description
                    )
                    logNonFatalError(error)

                } catch ParseError.badIntString(let string) {
                    let error = ParseError.invalidMapAnnotation(
                        message: ParseError.badIntString(string: string).errorDescription!,
                        data: annotationJSON.description
                    )
                    logNonFatalError(error)

                } catch ParseError.badCLLocationString(let string) {
                    let error = ParseError.invalidMapAnnotation(
                        message: ParseError.badCLLocationString(string: string).errorDescription!,
                        data: annotationJSON.description
                    )
                    logNonFatalError(error)

                } catch ParseError.badURLString(let string) {
                    let error = ParseError.invalidMapAnnotation(
                        message: ParseError.badURLString(string: string).errorDescription!,
                        data: annotationJSON.description
                    )
                    logNonFatalError(error)

                } catch {
                    fatalError(error.localizedDescription)
                }
			}

			// Far Objects
			var floorFarObjectAnnotations: [Int: [MapObjectAnnotation]] = [
				0: [MapObjectAnnotation](),
				1: [MapObjectAnnotation](),
				2: [MapObjectAnnotation](),
				3: [MapObjectAnnotation]()
			]

			// Add object visible from far to each floor
			for floorNumber in 0..<Common.Map.totalFloors {
				// first add all artworks from the search
				for artwork in self.searchArtworks {
					if artwork.location.floor == floorNumber {
						if let objectAnnotation = floorObjectAnnotations[floorNumber]?.filter({ $0.nid == artwork.nid }).first as? MapObjectAnnotation {
							floorFarObjectAnnotations[floorNumber]!.append(objectAnnotation)
						}
					}
				}
			}

			// Lions

            let leftLion = MapImageAnnotation(
                coordinate: Common.EntranceLionStatue.left.coordinate,
                image: UIImage(named: Common.EntranceLionStatue.left.imageName)!,
                identifier: Common.EntranceLionStatue.left.identifier
            )
            let rightLion = MapImageAnnotation(
                coordinate: Common.EntranceLionStatue.right.coordinate,
                image: UIImage(named: Common.EntranceLionStatue.right.imageName)!,
                identifier: Common.EntranceLionStatue.right.identifier
            )
			imageAnnotations.append(leftLion)
			imageAnnotations.append(rightLion)

			var floors: [AICMapFloorModel] = []
			for floorNumber in 0..<Common.Map.totalFloors {
                let floor = AICMapFloorModel(
                    floorNumber: floorNumber,
                    overlay: floorOverlays[floorNumber],
                    objects: floorObjectAnnotations[floorNumber]!,
                    farObjects: floorFarObjectAnnotations[floorNumber]!,
                    amenities: floorAmenityAnnotations[floorNumber]!,
                    departments: floorDepartmentAnnotations[floorNumber]!,
                    galleries: floorGalleryAnnotations[floorNumber]!,
                    spaces: floorSpaceAnnotations[floorNumber]!
                )
                floors.append(floor)
			}

            return AICMapModel(
                imageAnnotations: imageAnnotations,
                landmarkAnnotations: landmarkAnnotations,
                gardenAnnotations: gardenAnnotations,
                floors: floors
            )

		} catch ParseError.badPointString(let string) {
            let error = ParseError.invalidMapFloor(
                message: ParseError.badPointString(string: string).errorDescription!,
                data: mapFloorsJSON.description
            )
            logNonFatalError(error)
		} catch ParseError.badCLLocationString(let string) {
            let error = ParseError.invalidMapFloor(
                message: ParseError.badCLLocationString(string: string).errorDescription!,
                data: mapFloorsJSON.description
            )
            logNonFatalError(error)
        } catch {
            fatalError(error.localizedDescription)
        }

        return AICMapModel(
            imageAnnotations: [MapImageAnnotation](),
            landmarkAnnotations: [MapTextAnnotation](),
            gardenAnnotations: [MapTextAnnotation](),
            floors: [AICMapFloorModel]()
        )
	}

	// Gallery annotations
	private func getGalleryAnnotations(forFloorNumber floorNumber: Int) -> [MapTextAnnotation] {
		var galleryAnnotations: [MapTextAnnotation] = []
		let galleriesForThisFloor = self.galleries.filter({ $0.location.floor == floorNumber })
		for gallery in galleriesForThisFloor {
            galleryAnnotations.append(
                MapTextAnnotation(
                    coordinate: gallery.location.coordinate,
                    text: gallery.displayTitle,
                    type: MapTextAnnotation.AnnotationType.Gallery
                )
            )
		}

		return galleryAnnotations
	}

	// Amenity Annotations
	private func parse(amenityAnnotationJSON: JSON, floorNumber: Int) throws -> MapAmenityAnnotation {
		let nid = try getInt(fromJSON: amenityAnnotationJSON, forKey: "nid")
		let coordinate = try getCLLocation2d(fromJSON: amenityAnnotationJSON, forKey: "location")
		let typeString = try getString(fromJSON: amenityAnnotationJSON, forKey: "amenity_type")
		if let type: MapAmenityAnnotationType = MapAmenityAnnotationType(rawValue: typeString) {
			return MapAmenityAnnotation(nid: nid, coordinate: coordinate, floor: floorNumber, type: type)
		}

		throw ParseError.badBoolString(string: typeString)
	}

	// Department Annotations
	private func parse(departmentAnnotationJSON: JSON) throws -> MapDepartmentAnnotation {
		let coordinate = try getCLLocation2d(fromJSON: departmentAnnotationJSON, forKey: "location")
		let title = try getString(fromJSON: departmentAnnotationJSON, forKey: "label")
		let imageUrl = try getURL(fromJSON: departmentAnnotationJSON, forKey: "image_url")!

		return MapDepartmentAnnotation(coordinate: coordinate, title: title, imageUrl: imageUrl)
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

	// MARK: Restaurants

	func parse(restaurantJSON: JSON, floorNumber: Int) throws -> AICRestaurantModel {
		let nid = try getInt(fromJSON: restaurantJSON, forKey: "nid")
		let title = try getString(fromJSON: restaurantJSON, forKey: "label", optional: true)
		let description = try getString(fromJSON: restaurantJSON, forKey: "description", optional: true)
		let coreLocation = try getCLLocation2d(fromJSON: restaurantJSON, forKey: "location")
		let location = CoordinateWithFloor(coordinate: coreLocation, floor: floorNumber)
		let imageUrl: URL? = try getURL(fromJSON: restaurantJSON, forKey: "image_url", optional: true)

        return AICRestaurantModel(
            nid: nid,
            title: title,
            imageUrl: imageUrl,
            description: description,
            location: location
        )
	}

	// MARK: Data Settings

	func parse(dataSettingsJSON: JSON) -> [Common.DataSetting: String] {
		var dataSettings = [Common.DataSetting: String]()
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
			dataSettings[.multiSearchEndpoint] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.multiSearchEndpoint.rawValue)
			dataSettings[.websiteUrl] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.websiteUrl.rawValue)
			dataSettings[.membershipUrl] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.membershipUrl.rawValue)
			dataSettings[.ticketsUrl] = try getString(fromJSON: dataSettingsJSON, forKey: Common.DataSetting.ticketsUrl.rawValue)

		} catch ParseError.missingKey(let key) {
            let error = ParseError.invalidDataSetting(
                message: ParseError.missingKey(key: key).errorDescription!,
                data: dataSettingsJSON.description
            )
            logNonFatalError(error)

        } catch {
            fatalError(error.localizedDescription)
        }
		return dataSettings
	}

	// MARK: Exhibitions

	func parse(exhibitionsData data: Data) -> [AICExhibitionModel] {
		var exhibitionItems = [AICExhibitionModel]()

		let json = try! JSON(data: data)
		let dataJSON: JSON = json["data"]
        dataJSON.arrayValue.forEach {
			do {
                let exhibitionItem = try parse(exhibitionJSON: $0)
                exhibitionItems.append(exhibitionItem)

            } catch ParseError.invalidExhibition(let message, let data) {
                let error = ParseError.invalidExhibition(message: message, data: data)
                logNonFatalError(error)
            } catch {
                fatalError(error.localizedDescription)
            }
		}

		return exhibitionItems
	}

	private func parse(exhibitionJSON: JSON) throws -> AICExhibitionModel {
		do {
            let id = try getInt(fromJSON: exhibitionJSON, forKey: "id")
            let title = try getString(fromJSON: exhibitionJSON, forKey: "title")
            let description = try getString(fromJSON: exhibitionJSON, forKey: "short_description", optional: true)

            // Image
            var imageURL: URL?
            let exhibitionUrl = try getString(fromJSON: exhibitionJSON, forKey: "image_url")
            let fullExhibitionUrl: String = exhibitionUrl + "&w=600"
            imageURL = URL(string: fullExhibitionUrl)

            // optional location
            var galleryId: Int?
            var location: CoordinateWithFloor?
            do {
                let id = try getInt(fromJSON: exhibitionJSON, forKey: "gallery_id")
                let gallery = try getGallery(forGalleryId: id)
                galleryId = id
                location = gallery.location
            } catch {}

            // Get date exibition ends
            let startDateString = try getString(fromJSON: exhibitionJSON, forKey: "aic_start_at")
            let endDateString = try getString(fromJSON: exhibitionJSON, forKey: "aic_end_at")

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            guard let startDate = dateFormatter.date(from: startDateString) else {
                throw ParseError.invalidExhibition(
                    message: ParseError.invalidDateFormat(dateString: startDateString).errorDescription!,
                    data: exhibitionJSON.description
                )
            }
            guard let endDate = dateFormatter.date(from: endDateString) else {
                throw ParseError.invalidExhibition(
                    message: ParseError.invalidDateFormat(dateString: endDateString).errorDescription!,
                    data: exhibitionJSON.description
                )
            }

            // Return news item
            return AICExhibitionModel(
                id: id,
                title: title.stringByDecodingHTMLEntities,
                shortDescription: description.stringByDecodingHTMLEntities,
                imageUrl: imageURL,
                startDate: startDate,
                endDate: endDate,
                galleryId: galleryId,
                location: location
            )
        } catch ParseError.missingKey(let key) {
            throw ParseError.invalidExhibition(
                message: ParseError.missingKey(key: key).errorDescription!,
                data: exhibitionJSON.description
            )

        } catch ParseError.badIntString(let string) {
            throw ParseError.invalidExhibition(
                message: ParseError.badIntString(string: string).errorDescription!,
                data: exhibitionJSON.description
            )
        } catch {
            fatalError(error.localizedDescription)
        }
	}

	// MARK: Events

	func parse(eventsData data: Data) -> [AICEventModel] {
		var eventItems = [AICEventModel]()

        let json = try! JSON(data: data)
        let dataJson: JSON = json["data"]
        dataJson.arrayValue.forEach {
			do {
                let eventItem = try parse(eventJson: $0)
                eventItems.append(eventItem)
            } catch ParseError.invalidEvent(let message, let data) {
                let error = ParseError.invalidEvent(message: message, data: data)
                logNonFatalError(error)
            } catch {
                fatalError(error.localizedDescription)
            }
		}

		return eventItems
	}

	func parse(eventJson: JSON) throws -> AICEventModel {
        do {
            let eventId = try getString(fromJSON: eventJson, forKey: "id")
            let title = try getString(fromJSON: eventJson, forKey: "title")
            let longDescription = try getString(fromJSON: eventJson, forKey: "description")
            let shortDescription = try getString(fromJSON: eventJson, forKey: "short_description", optional: true)
            let imageUrl: URL = try getURL(fromJSON: eventJson, forKey: "image_url")!
            let eventUrl = try getURL(fromJSON: eventJson, forKey: "button_url", optional: true)
            let buttonText = try getString(fromJSON: eventJson, forKey: "button_text", optional: true)
            let locationText = try getString(fromJSON: eventJson, forKey: "location", optional: true)

            // Get date exibition ends
            let startDateString = try getString(fromJSON: eventJson, forKey: "start_at")
            let endDateString = try getString(fromJSON: eventJson, forKey: "end_at")

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            guard let startDate = dateFormatter.date(from: startDateString) else {
                throw ParseError.invalidEvent(
                    message: ParseError.invalidDateFormat(dateString: startDateString).errorDescription!,
                    data: eventJson.description
                )
            }
            guard let endDate = dateFormatter.date(from: endDateString) else {
                throw ParseError.invalidEvent(
                    message: ParseError.invalidDateFormat(dateString: endDateString).errorDescription!,
                    data: eventJson.description
                )
            }

            // Return news item
            return AICEventModel(
                eventId: eventId,
                title: title.stringByDecodingHTMLEntities,
                shortDescription: shortDescription.stringByDecodingHTMLEntities,
                longDescription: longDescription.stringByDecodingHTMLEntities,
                imageUrl: imageUrl,
                locationText: locationText,
                startDate: startDate,
                endDate: endDate,
                eventUrl: eventUrl,
                buttonText: buttonText
            )
        } catch ParseError.missingKey(let key) {
            throw ParseError.invalidEvent(
                message: ParseError.missingKey(key: key).errorDescription!,
                data: eventJson.description
            )
        } catch ParseError.badURLString(let string) {
            throw ParseError.invalidEvent(
                message: ParseError.badURLString(string: string).errorDescription!,
                data: eventJson.description
            )
        } catch {
            fatalError(error.localizedDescription)
        }
	}

	// MARK: Search

	func parse(searchStringsJSON: JSON) -> [String] {
		var searchStrings = [String]()

        searchStringsJSON.dictionaryValue.values.forEach {
            let searchString = $0.string!
            searchStrings.append(searchString)
		}

		return searchStrings
	}

	func parse(searchArtworks inSearchJSON: JSON) -> [AICObjectModel] {
		var artworks = [AICObjectModel]()

		do {
            let artworkIDs = try getIntArray(fromJSON: inSearchJSON, forArrayKey: "search_objects")
            for artworkID in artworkIDs {
                let artwork = try getObject(forNID: artworkID)
                artworks.append(artwork)
            }
        } catch ParseError.missingKey(let key) {
            let error = ParseError.invalidSearchArtworks(
                message: ParseError.missingKey(key: key).errorDescription!,
                data: inSearchJSON.description
            )
            logNonFatalError(error)

        } catch ParseError.badIntString(let string) {
            let error = ParseError.invalidSearchArtworks(
                message: ParseError.badIntString(string: string).errorDescription!,
                data: inSearchJSON.description
            )
            logNonFatalError(error)

        } catch ParseError.objectNotFound(let nid) {
            let error = ParseError.invalidSearchArtworks(
                message: ParseError.objectNotFound(nid: nid).errorDescription!,
                data: inSearchJSON.description
            )
            logNonFatalError(error)

        } catch {
            fatalError(error.localizedDescription)
        }

		return artworks
	}

	func parse(autocompleteData: Data) -> [String] {
		var autocompleteStrings = [String]()

		do {
            let json = try JSON(data: autocompleteData)
            if let jsonArray = json.array {
                for index in 0..<jsonArray.count {
                    let autocompleteString = jsonArray[index].string
                    autocompleteStrings.append(autocompleteString!)
                }
            }
		} catch let error {
            let localError = ParseError.invalidSearchAutocomplete(
                message: error.localizedDescription,
                data: autocompleteData.description
            )
            logNonFatalError(localError)
		}

		return autocompleteStrings
	}

	func parse(searchContent data: Data) -> [Common.Search.Filter: [Any]] {
		var results: [Common.Search.Filter: [Any]] = [:]

		do {
            let json = try JSON(data: data)
            if let jsonArray = json.array {
                for index in 0...jsonArray.count-1 {
                    if index == 0 {
                        results[.artworks] = parse(searchedArtworksJSON: jsonArray[index])
                    } else if index == 1 {
                        results[.tours] = parse(searchedToursJSON: jsonArray[index])
                    } else if index == 2 {
                        results[.exhibitions] = parse(searchedExhibitionsJSON: jsonArray[index])
                    }
                }
            }
		} catch let error {
            let localError = ParseError.invalidSearchContent(
                message: error.localizedDescription,
                data: data.description
            )
            logNonFatalError(localError)
        }

		return results
	}

	func parse(searchedArtworksJSON: JSON) -> [AICSearchedArtworkModel] {
		var searchedArtworks = [AICSearchedArtworkModel]()

		let dataJSON: JSON = searchedArtworksJSON["data"]
        dataJSON.arrayValue.forEach { resultJSON in
            do {
                let artworkId = try getInt(fromJSON: resultJSON, forKey: "id")
                let isOnView = try getBool(fromJSON: resultJSON, forKey: "is_on_view")

                // If this artwork is also in the mobile CMS,
                // we get the data correspondent data from the AICObjectModel
                if let object = AppDataManager.sharedInstance.getObject(forObjectID: artworkId) {
                    var artistDisplay = ""
                    if let tombstone = object.tombstone {
                        artistDisplay = tombstone
                    }
                    let searchedArtwork = AICSearchedArtworkModel(
                        artworkId: artworkId,
                        audioObject: object,
                        title: object.title,
                        thumbnailUrl: object.thumbnailUrl,
                        imageUrl: object.imageUrl,
                        artistDisplay: artistDisplay,
                        location: object.location,
                        gallery: object.gallery
                    )
                    searchedArtworks.append(searchedArtwork)
                }
                // Otherwise we parse from the data api
                else if isOnView {
                    let title: String = try getString(fromJSON: resultJSON, forKey: "title")
                    let artistDisplay: String = try getString(fromJSON: resultJSON, forKey: "artist_display")

                    // optional
                    var thumbnailUrl: URL?
                    var imageUrl: URL?
                    do {
                        let imageId = try getString(fromJSON: resultJSON, forKey: "image_id")
                        let iiifString = AppDataManager.sharedInstance.app.dataSettings[.imageServerUrl]! + "/" + imageId
                        let thumbnailString: String = iiifString + "/full/!200,200/0/default.jpg"
                        let imageString: String = iiifString + "/full/!800,800/0/default.jpg"
                        thumbnailUrl = URL(string: thumbnailString)
                        imageUrl = URL(string: imageString)
                    } catch {}

                    if thumbnailUrl == nil {
                        thumbnailUrl = URL(string: "https://aic-mobile-tours.artic.edu/sites/default/files/object-images/AIC_ImagePlaceholder_25.png")!
                    }
                    if imageUrl == nil {
                        imageUrl = URL(string: "https://aic-mobile-tours.artic.edu/sites/default/files/object-images/AIC_ImagePlaceholder_25.png")!
                    }

                    let galleryId = try getInt(fromJSON: resultJSON, forKey: "gallery_id")
                    let gallery = try getGallery(forGalleryId: galleryId)

                    var location: CoordinateWithFloor?
                    do {
                        let coreLocation = try getCLLocation2d(fromJSON: resultJSON, forKey: "latlon")
                        let floorNumber = gallery.location.floor
                        location = CoordinateWithFloor(coordinate: coreLocation, floor: floorNumber)
                    } catch {}

                    if location == nil {
                        location = gallery.location
                    }

                    let searchedArtwork = AICSearchedArtworkModel(
                        artworkId: artworkId,
                        audioObject: nil,
                        title: title.stringByDecodingHTMLEntities,
                        thumbnailUrl: thumbnailUrl!,
                        imageUrl: imageUrl!,
                        artistDisplay: artistDisplay.stringByDecodingHTMLEntities,
                        location: location!,
                        gallery: gallery
                    )
                    searchedArtworks.append(searchedArtwork)
                }
            } catch ParseError.missingKey(let key) {
                let error = ParseError.invalidSearchContent(
                    message: ParseError.missingKey(key: key).errorDescription!,
                    data: searchedArtworksJSON.description
                )
                logNonFatalError(error)

            } catch ParseError.badIntString(let string) {
                let error = ParseError.invalidSearchContent(
                    message: ParseError.badIntString(string: string).errorDescription!,
                    data: searchedArtworksJSON.description
                )
                logNonFatalError(error)

            } catch ParseError.badBoolString(let string) {
                let error = ParseError.invalidSearchContent(
                    message: ParseError.badBoolString(string: string).errorDescription!,
                    data: searchedArtworksJSON.description
                )
                logNonFatalError(error)

            } catch ParseError.galleryIdNotFound(let galleryId) {
                let error = ParseError.invalidSearchContent(
                    message: ParseError.galleryIdNotFound(galleryId: galleryId).errorDescription!,
                    data: searchedArtworksJSON.description
                )
                logNonFatalError(error)

            } catch ParseError.badCLLocationString(let string) {
                let error = ParseError.invalidSearchContent(
                    message: ParseError.badCLLocationString(string: string).errorDescription!,
                    data: searchedArtworksJSON.description
                )
                logNonFatalError(error)
            }
            catch {
                fatalError(error.localizedDescription)
            }
		}

		return searchedArtworks
	}

	func parse(searchedToursJSON: JSON) -> [AICTourModel] {
		var searchedTours = [AICTourModel]()
		do {
            let dataJson: JSON = searchedToursJSON["data"]
            for resultson: JSON in dataJson.arrayValue {
                // Since Tours are stored in the CMS, we just need to match ids with the tour models we already parsed on app launch
                let tourId = try getInt(fromJSON: resultson, forKey: "id")
                if let tour = AppDataManager.sharedInstance.getTour(forID: tourId) {
                    searchedTours.append(tour)
                }
            }
		} catch ParseError.missingKey(let key) {
            let error = ParseError.invalidSearchTours(
                message: ParseError.missingKey(key: key).errorDescription!,
                data: searchedToursJSON.description
            )
            logNonFatalError(error)

        } catch ParseError.badIntString(let string) {
            let error = ParseError.invalidSearchTours(
                message: ParseError.badIntString(string: string).errorDescription!,
                data: searchedToursJSON.description
            )
            logNonFatalError(error)

        } catch {
            fatalError(error.localizedDescription)
        }
		return searchedTours
	}

	func parse(searchedExhibitionsJSON: JSON) -> [AICExhibitionModel] {
		var searchedExhibitions: [AICExhibitionModel] = []

		let dataJSON: JSON = searchedExhibitionsJSON["data"]
		for exhibitionJSON: JSON in dataJSON.arrayValue {
			do {
                let exhibition = try parse(exhibitionJSON: exhibitionJSON)
                searchedExhibitions.append(exhibition)

			} catch ParseError.invalidExhibition(let message, let data) {
                let error = ParseError.invalidSearchExhibitions(message: message, data: data)
                logNonFatalError(error)

            } catch {
                fatalError(error.localizedDescription)
            }
		}

		return searchedExhibitions
	}

	// MARK: Messages

	private func parse(messagesJSON: JSON) -> [AICMessageModel] {
		var messages: [AICMessageModel] = []

		for (messageNid, messageJSON) in messagesJSON {
			do {
                let message = try parse(messageJSON: messageJSON, messageNid: messageNid)
                messages.append(message)
            } catch ParseError.invalidMessage(let message, let data) {
                let error = ParseError.invalidMessage(message: message, data: data)
                logNonFatalError(error)
            } catch {
                fatalError(error.localizedDescription)
            }
		}

		return messages
	}

	private func parse(messageJSON: JSON, messageNid: String) throws -> AICMessageModel {
        do {
            let messageTypeString = try getString(fromJSON: messageJSON, forKey: "message_type")
            let messageType: AICMessageModel.MessageType
            switch messageTypeString {
            case "launch":
                messageType = .launch(isPersistent: try getBool(fromJSON: messageJSON, forKey: "persistent"))
            case "tour_exit":
                messageType = .tourExit(
                    isPersistent: try getBool(fromJSON: messageJSON, forKey: "persistent"),
                    tourNid: try getString(fromJSON: messageJSON, forKey: "tour_exit")
                )
            case "member_expiration":
                messageType = .memberExpiration(
                    isPersistent: try getBool(fromJSON: messageJSON, forKey: "persistent"),
                    threshold: try getInt(fromJSON: messageJSON, forKey: "expiration_threshold")
                )
            default:
                throw ParseError.objectParseFailure
            }

            var translations = [Common.Language: AICMessageTranslationModel]()
            translations[.english] = try parseTranslation(messageJSON: messageJSON)

            for translationJSON in messageJSON["translations"].array ?? [] {
                do {
                    let language = try getLanguageFor(translationJSON: translationJSON)
                    let translation = try parseTranslation(messageJSON: translationJSON)
                    translations[language] = translation
                } catch ParseError.languageNotFound(let key, let data) {
                    let error = ParseError.languageNotFound(key: key, data: data)
                    logNonFatalError(error)

                } catch ParseError.translationNotFound(let key, let data) {
                    let error = ParseError.languageNotFound(key: key, data: data)
                    logNonFatalError(error)
                }
            }

            let title = try getString(fromJSON: messageJSON, forKey: "title")
            let message = try getString(fromJSON: messageJSON, forKey: "message")
            let action = try getString(fromJSON: messageJSON, forKey: "action", optional: true)
            let actionTitle = try getString(fromJSON: messageJSON, forKey: "action_title", optional: true)

            return AICMessageModel(
                nid: messageNid,
                messageType: messageType,
                title: title,
                message: message,
                actionButtonTitle: actionTitle,
                action: action,
                translations: translations
            )
        } catch ParseError.missingKey(let key) {
            throw ParseError.invalidMessage(
                message: ParseError.missingKey(key: key).errorDescription!,
                data: messageJSON.description
            )

        } catch ParseError.badBoolString(let string) {
            throw ParseError.invalidMessage(
                message: ParseError.badBoolString(string: string).errorDescription!,
                data: messageJSON.description
            )

        } catch ParseError.badIntString(let string) {
            throw ParseError.invalidMessage(
                message: ParseError.badIntString(string: string).errorDescription!,
                data: messageJSON.description
            )
        } catch ParseError.objectParseFailure {
            throw ParseError.invalidMessage(
                message: ParseError.objectParseFailure.errorDescription!,
                data: messageJSON.description
            )

        } catch {
            fatalError(error.localizedDescription)
        }
	}

	private func parseTranslation(messageJSON: JSON) throws -> AICMessageTranslationModel {
		return AICMessageTranslationModel(
			title: try getString(fromJSON: messageJSON, forKey: "title"),
			message: try getString(fromJSON: messageJSON, forKey: "message"),
			actionButtonTitle: try getString(fromJSON: messageJSON, forKey: "action_title", optional: true)
		)
	}

	// MARK: Error-Throwing data parsing functions

	// Try to unwrap a string from JSON
	private func getString(fromJSON json: JSON, forKey key: String, optional: Bool = false) throws -> String {
		guard let str = json[key].string else {
			if optional == false {
				throw ParseError.missingKey(key: key)
			} else {
				return ""
			}
		}

		return str
	}

	private func getBool(fromJSON json: JSON, forKey key: String, optional: Bool = false, optionalValue: Bool = false) throws -> Bool {
		guard let bool = json[key].bool else {
			if optional == false {
				let str = try getString(fromJSON: json, forKey: key)
				throw ParseError.badBoolString(string: str)
			} else {
				return optionalValue
			}
		}

		return bool

	}

	// Try to parse an float from a JSON string
	private func getFloat(fromJSON json: JSON, forKey key: String) throws -> CGFloat {
		guard let float = json[key].float else {

			let str = try getString(fromJSON: json, forKey: key)
			let float = Float(str)

			if float == nil {
				throw ParseError.badFloatString(string: str)
			}

			return CGFloat(float!)
		}

		return CGFloat(float)
	}

	// Try to parse an int from a JSON string
	private func getInt(fromJSON json: JSON, forKey key: String) throws -> Int {
		guard let int = json[key].int else {

			let str = try getString(fromJSON: json, forKey: key)
			let int = Int(str)

			if int == nil {
				throw ParseError.badIntString(string: str)
			}

			return int!
		}

		return int
	}

	private func getIntArray(fromJSON json: JSON, forArrayKey key: String) throws -> [Int] {
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

	private func getRect(fromJSON json: JSON, forKey key: String) throws -> CGRect {
		guard let cropDict = json[key].dictionary else {
			throw ParseError.missingKey(key: key)
		}

		guard let x = cropDict["x"]?.floatValue else {
			throw ParseError.missingKey(key: "x")
		}
		guard let y = cropDict["y"]?.floatValue else {
			throw ParseError.missingKey(key: "y")
		}
		guard let width = cropDict["width"]?.floatValue else {
			throw ParseError.missingKey(key: "width")
		}
		guard let height = cropDict["height"]?.floatValue else {
			throw ParseError.missingKey(key: "height")
		}

		return CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
	}

	// Try to get a URL from a string
	private func getURL(fromJSON json: JSON, forKey key: String, optional: Bool = false) throws -> URL? {
		let stringVal = json[key].string
		if stringVal == nil {
			if optional == false {
				throw ParseError.badURLString(string: "null")
			} else {
				return nil
			}
		}

		guard let url: URL = URL(string: stringVal!) else {
			if optional == false {
				throw ParseError.badURLString(string: stringVal!)
			} else {
				return nil
			}
		}

		return url
	}

	// Try to Parse out the lat + long from a CMS location string,
	// i.e. "location": "41.879225,-87.622289"
	private func getCLLocation2d(fromJSON json: JSON, forKey key: String) throws -> CLLocationCoordinate2D {
		let stringVal = try getString(fromJSON: json, forKey: key)

		let latLongString = stringVal.replacingOccurrences(of: " ", with: "")
		let latLong: [String] = latLongString.components(separatedBy: ",")
		if latLong.count == 2 {
			let latitude = CLLocationDegrees(latLong[0])
			let longitude = CLLocationDegrees(latLong[1])

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

	private func getInt(fromJSON json: JSON, forArrayKey arrayKey: String, atIndex index: Int) throws -> Int {
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

	private func getAudioFile(forNID nid: Int) throws -> AICAudioFileModel {
		for audioFile in self.audioFiles {
			if audioFile.nid == nid {
				return audioFile
			}
		}
		throw ParseError.audioFileNotFound(nid: nid)
	}

	private func getObject(forNID nid: Int) throws -> AICObjectModel {
		guard let object = self.objects.filter({ $0.nid == nid}).first else {
			throw ParseError.objectNotFound(nid: nid)
		}

		return object
	}

	private func getGallery(forGalleryName galleryName: String) throws -> AICGalleryModel {
		guard let gallery = self.galleries
            .filter({ $0.title == galleryName && $0.closed == false }).first else {
			throw ParseError.galleryNameNotFound(galleryName: galleryName)
		}

		return gallery
	}

	private func getGallery(forGalleryId galleryId: Int) throws -> AICGalleryModel {
		guard let gallery = AppDataManager.sharedInstance.app.galleries
            .filter({ $0.galleryId == galleryId && $0.closed == false }).first else {
			throw ParseError.galleryIdNotFound(galleryId: galleryId)
		}
		return gallery
	}

	private func getLanguageFor(translationJSON: JSON) throws -> Common.Language {
        var commonLanguage = Common.Language.english

		do {
			let translationLanguage = try getString(fromJSON: translationJSON, forKey: "language")
            commonLanguage = Common.Language
                .allCases
                .first(where: { translationLanguage.hasPrefix($0.prefix) }) ?? .english
		} catch {
            throw ParseError.languageNotFound(key: "language", data: translationJSON.description)
        }

        return commonLanguage
	}

    private func logNonFatalError(_ parseError: ParseError) {
        crashlyticsManager.record(
            DataParserCrashlyticsReport(
                error: parseError
            )
        )

        if Common.Testing.printDataErrors {
            debugPrint(parseError.localizedDescription)
        }
    }
}
