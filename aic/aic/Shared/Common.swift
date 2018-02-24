/*
 Abstract:
 Constant global properties needed by all views
 */

import UIKit
import CoreLocation
import SnapKit
import Localize_Swift

struct Common {
    
    // MARK: Testing
    struct Testing {

        // Print data loading errors to console
        static var printDataErrors = false

        // Show the intro everytime the app launches
        static var alwaysShowInstructions = false

        // Show related tours even if on the tour,
        // many objects are only on one tour so this ensures tour to tour linking
        static var filterOutRelatedTours = true

        // Fake the current floor
        static var useTestFloorLocation = false
        static var testFloorNumber = 1

        // Test out news distance regardless of museum proximity
        static var testNewsToursDistances = false
    }

    // MARK: Data
    struct DataConstants {
        static let totalDataFeeds = 3

        struct NewsFeed {
            static var Featured = "http://www.artic.edu/exhibitions-json/featured-exhibitions"
        }
        
        static var appDataJSON = "http://localhost:8888/appData.json"

        static var appDataExternalPrefix = "http://localhost:8888/"
        static var appDataInternalPrefix = "http://localhost:8888/"
		static var appDataLocalPrefix = "http://localhost:9000/"

        // This URL is the link for requests to validate member card data. The member card feature is disabled by default
        // in the open source version of this application
        static var memberCardSOAPRequestURL = "http://link-to-member-card-validation.domain"

        static let testMemberID:UInt64 = 0000000000000
        static let testMemberZip:Int = 00000

        static let testMultipleMemberID:UInt64 = 000000
        static let testMultipleMemberZip:Int = 00000

        static let dataLoadFailureTitle = "Load Failure"
        static let dataLoadFailureMessage = "Please check your internet connection and try again."
        static let dataLoadFailureButtonTitle = "Retry"

        // Feature #886 - Override crop rects for SOLR images
        static var ignoreOverrideImageCrop = true

        // Used to cache JSON data locally until remote file changes
        static let localAppDataFilename = "app.data"
        static let localNewsFeedFilename = "news.data"
    }

    // MARK: Sections
    static let Sections:[Section:AICSectionModel] = [
		Section.home: AICSectionModel(nid:Section.home.rawValue,
										 color: .aicHomeColor,
										 background: #imageLiteral(resourceName: "backgroundHome"),
										 icon: #imageLiteral(resourceName: "iconHome"),
										 title: "Welcome",
										 tabBarTitle: "Home",
										 tabBarIcon: #imageLiteral(resourceName: "navHome")
		),
		Section.audioGuide: AICSectionModel(nid:Section.audioGuide.rawValue,
            color: .aicAudioGuideColor,
			background: nil,
			icon: #imageLiteral(resourceName: "iconNumPad"),
            title: "Audio Title",
            tabBarTitle: "Audio",
            tabBarIcon: #imageLiteral(resourceName: "navNumPad")
        ),
        Section.map: AICSectionModel(nid:Section.map.rawValue,
            color: .aicNearbyColor,
			background: nil,
			icon: #imageLiteral(resourceName: "iconMap"),
            title: "Map Title",
            tabBarTitle: "Map",
            tabBarIcon: #imageLiteral(resourceName: "navMap")
        ),
        Section.info: AICSectionModel(nid:Section.info.rawValue,
            color: .aicInfoColor,
			background: #imageLiteral(resourceName: "backgroundInfo"),
            icon: #imageLiteral(resourceName: "iconInfo"),
            title: "Information Title",
            tabBarTitle: "Info",
            tabBarIcon: #imageLiteral(resourceName: "navInfo")
        )
    ]


    // MARK: User Defaults
    struct UserDefaults {
        // Configuration defaults (these come through MDM)
        static let configurationDictionaryUserDefaultKey = "com.apple.configuration.managed"

        static let rentalRestartHourUserDefaultKey = "AICRentalRestartHour"
        static let rentalRestartMinuteUserDefaultKey = "AICRentalRestartMinute"
        static let rentalRestartDaysFromNowUserDefaultKey = "AICRentalRestartDaysFromNow"

        static let showLanguageSelectionUserDefaultsKey = "AICShowLanguageSelection"
        static let showHeadphonesUserDefaultsKey = "AICShowHeadphones"
        static let showEnableLocationUserDefaultsKey = "AICShowEnableLocation"

        static let memberInfoIDUserDefaultsKey = "AICMemberInfoName"
        static let memberInfoZipUserDefaultsKey = "AICMemberInfoZip"
		static let memberFirstNameUserDefaultsKey = "AICMemberFirstName"
        static let memberInfoSelectedMemberDefaultsKey = "AICMemberInfoSelectedMember"

        static let onDiskAppDataLastModifiedString = "AICAppDataLastModified"
        static let onDiskNewsFeedLastModifiedString = "AICNewsFeedLastModified"
    }

    // MARK: URL Scheme/Deep Links
    struct DeepLinks {
        
        static var loadedEnoughToLink = false
        
        static let domain = "artic"
        static let tourCategory = "tour"

        static func getURL(forTour tour:AICTourModel) -> String?{
            if (loadedEnoughToLink){
                return String("\(domain)://\(tourCategory)/\(tour.nid)")
            } else {
                return nil
            }
        }
    }
	
	// MARK: Language
	enum Language : String {
		case english = "en"
		case spanish = "es"
		case chinese = "zh-Hans"
	}
	
	static var currentLanguage: Language {
		let current = Localize.currentLanguage()
		if current.hasPrefix("es") {
			return .spanish
		}
		else if current.hasPrefix("zh") {
			return .chinese
		}
		return .english
	}

    // MARK: Layout
	struct Layout {
		static var safeAreaTopMargin: CGFloat {
			if UIDevice().type == .iPhoneX {
				return 44
			}
			return 20
		}
		
		static var navigationBarHeight: CGFloat = 240
		
		static var navigationBarMinimizedHeight: CGFloat {
			if UIDevice().type == .iPhoneX {
				return 73
			}
			return 64
		}
		
		static var navigationBarVerticalOffset: CGFloat {
			return navigationBarHeight - safeAreaTopMargin
		}
		
		static var navigationBarMinimizedVerticalOffset: CGFloat {
			return navigationBarMinimizedHeight
		}
		
		static var tabBarHeight: CGFloat {
			if UIDevice().type == .iPhoneX {
				return 83
			}
			return 49
		}
		
		static var miniAudioPlayerHeight: CGFloat = 40.0

        static var tabBarHeightWithMiniAudioPlayerHeight:CGFloat {
			return tabBarHeight + miniAudioPlayerHeight
        }
		
		static var cardFullscreenPositionY: CGFloat {
			if UIDevice().type == .iPhoneX {
				return 40
			}
			return 20
		}
		
		static var cardContentHeight: CGFloat {
			return UIScreen.main.bounds.height - cardFullscreenPositionY - Common.Layout.tabBarHeight
		}
        
        static var cardMinimizedContentHeight: CGFloat = 170.0 + Common.Layout.miniAudioPlayerHeight

        static let showTabBarTitles = true

        static var showStatusBar:Bool = true {
            didSet {
                UIView.animate(withDuration: 0.75) {
                    UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }

        enum Priority : Int {
            case low = 1
            case medium = 250
            case high = 500
            case required = 1000
        }
    }

    // MARK: Notifications
    struct Notifications {
        // Object View
        static let shouldShowObjectViewNotification = "SHOULD_SHOW_OBJECT_VIEW_NOTIFICATION"
        static let tabBarHeightDidChangeNotification = "TAB_BAR_HEIGHT_DID_CHANGE_NOTIFICATION"

        // Map
        static let mapShouldShowTour = "MAP_SHOULD_SHOW_TOUR_NOTIFICATION"
        static let mapShouldHighlightTourItem = "MAP_SHOULD_HIGHLIGHT_TOUR_ITEM_NOTIFICATION"
    }

    // MARK: Messages
    struct Messages {
        // Animation
        static let fadeInAnimationDuration = 0.5


        // Small
        static let leaveTour = AICMessageSmallModel(title: "Leave this tour?",
                                                    message: "If you continue, you will leave this page and end the tour.",
                                                    actionButtonTitle: "Continue",
                                                    cancelButtonTitle: "Cancel"
        )

        static let locationDisabled = AICMessageSmallModel(title: "Your phone’s Location Services feature is off.",
                                                           message: "Turn on Location Services to easily navigate the museum and find museum features near you.",
                                                           actionButtonTitle: "Go to Settings",
                                                           cancelButtonTitle: "Cancel"
        )

        static let locationOffsite = AICMessageSmallModel(title: "You are currently located outside of the museum.",
                                                          message: "Please visit the museum to experience our location tracking features.",
                                                          actionButtonTitle: "OK",
                                                          cancelButtonTitle: nil
        )

        // Large
        static let useHeadphones = AICMessageModel(iconImage: #imageLiteral(resourceName: "messageListenIn"),
                                                        title: "Message Headphones Title",
                                                        message: "Message Headphones Text",
                                                        actionButtonTitle: "Message Headphones Action Button Title",
                                                        cancelButtonTitle: nil
        )
        
        static let leavingTour = AICMessageModel(iconImage: #imageLiteral(resourceName: "messageListenIn"),
                                                 title: "Message Leaving Tour Title",
                                                 message: "Message Leaving Tour Text",
                                                 actionButtonTitle: "Message Leaving Tour Action Button Title",
                                                 cancelButtonTitle: "Message Leaving Tour Cancel Button Title"
        )

        static let enableLocation = AICMessageModel(iconImage: #imageLiteral(resourceName: "messageMap"),
                                                         title: "Message Location Title",
                                                         message: "Message Location Text",
                                                         actionButtonTitle: "Message Location Action Button Title",
                                                         cancelButtonTitle: "Message Location Cancel Button Title"
        )
    }

    // MARK: Location
    struct Location {
        // Geo-Fence distance
        static let minDistanceFromMuseumForLocation = 250.0

        static let walkingSpeed = 2.0 // in km/h
        static let timeToChangeFloors = 1.0 // Minutes

        // Get the time (in minutes) to walk from one
        static func getTime(fromUserLocation userLocation:CLLocation, toObjectLocation objectLocation: CoordinateWithFloor) -> Int {
            // Get the distancse
            let distanceInMeters = getDistance(fromUserLocation: userLocation, toObjectLocation: objectLocation);
            let distanceInKilometers = distanceInMeters/1000.0

            // Convert to time
            let timeInHours = distanceInKilometers/walkingSpeed
            var timeInMinutes = timeInHours * 60.0

            // Figure out the floor time
            guard let floor = userLocation.floor else {
                return Int(timeInMinutes)
            }

            let floorDifference = abs(floor.level - objectLocation.floor)
            let floorTime = Double(floorDifference) * timeToChangeFloors

            timeInMinutes = timeInMinutes + floorTime

            return Int(timeInMinutes)
        }

        // Get the object that is closest to a user location
        static func getClosestObject(toUserLocation userLocation:CLLocation, forObjects objects:[AICObjectModel]) -> AICObjectModel {
            var closestObject:AICObjectModel? = nil
            var closestDistance:Double = Double.greatestFiniteMagnitude

            for object in objects {
                let distance = getDistance(fromUserLocation: userLocation, toObjectLocation: object.location);
                if distance < closestDistance {
                    closestObject = object
                    closestDistance = distance
                }
            }

            return closestObject!
        }

        static func getDistance(fromUserLocation userLocation:CLLocation, toObjectLocation objectLocation:CoordinateWithFloor) -> Double {
            let objectCLLocation = CLLocation(latitude: objectLocation.coordinate.latitude, longitude: objectLocation.coordinate.longitude)
            return userLocation.distance(from: objectCLLocation)
        }
    }
	
	// MARK: Home
	struct Home {
		static let maxNumberOfTours: Int = 6
		static let maxNumberOfExhibitions: Int = 6
		static let maxNumberOfEvents: Int = 8
	}

    // MARK: Instructions
	// TODO: REMOVE instructions
    // Content for each screen
    struct Instructions {
        static let screens = [
			AICInstructionsScreenModel(iconImage: #imageLiteral(resourceName: "iconToursLarge"),
									   title:"Please Choose Your Preferred Language",
									   subtitle: "Some content may not be available in your selected language.",
									   color: .aicHomeColor
			),
			
            AICInstructionsScreenModel(iconImage: #imageLiteral(resourceName: "iconMapLarge"),
                title:"Find Your Way",
                subtitle: "Use the map to explore the museum and find audio-enhanced artworks near you.",
                color: .aicMapColor
            ),


            AICInstructionsScreenModel(iconImage: #imageLiteral(resourceName: "iconToursLarge"),
                title:"On View Now",
                subtitle: "Preview the latest exhibitions at the Art Institute.",
                color: .aicHomeColor
            ),


            AICInstructionsScreenModel(iconImage: #imageLiteral(resourceName: "iconNumPadLarge"),
                title:"Look It Up",
                subtitle: "Find an artwork you like? Use the keypad to access audio-enhanced stories.",
                color: .aicAudioGuideColor
            ),


            AICInstructionsScreenModel(iconImage: #imageLiteral(resourceName: "iconInfoLarge"),
                title:"Member’s Access",
                subtitle: "Enter your membership ID for easy access to the museum.",
                color: .aicInfoColor
            ),

            AICInstructionsScreenModel(iconImage: #imageLiteral(resourceName: "iconToursLarge"),
                title:"Go on a Tour",
                subtitle: "Find a story that suits your interests in our ever-expanding portfolio of audio tours.",
                color: .aicHomeColor
            )
        ]
    }
	
    // MARK: Map
    struct Map {
		// Location Manager
		static let locationManager: CLLocationManager = CLLocationManager()
		
        static let backgroundOverlayAlpha:CGFloat = 0.75

        static let totalFloors = 4
        static let startFloor = 1
		
		static var stringForFloorNumber: [Int : String] {
			return [
				0 : "Lower Level".localized(using: "Map"),
				1 : "First Level".localized(using: "Map"),
				2 : "Second Level".localized(using: "Map"),
				3 : "Third Level".localized(using: "Map")]
		}

        // File directories
        static let mapsDirectory = "map"
        static let floorplanFileNamePrefix = "map_floor"
        static let amenityLandmarkSVGFileName = "map_amenities_landmarks"

        // Map SVG File
        static let mapSVGFileURL = Bundle.main.url(forResource: Common.Map.amenityLandmarkSVGFileName, withExtension: "svg", subdirectory:Common.Map.mapsDirectory)

        // Anchor pair for mapping GeoCoords to PDF Coords
        static let pdfSize = CGSize(width: 800, height: 800)
        static let anchor1 = GeoAnchor(latitudeLongitudeCoordinate: CLLocationCoordinate2DMake(41.88002009571711,-87.62398928403854),
                                       pdfPoint: CGPoint(x: 55.955, y: pdfSize.height-261.635)
        )

        static let anchor2 = GeoAnchor(latitudeLongitudeCoordinate: CLLocationCoordinate2DMake(41.8800240897643,-87.62334823608397),
                                       pdfPoint: CGPoint(x: 211.94, y: pdfSize.height-261.635)
        )
		
        static let anchorPair = GeoAnchorPair(fromAnchor: anchor1, toAnchor: anchor2)

        static let coordinateConverter = CoordinateConverter(anchors: Common.Map.anchorPair)

        enum ZoomLevelAltitude : Double {
            case zoomedOut = 1200.0
            case zoomedIn = 200.0
            case zoomedDetail = 40.0
            case zoomedMax = 25.0

            static let allValues = [zoomedOut, zoomedIn, zoomedDetail, zoomedMax]
        }

        enum AnnotationZPosition: CGFloat {
            case gradient = 0
            case amenities = 1
            case objectsDeselected = 5
            case text = 10
            case department = 20
            case objectMaximized = 30
            case objectsSelected = 40
        }

        // Departments
        enum Department: String {
            case African = "african"
            case AmericaBefore1900 = "americanbefore1900"
            case AmericanDecorative = "americandecorative"
            case AmericanFolk = "americanfolk"
            case AmericanIndian = "americanindian"
            case AmericanModern = "americanmodern"
            case Architecture1 = "architecture0"
            case Architecture2 = "architecture2"
            case Armor = "armor"
            case Chicago = "chicago"
            case Chinese = "chinese"
            case Contemporary = "contemporary"
            case ContempSculpture = "contemporarysculpture"
            case EuroBefore1900 = "europeanbefore1900"
            case EuroDecorative = "europeandecorative"
            case Film = "film"
            case Greek = "greek"
            case Impressionism = "impressionism"
            case Indian = "indian"
            case Islamic = "islamic"
            case Modern = "modern"
            case Paperweights = "paperweights"
            case Photography0 = "photography0"
            case Photography1 = "photography1"
            case Print = "prints"
            case Textiles = "textiles"
            case Thorne = "thorne"
        }

        static let departmentTitles:[Department:String] = [
            .African : "African Art",
            .AmericaBefore1900 : "American Art Before 1900",
            .AmericanDecorative : "American Decorative\nArts 1920-1970",
            .AmericanFolk : "American Folk Art",
            .AmericanIndian : "Indian Art of\nthe Americas",
            .AmericanModern : "Modern American Art",
            .Architecture1 : "Architecture\nand Design",
            .Architecture2 : "Architecture\nand Design",
            .Armor : "Arms and Armor",
            .Chicago : "Chicago\nArchitecture",
            .Chinese : "Chinese, Japanese,\nand Korean Art",
            .Contemporary : "Contemporary Art 1945 - 1960",
            .ContempSculpture : "Contemporary Sculpture",
            .EuroBefore1900 : "European Art\nBefore 1900",
            .EuroDecorative : "European Decorative\nArts",
            .Film : "Film, Video,\nand New Media",
            .Greek : "Greek, Roman,\nand Byzantine Art",
            .Impressionism : "Impressionism",
            .Indian : "Indian, Southeast Asian,\nand Himalayan Art",
            .Islamic : "Islamic Art",
            .Modern : "Modern Art",
            .Paperweights : "Paperweights",
            .Photography0 : "Photography",
            .Photography1 : "Photography",
            .Print : "Prints and Drawings",
            .Textiles : "Textiles",
            .Thorne : "Thorne Miniature Rooms"
        ]

        // Annotation view settings
        static let thumbSize:CGFloat = 54
        static let thumbHolderMargin:CGFloat = 2
    }

    //MARK: Info
    struct Info {

        // Text and URL constants
        static let becomeMemberTitle = "Become a Member"
        static let becomeMemberJoinPromptMessage = "Enjoy free, yearlong admission."
        static let becomeMemberJoinMessage = "Join now"
        static let becomeMemberJoinURL = "https://sales.artic.edu/memberships"
        static let becomeMemberAccessPrompt = "Already a member?"
        static let becomeMemberAccessButtonTitle = "Access Member Card"
        static let becomeMemberExistingMemberTitle = "Welcome Back"
		
        static let museumInformationAddress = "111 S Michigan Ave\nChicago, IL 60603"
        static let museumInformationPhoneNumber = "+1 312 443 3600"
        static let museumInformationGetTicketsTitle = "Get Tickets"
        static let museumInformationGetTicketsURL = "https://sales.artic.edu/admissiondate"

        static let potionURL = "http://www.potiondesign.com"

        static let memberCardTitle = "Member Card"
        static let memberIDTitle = "Your Member ID"
        static let memberIDPlaceholder = "Enter your Member ID..."
        static let memberZipTitle = "Your Zip Code"
        static let memberZipPlaceholder = "Enter your home zip code..."
        static let memberSignInTitle = "Sign In"
        static let memberUpdateTitle = "Change Information"
        static let memberSwitchCardHolder = "Switch Cardholder"

        static let alertMessageNotFound = "Could not find Member Information"
        static let alertMessageParseError = "Member Card data parse error"
        static let alertMessageCancelButtonTitle = "OK"
		
		// Date formats
		static func throughDateString(endDate: Date) -> String {
			let dateFormatter = DateFormatter()
//			dateFormatter.dateFormat = "MMMM d, yyyy"
			//DateFormatter.localizedString(from: endDate, dateStyle: .medium, timeStyle: .medium)
			dateFormatter.locale = Locale(identifier: Common.currentLanguage.rawValue)
			dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
			let endDateFormatted = dateFormatter.string(from: endDate)
			let throughString = "Through Date".localized(using: "Global")
			return throughString + " " + endDateFormatted
		}
		
		static func monthDayString(date: Date) -> String {
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier: Common.currentLanguage.rawValue)
			dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d")
			let monthDayString = dateFormatter.string(from: date)
			return monthDayString
		}
		
		static func hoursMinutesString(date: Date) -> String {
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier: Common.currentLanguage.rawValue)
			dateFormatter.setLocalizedDateFormatFromTemplate("h:mma")
			dateFormatter.amSymbol = "am"
			dateFormatter.pmSymbol = "pm"
			let hoursMinutesString = dateFormatter.string(from: date)
			return hoursMinutesString
		}
		
        // Background images
        static let backgroundAnimationTime = 3.0
        static let memberCardImagesTotal = 3
        static let memberCardImagePrefix = "memberCard"

        static var memberCardImages:[UIImage] = {
            var images:[UIImage] = []

            for index in 1...memberCardImagesTotal {
                let imageName = "\(memberCardImagePrefix)\(index)"
                images.append(UIImage(named:imageName)!)
            }

            return images
        }()

    }
	
	// MARK: Search
	struct Search {
		static let museumWebsiteURL = "http://www.artic.edu"
		static let visitWebsiteText = "For help, visit the nearest museum representative\nor visit our website."
		
		enum Filter {
			case empty
			case suggested
			case artworks
			case tours
			case exhibitions
		}
	}
	
	// MARK: Data Settings
	enum DataSetting: String {
		case imageServerUrl = "image_server_url"
		case dataApiUrl = "data_api_url"
		case exhibitionsEndpoint = "exhibitions_endpoint"
		case artworksEndpoint = "artworks_endpoint"
		case galleriesEndpoint = "galleries_endpoint"
		case imagesEndpoint = "images_endpoint"
		case eventsEndpoint = "events_endpoint"
		case autocompleteEndpoint = "autocomplete_endpoint"
		case toursEndpoint = "tours_endpoint"
	}
}
