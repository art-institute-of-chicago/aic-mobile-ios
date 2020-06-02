/*
Abstract:
Constant global properties needed by all views
*/

import UIKit
import CoreLocation
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
		static let totalDataFeeds = 4

		static var appDataJSON = "http://localhost:8888/appData.json"

		// This URL is the link for requests to validate member card data. The member card feature is disabled by default
		// in the open source version of this application
		static var memberCardSOAPRequestURL = "http://link-to-member-card-validation.domain"

		static let dataLoadFailureTitle = "Load Failure"
		static let dataLoadFailureMessage = "Please check your internet connection and try again."
		static let dataLoadFailureButtonTitle = "Retry"

		// Feature #886 - Override crop rects for SOLR images
		static var ignoreOverrideImageCrop = true

		// Used to cache JSON data locally until remote file changes
		static let localAppDataFilename = "app.data"
	}

	// MARK: Sections
	static let Sections: [Section: AICSectionModel] = [
		Section.home: AICSectionModel(nid: Section.home.rawValue,
									  color: .aicHomeColor,
									  background: #imageLiteral(resourceName: "backgroundHome"),
									  icon: #imageLiteral(resourceName: "iconHome"),
									  title: "welcome_title:Base",
									  tabBarTitle: "Home",
									  tabBarIcon: #imageLiteral(resourceName: "navHome")
		),
		Section.audioGuide: AICSectionModel(nid: Section.audioGuide.rawValue,
											color: .aicAudioGuideColor,
											background: nil,
											icon: #imageLiteral(resourceName: "iconNumPad"),
											title: "Audio Title",
											tabBarTitle: "Audio",
											tabBarIcon: #imageLiteral(resourceName: "navNumPad")
		),
		Section.map: AICSectionModel(nid: Section.map.rawValue,
									 color: .aicNearbyColor,
									 background: nil,
									 icon: #imageLiteral(resourceName: "iconMap"),
									 title: "Map Title",
									 tabBarTitle: "Map",
									 tabBarIcon: #imageLiteral(resourceName: "navMap")
		),
		Section.info: AICSectionModel(nid: Section.info.rawValue,
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
		static let showTooltipsDefaultsKey = "AICShowTooltips"

		static let memberInfoIDUserDefaultsKey = "AICMemberInfoName"
		static let memberInfoZipUserDefaultsKey = "AICMemberInfoZip"
		static let memberFirstNameUserDefaultsKey = "AICMemberFirstName"
		static let memberInfoSelectedMemberDefaultsKey = "AICMemberInfoSelectedMember"

		static let onDiskAppDataLastModifiedStringKey = "AICAppDataLastModified"

		static let lastVersionNumberKey = "AICLastVersionNumber"
	}

	// MARK: URL Scheme/Deep Links
	struct DeepLinks {

		static var loadedEnoughToLink = false

		static let domain = "artic"
		static let tourCategory = "tour"

		static func getURL(forTour tour: AICTourModel) -> String? {
			if loadedEnoughToLink {
				return String("\(domain)://\(tourCategory)/\(tour.nid)")
			} else {
				return nil
			}
		}
	}

	// MARK: Language
	enum Language: String, CaseIterable {
		case english = "en"
		case spanish = "es"
		case chinese = "zh-Hans"
		case korean = "ko"
		case french = "fr"

		var prefix: String {
			switch self {
			case .english:
				return "en"
			case .spanish:
				return "es"
			case .chinese:
				return "zh"
			case .korean:
				return "ko"
			case .french:
				return "fr"
			}
		}
	}

	static var currentLanguage: Language {
		let current = Localize.currentLanguage()
		for language in Language.allCases {
			guard current.hasPrefix(language.prefix) else { continue }
			return language
		}
		return .english
	}

	static var stringForLanguage: [Language: String] {
		return [
			.english: "English",
			.spanish: "Spanish",
			.chinese: "Chinese",
			.korean: "Korean",
			.french: "French"
		]
	}

	// MARK: Layout
	struct Layout {
		static var safeAreaTopMargin: CGFloat {
			if UIDevice().type == .iPhoneX ||
				UIDevice().type == .iPhoneXS ||
				UIDevice().type == .iPhoneXS_Max ||
				UIDevice().type == .iPhoneXR ||
				UIDevice().type == .iPhone11 ||
				UIDevice().type == .iPhone11_Pro ||
				UIDevice().type == .iPhone11_Pro_Max {
				return 44
			}
			return 20
		}

		static var navigationBarHeight: CGFloat = 240

		static var navigationBarMinimizedHeight: CGFloat {
			if UIDevice().type == .iPhoneX ||
				UIDevice().type == .iPhoneXS ||
				UIDevice().type == .iPhoneXS_Max ||
				UIDevice().type == .iPhoneXR ||
				UIDevice().type == .iPhone11 ||
				UIDevice().type == .iPhone11_Pro ||
				UIDevice().type == .iPhone11_Pro_Max {
				return 73
			}
			return 64
		}

		static var tabBarHeight: CGFloat {
			if UIDevice().type == .iPhoneX ||
				UIDevice().type == .iPhoneXS ||
				UIDevice().type == .iPhoneXS_Max ||
				UIDevice().type == .iPhoneXR ||
				UIDevice().type == .iPhone11 ||
				UIDevice().type == .iPhone11_Pro ||
				UIDevice().type == .iPhone11_Pro_Max {
				return 83
			}
			return 49
		}

		static var miniAudioPlayerHeight: CGFloat = 42.0

		static var tabBarHeightWithMiniAudioPlayerHeight: CGFloat {
			return tabBarHeight + miniAudioPlayerHeight
		}

		static var cardFullscreenPositionY: CGFloat {
			if UIDevice().type == .iPhoneX ||
				UIDevice().type == .iPhoneXS ||
				UIDevice().type == .iPhoneXS_Max ||
				UIDevice().type == .iPhoneXR ||
				UIDevice().type == .iPhone11 ||
				UIDevice().type == .iPhone11_Pro ||
				UIDevice().type == .iPhone11_Pro_Max {
				return 40
			}
			return 20
		}

		static var cardMinimizedPositionY: CGFloat {
			return UIScreen.main.bounds.height - Common.Layout.tabBarHeight - Common.Layout.cardMinimizedContentHeight
		}

		static var cardContentHeight: CGFloat {
			return UIScreen.main.bounds.height - cardFullscreenPositionY - Common.Layout.tabBarHeight
		}

		static var cardMinimizedContentHeight: CGFloat = 170.0 + Common.Layout.miniAudioPlayerHeight

		static let showTabBarTitles = true

		static var showStatusBar: Bool = true {
			didSet {
				UIView.animate(withDuration: 0.75) {
					UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
				}
			}
		}

		enum Priority: Int {
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
												   title: "headphone_message_title".localized(using: "MediaUI"),
												   message: "headphone_message_body".localized(using: "MediaUI"),
												   actionButtonTitle: "global_accept_action".localized(using: "Base"),
												   cancelButtonTitle: nil
		)

		static let leavingTour = AICMessageModel(iconImage: #imageLiteral(resourceName: "messageTours"),
												 title: "tour_leave_tour_title".localized(using: "Base"),
												 message: "",
												 actionButtonTitle: "tour_leave_tour_leave_action".localized(using: "Base"),
												 cancelButtonTitle: "tour_leave_tour_cancel_action".localized(using: "Base")
		)

		static let enableLocation = AICMessageModel(iconImage: #imageLiteral(resourceName: "messageMap"),
													title: "location_settings_header".localized(using: "LocationUI"),
													message: "location_settings_body".localized(using: "LocationUI"),
													actionButtonTitle: "global_accept_action".localized(using: "Base"),
													cancelButtonTitle: "global_cancel_action".localized(using: "Base")
		)
	}

	// MARK: Location
	struct Location {
		// Geo-Fence distance
		static let minDistanceFromMuseumForLocation = 250.0

		static let walkingSpeed = 2.0 // in km/h
		static let timeToChangeFloors = 1.0 // Minutes

		// Get the time (in minutes) to walk from one
		static func getTime(fromUserLocation userLocation: CLLocation, toObjectLocation objectLocation: CoordinateWithFloor) -> Int {
			// Get the distancse
			let distanceInMeters = getDistance(fromUserLocation: userLocation, toObjectLocation: objectLocation)
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
		static func getClosestObject(toUserLocation userLocation: CLLocation, forObjects objects: [AICObjectModel]) -> AICObjectModel {
			var closestObject: AICObjectModel?
			var closestDistance: Double = Double.greatestFiniteMagnitude

			for object in objects {
				let distance = getDistance(fromUserLocation: userLocation, toObjectLocation: object.location)
				if distance < closestDistance {
					closestObject = object
					closestDistance = distance
				}
			}

			return closestObject!
		}

		static func getDistance(fromUserLocation userLocation: CLLocation, toObjectLocation objectLocation: CoordinateWithFloor) -> Double {
			let objectCLLocation = CLLocation(latitude: objectLocation.coordinate.latitude, longitude: objectLocation.coordinate.longitude)
			return userLocation.distance(from: objectCLLocation)
		}

		static var hasLoggedOnsite: Bool = false
		static var previousOnSiteState: Bool?
		static var previousAuthorizationStatus: CLAuthorizationStatus = .notDetermined
	}

	// MARK: Home
	struct Home {
		static let maxNumberOfTours: Int = 6
		static let maxNumberOfExhibitions: Int = 6
		static let maxNumberOfEvents: Int = 8
	}

	// MARK: Tooltips
	struct Tooltips {
		static var mapPinchTooltip = AICTooltipModel(type: .popup,
													 title: "map_tutorial_explore_title".localized(using: "Map"),
													 text: "map_tutorial_explore_text".localized(using: "Map"),
													 arrowPosition: .zero,
													 image: #imageLiteral(resourceName: "tooltipPinch")
		)
		static var mapFloorTooltip = AICTooltipModel(type: .arrow,
													 title: "",
													 text: "map_tutorial_floor_picker_prompt".localized(using: "Map"),
													 arrowPosition: .zero,
													 image: nil
		)
		static var mapOrientationTooltip = AICTooltipModel(type: .arrow,
														   title: "",
														   text: "map_tutorial_orient_map".localized(using: "Map"),
														   arrowPosition: .zero,
														   image: nil
		)
		static var mapArtworkTooltip = AICTooltipModel(type: .popup,
													   title: "map_tutorial_audio_pins_title".localized(using: "Map"),
													   text: "map_tutorial_audio_pins_text".localized(using: "Map"),
													   arrowPosition: .zero,
													   image: #imageLiteral(resourceName: "tooltipArtwork")
		)
	}

	// MARK: Map
	struct Map {
		// Location Manager
		static let locationManager: CLLocationManager = CLLocationManager()

		static let totalFloors = 4
		static let startFloor = 1

		static var stringForFloorNumber: [Int: String] {
			return [
				0: "map_lower_level".localized(using: "Map"),
				1: "map_first_level".localized(using: "Map"),
				2: "map_second_level".localized(using: "Map"),
				3: "map_third_level".localized(using: "Map")]
		}

		// File directories
		static let mapsDirectory = "map"
		static let floorplanFileNamePrefix = "map_floor"
		static let amenityLandmarkSVGFileName = "map_amenities_landmarks"

		// Map SVG File
		static let mapSVGFileURL = Bundle.main.url(forResource: Common.Map.amenityLandmarkSVGFileName, withExtension: "svg", subdirectory: Common.Map.mapsDirectory)

		// Anchor pair for mapping GeoCoords to PDF Coords
		static let pdfSize = CGSize(width: 2400, height: 2400)
		static let anchor1 = GeoAnchor(latitudeLongitudeCoordinate: CLLocationCoordinate2DMake(41.88002009571711, -87.62398928403854),
									   pdfPoint: CGPoint(x: 855.955, y: pdfSize.height-1061.635)
		)

		static let anchor2 = GeoAnchor(latitudeLongitudeCoordinate: CLLocationCoordinate2DMake(41.8800240897643, -87.62334823608397),
									   pdfPoint: CGPoint(x: 1011.94, y: pdfSize.height-1061.635)
		)

		static let anchorPair = GeoAnchorPair(fromAnchor: anchor1, toAnchor: anchor2)

		static let coordinateConverter = CoordinateConverter(anchors: Common.Map.anchorPair)

		static let defaultLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 41.8796, longitude: -87.623533)

		enum ZoomLevelAltitude: Double {
			case zoomFarLimit = 1200
			case zoomLimit = 340.0
			case zoomDefault = 300.0
			case zoomMedium = 150.0
			case zoomDetail = 50.0
			case zoomMax = 25.0

			static let allValues = [zoomFarLimit, zoomLimit, zoomDefault, zoomMedium, zoomDetail, zoomMax]
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

		// Annotation view settings
		static let thumbSize: CGFloat = 54
		static let thumbHolderMargin: CGFloat = 2
	}

	// MARK: Info
	struct Info {

		// Text and URL constants
		static let becomeMemberExistingMemberTitle = "Welcome Back"

		static let museumInformationAddress = "111 S Michigan Ave\nChicago, IL 60603"
		static let museumInformationPhoneNumber = "+1 312 443 3600"
		static let museumInformationGetTicketsTitle = "Get Tickets"
		static let museumInformationGetTicketsURL = "https://sales.artic.edu/admissiondate"

		static let potionURL = "http://www.potiondesign.com"

		static let alertMessageNotFound = "Could not find Member Information"
		static let alertMessageParseError = "Member Card data parse error"
		static let alertMessageCancelButtonTitle = "OK"

		// Date formats
		static func throughDateString(endDate: Date) -> String {
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier: Common.currentLanguage.rawValue)
			dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
			return "content_through_date".localizedFormat(arguments: dateFormatter.string(from: endDate), using: "Base")
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
			if Common.currentLanguage == .english {
				dateFormatter.setLocalizedDateFormatFromTemplate("h:mma")
			} else {
				dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm")
			}
			if Common.currentLanguage == .english || Common.currentLanguage == .spanish {
				dateFormatter.amSymbol = "am"
				dateFormatter.pmSymbol = "pm"
			}
			let hoursMinutesString = dateFormatter.string(from: date)
			return hoursMinutesString
		}
	}

	// MARK: Search
	struct Search {
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
		case eventsEndpoint = "events_endpoint_v2"
		case autocompleteEndpoint = "autocomplete_endpoint"
		case toursEndpoint = "tours_endpoint"
		case multiSearchEndpoint = "multisearch_endpoint"
		case websiteUrl = "website_url"
		case membershipUrl = "membership_url"
		case ticketsUrl = "tickets_url"
	}
}
