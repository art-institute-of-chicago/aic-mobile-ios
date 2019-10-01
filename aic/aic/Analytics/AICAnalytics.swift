/*
 Abstract:
 Abstracted analytics centralized commands
 currently using Google Analytics
*/

import Firebase

class AICAnalytics {
	// Analytics tracker
	static fileprivate var tracker: GAITracker? = nil
	
	fileprivate enum Category : String {
		case app					= "app"
		case language				= "language"
		case languageTour			= "language_tour"
		case languageAudio			= "language_audio"
		case location				= "location"
		case playAudio				= "play_audio"
		case playback				= "playback"
		case tour					= "tour"
		case exhibition				= "exhibition"
		case event					= "event"
		case map					= "map"
		case member					= "member"
		case museumInfo				= "museum_info"
		case search					= "search"
		case searchArtwork			= "search_artwork"
		case searchPlayArtwork		= "search_play_artwork"
		case searchTour				= "search_tour"
		case searchExhibition 		= "search_exhibition"
		case errors					= "errors"
	}
	
	fileprivate enum Action : String {
		case appOpen				= "open"
		case appBackground			= "background"
		case appForeground			= "foreground"
		
		case languageSelected		= "selected"
		case languageChanged		= "changed"
		
		case locationOnSite			= "on_site"
		case locationOffSite		= "off_site"
		case locationDisabled		= "disabled"
		case locationNotNowPressed	= "not_now_pressed"
		case locationHeadingEnabled = "heading_enabled"
		
		case playAudioTour			= "tour"
		case playAudioTourStop		= "tour_stop"
		case playAudioAudioGuide	= "audio_guide"
		case playAudioMap			= "map"
		case playAudioSearch		= "search"
		
		case playbackInterrupted	= "interrupted"
		case playbackCompleted		= "completed"
		
		case tourStarted			= "started"
		case tourLeft				= "left"
		
		case opened					= "opened" 			// tour, exhibition and event Categories
		case linkPressed			= "link_pressed"	// exhibition and event Categories
		
		case mapShowExhibition		= "show_exhibition"
		case mapShowArtwork			= "show_artwork"
		case mapShowDining			= "show_dining"
		case mapShowMemberLounge	= "show_member_lounge"
		case mapShowGiftShops		= "show_gift_shops"
		case mapShowRestrooms		= "show_restrooms"
		
		case memberShowCard			= "show_card"
		case memberJoinPressed		= "join_pressed"
		
		case museumInfoPhoneLink	= "phone_link"
		case museumInfoAddressLink	= "address_link"
		
		case searchLoaded			= "loaded"
		case searchAutocomplete		= "autocomplete"
		case searchPromoted			= "promoted"
		case searchNoResults		= "no_results"
		case searchAbandoned		= "abandoned"
		case searchResultTapped		= "result_tapped"
		case searchCategorySwitched = "category_switched"
		
		case errorsAudioGuideWrongNumber = "audio_guide_wrong_number"
		case errorsAudioLoadFail 	= "audio_load_fail"
	}
	
	fileprivate enum Event : String {
		case appOpen				= "app_open"
		case languageFirstSelection	= "language_first_selection"
		case audioPlayed			= "audio_played"
		case audioStopped			= "audio_stopped"
		case tourStarted			= "tour_started"
		case tourLeft				= "tour_left"
		case eventViewed			= "event_viewed"
		case eventRegisterLink		= "event_register_link"
		case exhibitionViewed		= "exhibition_viewed"
		case exhibitionBuyLink		= "exhibition_buy_link"
		case exhibitionMap			= "exhibition_map"
		case artworkMap				= "artwork_map"
		case search					= "search"
		case searchNoResults		= "search_no_results"
		case searchAbandoned		= "search_abandoned"
		case searchTappedArtwork	= "search_tapped_artwork"
		case searchTappedTour		= "search_tapped_tour"
		case searchTappedExhibition	= "search_tapped_exhibition"
		case searchFacilities		= "search_facilities"
		case locationDetected		= "location_detected"
		case locationHeadingEnabled	= "location_heading_enabled"
		case memberCardShown		= "member_card_shown"
		case error					= "error"
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
	
	enum MiscLink : String {
		case InfoPhone = "Info Phone"
		case InfoAddress = "Info Address"
		case MemberJoin = "MemberJoin"
	}
	
	fileprivate enum UserProperty : UInt {
		case membership				= 2
		case appLanguage			= 3
		case deviceLanguage			= 4
		case onSite					= 5
	}
	
	static fileprivate var previousScreen: String? = nil
	static fileprivate var currentScreen: String? = nil
	static fileprivate var lastSearchText: String = ""
	
	static func configure() {
		
		FirebaseApp.configure()
		
		// Set User Properties
		let userDefaults = UserDefaults.standard
		let membership = userDefaults.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) != nil ? "Member" : "None"
		let deviceLanguage = NSLocale.preferredLanguages.first!
		setUserProperty(property: .membership, value: membership)
		setUserProperty(property: .appLanguage, value: Common.stringForLanguage[Common.currentLanguage]!)
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
	
	private static func trackEvent(category: Category, action: Action, label: String = "", value: Int = 0) {
		trackEvent(category: category.rawValue, action: action.rawValue, label: label, value: value)
	}
	
	private static func trackEvent(category: Category, action: String, label: String = "", value: Int = 0) {
		trackEvent(category: category.rawValue, action: action, label: label, value: value)
	}
	
	private static func trackEvent(category: String, action: String, label: String = "", value: Int = 0) {
		let event = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: NSNumber(value: value as Int)).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	// MARK: Set User Property
	
	private static func setUserProperty(property: UserProperty, value: String) {
		//Analytics.setUserProperty(<#T##value: String?##String?#>, forName: <#T##String#>)
		//AICAnalytics.tracker?.set(GAIFields.customDimension(for: property.rawValue), value: value)
	}
	
	// MARK: App
	
	static func sendAppOpenEvent(location: LocationState) {
		let parameters: [String : String] = [
			"location" : location.rawValue,
			"language" : Common.stringForLanguage[Common.currentLanguage]!
		]
		trackEvent(.appOpen, parameters: parameters)
	}
	
	// MARK: Language
	
	static func sendLanguageFirstSelectionEvent(language: Common.Language) {
		setUserProperty(property: .appLanguage, value: Common.stringForLanguage[language]!)
		trackEvent(.languageFirstSelection, parameters: ["start_language" : Common.stringForLanguage[language]!])
	}
	
	static func updateLanguageSelection(language: Common.Language) {
		setUserProperty(property: .appLanguage, value: Common.stringForLanguage[language]!)
	}
	
	// MARK: Location
	
	static func sendLocationEnableHeadingEvent() {
		trackEvent(.locationHeadingEnabled)
	}
	
	static func sendLocationDetectedEvent(location: LocationState) {
		trackEvent(.locationDetected, parameters: ["location" : location.rawValue])
	}
	
	static func updateUserLocationProperty(isOnSite: Bool?) {
		if isOnSite != nil {
			setUserProperty(property: .onSite, value: isOnSite! ? "Yes" : "No")
		}
		else {
			setUserProperty(property: .onSite, value: "Undefined")
		}
	}
	
	// MARK: Audio Player
	
	static func sendAudioPlayedEvent(source: PlaybackSource, language: Common.Language, artwork: AICObjectModel?, tour: AICTourModel?) {
		var parameters: [String : String] = [
			"playback_source" : source.rawValue,
			"playback_language" : Common.stringForLanguage[language]!
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
		trackEvent(.audioPlayed, parameters: parameters)
	}
	
	// MARK: Tours
	
	static func sendTourStartedEvent(tour: AICTourModel, language: Common.Language) {
		let parameters: [String : String] = [
			"title" : tour.translations[.english]!.title,
			"tour_language" : Common.stringForLanguage[language]!
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
		trackEvent(.exhibitionViewed, parameters: ["title" : exhibition.title])
	}
	
	static func sendExhibitionBuyLinkEvent(exhibition: AICExhibitionModel) {
		trackEvent(.exhibitionBuyLink, parameters: ["title" : exhibition.title])
	}
	
	static func sendExhibitionMapEvent(exhibition: AICExhibitionModel) {
		trackEvent(.exhibitionMap, parameters: ["title" : exhibition.title])
	}
	
	// MARK: Events
	
	static func sendEventViewedEvent(event: AICEventModel) {
		trackEvent(.eventViewed, parameters: ["title" : event.title])
	}
	
	static func sendEventRegisterLinkEvent(event: AICEventModel) {
		trackEvent(.eventRegisterLink, parameters: ["title" : event.title])
	}
	
	// MARK: Artwork
	
	static func sendArtworkMapEvent(artwork: AICObjectModel) {
		trackEvent(.artworkMap, parameters: ["title" : artwork.title])
	}
	
	static func sendArtworkMapEvent(searchedArtwork: AICSearchedArtworkModel) {
		trackEvent(.artworkMap, parameters: ["title" : searchedArtwork.title])
	}
	
	// MARK: Search Facilities
	
	static func sendSearchFacilitiesEvent(facility: Facility) {
		trackEvent(.searchFacilities, parameters: ["facility" : facility.rawValue])
	}
	
	// MARK: Members
	
	static func sendMemberCardShownEvent() {
		setUserProperty(property: .membership, value: "Member")
		trackEvent(.memberCardShown)
	}
	
	// MARK: Misc Links
	
	static func sendMiscLinkTappedEvent(link: MiscLink) {
		trackEvent(.miscLinkTapped, parameters: ["link" : link.rawValue])
	}
	
	// MARK: Search
	
	static func sendSearchLoadedEvent(searchText: String, isAutocompleteString: Bool, isPromotedString: Bool) {
		if searchText != lastSearchText {
			lastSearchText = searchText
			
			if isAutocompleteString == true {
				trackEvent(category: .search, action: .searchAutocomplete, label: searchText)
			}
			else if isPromotedString == true {
				trackEvent(category: .search, action: .searchPromoted, label: searchText)
			}
			else {
				trackEvent(category: .search, action: .searchLoaded, label: searchText)
			}
		}
	}
	
	static func sendSearchNoResultsEvent(searchText: String) {
		trackEvent(category: .search, action: .searchNoResults, label: searchText)
	}
	
	static func sendSearchAbandonedEvent(searchText: String) {
		trackEvent(category: .search, action: .searchAbandoned, label: searchText)
	}
	
	static func sendSearchResultTappedEvent(searchText: String) {
		trackEvent(category: .search, action: .searchResultTapped, label: searchText)
	}
	
	static func sendSearchCategorySwitchedEvent(category: String) {
		trackEvent(category: .search, action: .searchCategorySwitched, label: category)
	}
	
	// MARK: Search Selected Content
	
	static func sendSearchSelectedArtworkEvent(searchedArtwork: AICSearchedArtworkModel, searchText: String) {
		trackEvent(category: .searchArtwork, action: searchedArtwork.title, label: searchText)
	}
	
	static func sendSearchArtworkAndPlayedAudioEvent(artwork: AICObjectModel, searchText: String) {
		trackEvent(category: .searchPlayArtwork, action: artwork.title, label: searchText)
	}
	
	static func sendSearchSelectedTourEvent(tour: AICTourModel, searchText: String) {
		trackEvent(category: .searchTour, action: tour.translations[.english]!.title, label: searchText)
	}
	
	static func sendSearchSelectedExhibitionEvent(exhibition: AICExhibitionModel, searchText: String) {
		trackEvent(category: .searchExhibition, action: exhibition.title, label: searchText)
	}
	
	// MARK: Errors
	
	static func sendErrorAudioGuideBadNumberEvent(number: Int) {
		let parameters: [String : String] = [
			"type" : "Bad Number",
			"code" : String(number)
		]
		trackEvent(.error, parameters: parameters)
	}
	
	static func sendErrorAudioLoadFailEvent(number: Int) {
		let parameters: [String : String] = [
			"type" : "Audio Load Fail",
			"code" : String(number)
		]
		trackEvent(.error, parameters: parameters)
	}
}
