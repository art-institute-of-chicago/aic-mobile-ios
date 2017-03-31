/*
 Abstract:
 Constant global properties needed by all views
 */

import UIKit
import CoreLocation
import SnapKit

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
        static let totalDataFeeds = 2

        struct NewsFeed {
            static var Featured = "http://www.artic.edu/exhibitions-json/featured-exhibitions"
        }
        
        static var appDataJSON = "http://localhost:8888/appData.json"

        static var appDataExternalPrefix = "http://localhost:8888/"
        static var appDataInternalPrefix = "http://localhost:8888/"

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
        Section.audioGuide: AICSectionModel(nid:Section.audioGuide.rawValue,
            color: UIColor.aicAudioGuideColor(),
            icon: UIImage(named:"iconNumPad")!,
            title: "Look It Up",
            description: "Find an artwork you like? Enter the artwork number to learn more.",
            tabBarTitle: "Audio",
            tabBarIcon: UIImage(named: "navNumPad")!
        ),

        Section.whatsOn: AICSectionModel(nid:Section.whatsOn.rawValue,
            color: UIColor.aicWhatsonColor(),
            icon: UIImage(named:"iconWhatsOn")!,
            title: "On View Now",
            description: "Preview the latest exhibitions at the Art Institute.",
            tabBarTitle: "On View",
            tabBarIcon: UIImage(named: "navWhatsOn")!
        ),
        Section.tours: AICSectionModel(nid:Section.tours.rawValue,
            color: UIColor.aicToursColor(),
            icon: UIImage(named:"iconTours")!,
            title: "Take an Audio Tour",
            description: "Listen to the latest stories from our ever-expanding repertoire of mobile tours.",
            tabBarTitle: "Tours",
            tabBarIcon: UIImage(named: "navTours")!
        ),
        Section.map: AICSectionModel(nid:Section.map.rawValue,
            color: UIColor.aicNearbyColor(),
            icon: UIImage(named:"iconMap")!,
            title: "Find Your Way",
            description: "Use the map to explore the museum and find audio-enhanced artworks near you.",
            tabBarTitle: "Map",
            tabBarIcon: UIImage(named: "navMap")!
        ),
        Section.info: AICSectionModel(nid:Section.info.rawValue,
            color: UIColor.aicInfoColor(),
            icon: UIImage(named:"iconInfo")!,
            title: "Need Information?",
            description: "Here’s everything you need to visit us and keep in touch.",
            tabBarTitle: "Info",
            tabBarIcon: UIImage(named: "navInfo")!
        )
    ]


    // MARK: User Defaults
    struct UserDefaults {
        // Configuration defaults (these come through MDM)
        static let configurationDictionaryUserDefaultKey = "com.apple.configuration.managed"

        static let rentalRestartHourUserDefaultKey = "AICRentalRestartHour"
        static let rentalRestartMinuteUserDefaultKey = "AICRentalRestartMinute"
        static let rentalRestartDaysFromNowUserDefaultKey = "AICRentalRestartDaysFromNow"

        static let showInstructionsUserDefaultsKey = "AICShowInstructions"
        static let showHeadphonesUserDefaultsKey = "AICShowHeadphones"
        static let showEnableLocationUserDefaultsKey = "AICShowEnableLocation"

        static let memberInfoIDUserDefaultsKey = "AICMemberInfoName"
        static let memberInfoZipUserDefaultsKey = "AICMemberInfoZip"
        static let memberInfoSelectedMemberDefaultsKey = "AICMemberInfoSelectedMember"

        static let onDiskAppDataLastModifiedString = "AICAppDataLastModified"
        static let onDiskNewsFeedLastModifiedString = "AICNewsFeedLastModified"
    }

    // MARK: URL Scheme/Deep Links
    struct DeepLinks {
        static let domain = "AICOfficialMobileApp"
        static let tourCategory = "tour"

        static func getURL(forTour tour:AICTourModel) -> String{
            return String("\(domain)://\(tourCategory)/\(tour.nid)")
        }
    }

    // MARK: Layout
    struct Layout {
        static var appFrame:CGRect = CGRect.zero

        static let tabBarHeight:CGFloat = 49

        static var tabBarHeightWithMiniAudioPlayerHeight:CGFloat = 49 {
            didSet {
                if tabBarHeightWithMiniAudioPlayerHeight != oldValue {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.tabBarHeightDidChangeNotification), object: nil)
                }
            }
        }

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
        static let useHeadphones = AICMessageLargeModel(iconImage: UIImage(named: "messageHeadphones")!,
                                                        title: "Listen in.",
                                                        message: "Use your headphones to listen.\n\nDon’t have headphones?\nHold the phone close to your ear.",
                                                        actionButtonTitle: "OK",
                                                        cancelButtonTitle: nil
        )

        static let enableLocation = AICMessageLargeModel(iconImage: UIImage(named: "messageLocation")!,
                                                         title: "Where are you?",
                                                         message: "We’d like to use your location to help you navigate the museum.",
                                                         actionButtonTitle: "OK",
                                                         cancelButtonTitle: "Not Now"
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
            var closestDistance:Double = DBL_MAX

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

    // MARK: Intro
    // Content for each screen
    struct Instructions {
        static let screens = [
            AICInstructionsScreenModel(iconImage: UIImage(named:"iconMapLarge")!,
                title:"Find Your Way",
                subtitle: "Use the map to explore the museum and find audio-enhanced artworks near you.",
                color: UIColor.aicMapColor()
            ),


            AICInstructionsScreenModel(iconImage: UIImage(named:"iconWhatsOnLarge")!,
                title:"On View Now",
                subtitle: "Preview the latest exhibitions at the Art Institute.",
                color: UIColor.aicWhatsonColor()
            ),


            AICInstructionsScreenModel(iconImage: UIImage(named:"iconNumPadLarge")!,
                title:"Look It Up",
                subtitle: "Find an artwork you like? Use the keypad to access audio-enhanced stories.",
                color: UIColor.aicAudioGuideColor()
            ),


            AICInstructionsScreenModel(iconImage: UIImage(named:"iconInfoLarge")!,
                title:"Member’s Access",
                subtitle: "Enter your membership ID for easy access to the museum.",
                color: UIColor.aicInfoColor()
            ),

            AICInstructionsScreenModel(iconImage: UIImage(named:"iconToursLarge")!,
                title:"Go on a Tour",
                subtitle: "Find a story that suits your interests in our ever-expanding portfolio of audio tours.",
                color:UIColor.aicToursColor()
            )
        ]
    }

    // MARK: Map
    struct Map {
        static let backgroundOverlayAlpha:CGFloat = 0.75

        static let totalFloors = 4
        static let startFloor = 1

        // File directories
        static let mapsDirectory = "Assets/map"
        static let floorplanFileNamePrefix = "map_floor"
        static let amenityLandmarkSVGFileName = "map_amenities_landmarks"

        // Map SVG File
        static let mapSVGFileURL = Bundle.main.url(forResource: Common.Map.amenityLandmarkSVGFileName, withExtension: "svg", subdirectory:Common.Map.mapsDirectory)

        // Anchor pair for mapping GeoCoords to PDF Coords
        static let pdfSize = CGSize(width: 2400, height: 2400)
        static let anchor1 = GeoAnchor(latitudeLongitudeCoordinate: CLLocationCoordinate2DMake(41.87998814333057,-87.62397855520248),
                                       pdfPoint: CGPoint(x: 855.955, y: pdfSize.height-1061.635)
        )

        static let anchor2 = GeoAnchor(latitudeLongitudeCoordinate: CLLocationCoordinate2DMake(41.87999812845307,-87.62333750724792),
                                       pdfPoint: CGPoint(x: 1011.94, y: pdfSize.height-1061.635)
        )

        static let anchorPair = GeoAnchorPair(fromAnchor: anchor1, toAnchor: anchor2)

        static let coordinateConverter = CoordinateConverter(anchors: Common.Map.anchorPair)

        enum ZoomLevelAltitude : Double {
            case zoomedOut = 400.0
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
        static let becomeMemberTitle = "Become a member"
        static let becomeMemberSupportMessage = "Enjoy free, yearlong admission."
        static let becomeMemberJoinMessage = "Join now."
        static let becomeMemberJoinURL = "https://sales.artic.edu/memberships"
        static let becomeMemberAccessPrompt = "Already a member?"
        static let becomeMemberAccessButtonTitle = "Access Member Card"
        static let becomeMemberExistingMemberTitle = "Welcome Back"

        static let museumInformationTitle = "Museum Information"
        static let museumInformationHours = "Open daily 10:30am to 5:00pm\nThursday until 8:00pm\n\nClosed Thanksgiving, Christmas,\nand New Year’s Day"
        static let museumInformationAddress = "111 S Michigan Ave\nChicago, IL 60603"
        static let museumInformationPhoneNumber = "+1 312 443 3600"
        static let museumInformationGetTicketsTitle = "Get Tickets"
        static let museumInformationGetTicketsURL = "https://sales.artic.edu/admissiondate"

        static let creditsPotion = "Designed by Potion"
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
}
