/*
 Abstract:
 Abstracted analytics centralized commands
 currently using Google Analytics
*/

import Firebase

class AICAnalytics {
	
	fileprivate enum Event : String {
		case appOpen				= "app_open"
		case languageFirstSelection	= "language_first_selection"
		case audioPlayed			= "audio_played"
		case audioStopped			= "audio_stopped"
        case audioError             = "audio_error"
		case tourStarted			= "tour_started"
		case tourLeft				= "tour_left"
		case eventViewed			= "event_viewed"
		case eventRegisterLink		= "event_register_link"
		case exhibitionViewed		= "exhibition_viewed"
		case exhibitionBuyLink		= "exhibition_buy_link"
		case exhibitionMap			= "exhibition_map"
		case search					= "search"
		case searchNoResults		= "search_no_results"
		case searchAbandoned		= "search_abandoned"
		case searchTappedArtwork	= "search_tapped_artwork"
		case searchTappedTour		= "search_tapped_tour"
		case searchTappedExhibition	= "search_tapped_exhibition"
		case searchFacilities		= "search_facilities"
        case searchArtworkMap       = "search_artwork_map"
        case searchIconMap          = "search_icon_map"
		case locationDetected		= "location_detected"
		case locationHeadingEnabled	= "location_heading_enabled"
		case memberCardShown		= "member_card_shown"
		case miscLinkTapped			= "misc_link_tapped"
	}
	
	enum PlaybackSource : String {
		case Map = "Map"
		case AudioGuide = "Audio Guide"
		case Search = "Search"
		case SearchIcon = "Search Icon"
		case TourStop = "Tour Stop"
	}
	
	enum PlaybackCompletion : String {
		case Completed = "Completed"
		case Interrupted = "Interrupted"
	}
	
	enum Facility : String {
		case Dining = "Dining"
		case MemberLounge = "Lounge"
		case GiftShop = "Gift Shop"
		case Restroom = "Restroom"
	}
	
	enum LocationState : String {
		case Disabled = "Disabled"
		case NotNow = "Not Now"
		case OffSite = "Off Site"
		case OnSite = "On Site"
	}
	
	enum SearchTermSource : String {
		case TextInput = "Text Input"
		case Promoted = "Promoted Text"
		case Autocomplete = "Autocomplete Suggestion"
	}
	
	enum MiscLink : String {
		case InfoPhone = "Info Phone"
		case InfoAddress = "Info Address"
		case MemberJoin = "MemberJoin"
	}
	
	fileprivate enum UserProperty : String {
        case membership				= "Membership"
		case appLanguage			= "Language"
		case deviceLanguage			= "DeviceLanguage"
	}
	
	static fileprivate var previousScreen: String? = nil
	static fileprivate var currentScreen: String? = nil
	static fileprivate var lastSearchTerm: String = ""
	
	static func configure() {
		
		FirebaseApp.configure()
		
		// Set User Properties
		let userDefaults = UserDefaults.standard
		let membership = userDefaults.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) != nil ? "Member" : "None"
		let deviceLanguage = NSLocale.preferredLanguages.first!
        let languageString: String = Common.stringForLanguage[Common.currentLanguage]!
		setUserProperty(property: .membership, value: membership)
		setUserProperty(property: .appLanguage, value: languageString)
		setUserProperty(property: .deviceLanguage, value: deviceLanguage)
	}
	
	// MARK: Track Screens
	
	static func trackScreenView(_ screenName: String, screenClass: String) {
		if screenName != currentScreen {
			Analytics.setScreenName(screenName, screenClass: screenClass)

			previousScreen = currentScreen
			currentScreen = screenName
		}
	}
	
	// MARK: Track Events
	
	private static func trackEvent(_ event: Event, parameters: [String : String]? = nil) {
		Analytics.logEvent(event.rawValue, parameters: parameters)
	}
	
	// MARK: Set User Property
	
	private static func setUserProperty(property: UserProperty, value: String) {
        Analytics.setUserProperty(value, forName: property.rawValue)
	}
	
	// MARK: App
	
	static func sendAppOpenEvent(location: LocationState) {
        let languageString: String = Common.stringForLanguage[Common.currentLanguage]!
		let parameters: [String : String] = [
			"location" : location.rawValue,
			"language" : languageString
		]
		trackEvent(.appOpen, parameters: parameters)
	}
	
	// MARK: Language
	
	static func sendLanguageFirstSelectionEvent(language: Common.Language) {
		let languageString: String = Common.stringForLanguage[language]!
        setUserProperty(property: .appLanguage, value: languageString)
        let parameters: [String : String] = [
            "start_language" : languageString
        ]
		trackEvent(.languageFirstSelection, parameters: parameters)
	}
	
	static func updateLanguageSelection(language: Common.Language) {
        let languageString: String = Common.stringForLanguage[language]!
		setUserProperty(property: .appLanguage, value: languageString)
	}
	
	// MARK: Location
	
	static func sendLocationEnableHeadingEvent() {
		trackEvent(.locationHeadingEnabled)
	}
	
	static func sendLocationDetectedEvent(location: LocationState) {
		let parameters: [String : String] = [
			"location" : location.rawValue
		]
		trackEvent(.locationDetected, parameters: parameters)
	}
	
	static func updateUserLocationProperty(isOnSite: Bool?) {
//		if isOnSite != nil {
//			setUserProperty(property: .onSite, value: isOnSite! ? "Yes" : "No")
//		}
//		else {
//			setUserProperty(property: .onSite, value: "Undefined")
//		}
	}
	
	// MARK: Audio Player
	
	static func sendAudioPlayedEvent(source: PlaybackSource, language: Common.Language, artwork: AICObjectModel?, tour: AICTourModel?) {
        let languageString: String = Common.stringForLanguage[language]!
		var parameters: [String : String] = [
			"playback_source" : source.rawValue,
			"playback_language" : languageString
		]
		if let artworkModel: AICObjectModel = artwork {
			parameters["title"] = artworkModel.title
		}
		if let tourModel: AICTourModel = tour {
			parameters["tour_title"] = tourModel.translations[.english]!.title
		}
		trackEvent(.audioPlayed, parameters: parameters)
	}
	
	static func sendAudioStoppedEvent(audio: AICAudioFileModel, percentPlayed: Int) {
		let percent = percentPlayed > 95 ? 100 : percentPlayed
		let parameters: [String : String] = [
			"title" : audio.translations[.english]!.trackTitle,
			"completion" : percent == 100 ? PlaybackCompletion.Completed.rawValue : PlaybackCompletion.Interrupted.rawValue,
			"percent_played" : String(percent)
		]
		trackEvent(.audioStopped, parameters: parameters)
	}
    
    // MARK: Audio Errors
    
    static func sendErrorAudioGuideBadNumberEvent(number: Int) {
        let parameters: [String : String] = [
            "type" : "Bad Number",
            "code" : String(number)
        ]
        trackEvent(.audioError, parameters: parameters)
    }
    
    static func sendErrorAudioLoadFailEvent(number: Int) {
        let parameters: [String : String] = [
            "type" : "Audio Load Fail",
            "code" : String(number)
        ]
        trackEvent(.audioError, parameters: parameters)
    }
	
	// MARK: Tours
	
	static func sendTourStartedEvent(tour: AICTourModel, language: Common.Language) {
        let languageString: String = Common.stringForLanguage[language]!
		let parameters: [String : String] = [
			"title" : tour.translations[.english]!.title,
			"tour_language" : languageString
		]
		trackEvent(.tourStarted, parameters: parameters)
	}
	
	static func sendTourLeftEvent(tour: AICTourModel) {
		let parameters: [String : String] = [
			"title" : tour.translations[.english]!.title
		]
		trackEvent(.tourLeft, parameters: parameters)
	}
	
	// MARK: Exhibitions
	
	static func sendExhibitionViewedEvent(exhibition: AICExhibitionModel) {
		let parameters: [String : String] = [
			"title" : exhibition.title
		]
		trackEvent(.exhibitionViewed, parameters: parameters)
	}
	
	static func sendExhibitionBuyLinkEvent(exhibition: AICExhibitionModel) {
		let parameters: [String : String] = [
			"title" : exhibition.title
		]
		trackEvent(.exhibitionBuyLink, parameters: parameters)
	}
	
	static func sendExhibitionMapEvent(exhibition: AICExhibitionModel) {
		let parameters: [String : String] = [
			"title" : exhibition.title
		]
		trackEvent(.exhibitionMap, parameters: parameters)
	}
	
	// MARK: Events
	
	static func sendEventViewedEvent(event: AICEventModel) {
		let parameters: [String : String] = [
			"title" : event.title
		]
		trackEvent(.eventViewed, parameters: parameters)
	}
	
	static func sendEventRegisterLinkEvent(event: AICEventModel) {
		let parameters: [String : String] = [
			"title" : event.title
		]
		trackEvent(.eventRegisterLink, parameters: parameters)
	}
	
	// MARK: Members
	
	static func sendMemberCardShownEvent() {
		setUserProperty(property: .membership, value: "Member")
		trackEvent(.memberCardShown)
	}
	
	// MARK: Misc Links
	
	static func sendMiscLinkTappedEvent(link: MiscLink) {
		let parameters: [String : String] = [
			"link" : link.rawValue
		]
		trackEvent(.miscLinkTapped, parameters: parameters)
	}
	
	// MARK: Search
	
	static func sendSearchEvent(searchTerm: String, searchTermSource: SearchTermSource) {
		if searchTerm != lastSearchTerm {
			lastSearchTerm = searchTerm
			
			let parameters: [String : String] = [
				"search_term" : searchTerm,
				"search_term_source" : searchTermSource.rawValue
			]
			trackEvent(.search, parameters: parameters)
		}
	}
	
	static func sendSearchNoResultsEvent(searchTerm: String, searchTermSource: SearchTermSource) {
		let parameters: [String : String] = [
			"search_term" : searchTerm,
			"search_term_source" : searchTermSource.rawValue
		]
		trackEvent(.searchNoResults, parameters: parameters)
	}
	
	static func sendSearchAbandonedEvent(searchTerm: String, searchTermSource: SearchTermSource) {
		let parameters: [String : String] = [
			"search_term" : searchTerm,
			"search_term_source" : searchTermSource.rawValue
		]
		trackEvent(.searchAbandoned, parameters: parameters)
	}
	
	// MARK: Search Tapped Content
	
	static func sendSearchTappedArtworkEvent(searchedArtwork: AICSearchedArtworkModel, searchTerm: String, searchTermSource: SearchTermSource) {
		let parameters: [String : String] = [
			"title" : searchedArtwork.title,
			"search_term" : searchTerm,
			"search_term_source" : searchTermSource.rawValue
		]
		trackEvent(.searchTappedArtwork, parameters: parameters)
	}
	
	static func sendSearchTappedTourEvent(tour: AICTourModel, searchTerm: String, searchTermSource: SearchTermSource) {
		let parameters: [String : String] = [
			"title" : tour.translations[.english]!.title,
			"search_term" : searchTerm,
			"search_term_source" : searchTermSource.rawValue
		]
		trackEvent(.searchTappedTour, parameters: parameters)
	}
	
	static func sendSearchTappedExhibitionEvent(exhibition: AICExhibitionModel, searchTerm: String, searchTermSource: SearchTermSource) {
		let parameters: [String : String] = [
			"title" : exhibition.title,
			"search_term" : searchTerm,
			"search_term_source" : searchTermSource.rawValue
		]
		trackEvent(.searchTappedExhibition, parameters: parameters)
	}
    
    // MARK: Search Facilities
    
    static func sendSearchFacilitiesEvent(facility: Facility) {
        let parameters: [String : String] = [
            "facility" : facility.rawValue
        ]
        trackEvent(.searchFacilities, parameters: parameters)
    }
    
    // MARK: Search Artwork Map
    
    static func sendSearchArtworkMapEvent(searchedArtwork: AICSearchedArtworkModel) {
        let parameters: [String : String] = [
            "title" : searchedArtwork.title
        ]
        trackEvent(.searchArtworkMap, parameters: parameters)
    }
    
    // MARK: Search Icon Map
    
    static func sendSearchIconMapEvent(artwork: AICObjectModel) {
        let parameters: [String : String] = [
            "title" : artwork.title
        ]
        trackEvent(.searchIconMap, parameters: parameters)
    }
}
