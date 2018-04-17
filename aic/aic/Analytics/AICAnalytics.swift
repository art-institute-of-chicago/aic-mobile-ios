/*
 Abstract:
 Abstracted analytics centralized commands
 currently using Google Analytics
*/

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
		case search					= "search"
		case searchArtwork			= "search_artwork"
		case searchPlayArtwork		= "search_play_artwork"
		case searchTour				= "search_tour"
		case searchExhibition 		= "search_exhibition"
	}
	
	fileprivate enum Action : String {
		case appOpen				= "open"
		case appBackground			= "background"
		case appForeground			= "foreground"
		
		case languageSelected		= "selected"
		case languageChanged		= "changed"
		
		case locationOnSite			= "on_site"
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
		
		case searchLoaded			= "loaded"
		case searchAutocomplete		= "autocomplete"
		case searchPromoted			= "promoted"
		case searchNoResults		= "no_results"
		case searchAbandoned		= "abandoned"
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
		if let gai = GAI.sharedInstance(),
			let googleAnalyticsPlist = Bundle.main.path(forResource: "GoogleService-Info", ofType: ".plist"),
			let googleDict = NSDictionary(contentsOfFile: googleAnalyticsPlist),
			let trackingId = googleDict["TRACKING_ID"] as? String
		{
			gai.dispatchInterval = 30
			gai.trackUncaughtExceptions = false  // report uncaught exceptions
			#if APP_STORE
			gai.logger.logLevel = .error
			#else
			gai.logger.logLevel = .warning
			#endif
			AICAnalytics.tracker = gai.tracker(withTrackingId: trackingId)
		} else {
			assertionFailure("Google Analytics not configured correctly")
		}
		
		// Google Analytics Custom Dimensions
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
			AICAnalytics.tracker?.set(kGAIScreenName, value: screenName)
			let builder = GAIDictionaryBuilder.createScreenView()
			let dictionary = builder?.build() as NSDictionary?
			AICAnalytics.tracker?.send(dictionary as? [AnyHashable : Any])
			
			previousScreen = currentScreen
			currentScreen = screenName
		}
	}
	
	// MARK: Track Events
	
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
		AICAnalytics.tracker?.set(GAIFields.customDimension(for: property.rawValue), value: value)
	}
	
    // MARK: App
    
	static func sendAppOpenEvent() {
		trackEvent(category: .app, action: .appOpen)
    }
    
    static func sendAppForegroundEvent() {
		trackEvent(category: .app, action: .appForeground)
    }
    
    static func sendAppBackgroundEvent() {
		trackEvent(category: .app, action: .appBackground)
    }
	
	// MARK: Language
	
	static func sendLanguageSelectedEvent(language: Common.Language) {
		setUserProperty(property: .appLanguage, value: Common.stringForLanguage[language]!)
		trackEvent(category: .language, action: .languageSelected, label: Common.stringForLanguage[language]!)
	}
	
	static func sendLanguageChangedEvent(language: Common.Language) {
		setUserProperty(property: .appLanguage, value: Common.stringForLanguage[language]!)
		trackEvent(category: .language, action: .languageChanged, label: Common.stringForLanguage[language]!)
	}
	
	static func sendLanguageTourEvent(language: Common.Language, tour: AICTourModel) {
		trackEvent(category: .languageTour, action: Common.stringForLanguage[language]!, label: tour.translations[.english]!.title)
	}
	
	static func sendLanguageAudioEvent(language: Common.Language, audio: AICAudioFileModel) {
		trackEvent(category: .languageAudio, action: Common.stringForLanguage[language]!, label: audio.translations[.english]!.trackTitle)
	}
    
    // MARK: Location
    static func sendLocationEnableHeadingEvent() {
		trackEvent(category: .location, action: .locationHeadingEnabled)
    }
    
    static func sendLocationOnSiteEvent() {
		trackEvent(category: .location, action: .locationOnSite)
    }
	
	static func updateUserLocationProperty(isOnSite: Bool) {
		setUserProperty(property: .onSite, value: isOnSite ? "Yes" : "No")
	}
	
	// MARK: Audio Player
	static func sendPlayAudioFromMapEvent(artwork: AICObjectModel) {
		trackEvent(category: .playAudio, action: .playAudioMap, label: artwork.title)
	}
	
	static func sendPlayAudioFromAudioGuideEvent(artwork: AICObjectModel, selectorNumber: Int, language: Common.Language) {
		trackEvent(category: .playAudio, action: .playAudioAudioGuide, label: artwork.title)
	}
	
	static func sendPlayAudioFromTourEvent(tour: AICTourModel) {
		trackEvent(category: .playAudio, action: .playAudioTour, label: tour.translations[.english]!.title)
	}
	
	static func sendPlayAudioFromTourStopEvent(artwork: AICObjectModel, tour: AICTourModel) {
		trackEvent(category: .playAudio, action: .playAudioTourStop, label: artwork.title)
	}
	
	static func sendPlayAudioFromSearchedArtworkEvent(artwork: AICObjectModel) {
		trackEvent(category: .playAudio, action: .playAudioSearch, label: artwork.title)
	}
	
	// MARK: Playback
	
	static func sendPlaybackInterruptedEvent(audio: AICAudioFileModel, pctComplete: Int) {
		trackEvent(category: .playback, action: .playbackInterrupted, label: audio.translations[.english]!.trackTitle)
	}
	
	static func sendPlaybackCompletedEvent(audio: AICAudioFileModel) {
		trackEvent(category: .playback, action: .playbackCompleted, label: audio.translations[.english]!.trackTitle)
	}
    
    // MARK: Tours
    
	static func sendTourOpenedEvent(tour: AICTourModel) {
		trackEvent(category: .tour, action: .opened, label: tour.translations[.english]!.title)
	}
	
	static func sendTourStartedEvent(tour: AICTourModel) {
		trackEvent(category: .tour, action: .tourStarted, label: tour.translations[.english]!.title)
	}
	
	static func sendTourLeftEvent(tour: AICTourModel) {
		trackEvent(category: .tour, action: .tourLeft, label: tour.translations[.english]!.title)
	}
	
	// MARK: Exhibitions
	
	static func sendExhibitionOpenedEvent(exhibition: AICExhibitionModel) {
		trackEvent(category: .exhibition, action: .opened, label: exhibition.title)
	}
	
	static func sendExhibitionLinkPressedEvent(exhibition: AICExhibitionModel) {
		trackEvent(category: .exhibition, action: .linkPressed, label: exhibition.title)
	}
	
	// MARK: Events
	
	static func sendEventOpenedEvent(event: AICEventModel) {
		trackEvent(category: .event, action: .opened, label: event.title)
	}
	
	static func sendEventLinkPressedEvent(event: AICEventModel) {
		trackEvent(category: .event, action: .linkPressed, label: event.title)
	}
	
	// MARK: Map
	
	static func sendMapShowArtworkEvent(artwork: AICObjectModel) {
		trackEvent(category: .map, action: .mapShowArtwork, label: artwork.title)
	}
	
	static func sendMapShowSearchedArtworkEvent(searchedArtwork: AICSearchedArtworkModel) {
		trackEvent(category: .map, action: .mapShowArtwork, label: searchedArtwork.title)
	}
	
	static func sendMapShowExhibitionEvent(exhibition: AICExhibitionModel) {
		trackEvent(category: .map, action: .mapShowExhibition, label: exhibition.title)
	}
	
	static func sendMapShowDiningEvent() {
		trackEvent(category: .map, action: .mapShowDining)
	}
	
	static func sendMapShowMemberLoungeEvent() {
		trackEvent(category: .map, action: .mapShowMemberLounge)
	}
	
	static func sendMapShowGiftShopsEvent() {
		trackEvent(category: .map, action: .mapShowGiftShops)
	}
	
	static func sendMapShowRestroomsEvent() {
		trackEvent(category: .map, action: .mapShowRestrooms)
	}
	
    // MARK: Members
	
	static func sendMemberShowCardEvent() {
		setUserProperty(property: .membership, value: "Member")
		trackEvent(category: .member, action: .memberShowCard)
    }
	
    static func sendMemberJoinPressedEvent() {
		trackEvent(category: .member, action: .memberJoinPressed)
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
}
