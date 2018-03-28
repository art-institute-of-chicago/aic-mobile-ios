/*
 Abstract:
 Abstracted analytics centralized commands
 currently using Google Analytics
*/

import Firebase

class AICAnalytics {
	
	fileprivate enum Event : String {
		case appOpen				= "app_open"
		case appBackground			= "app_background"
		case appForeground			= "app_foreground"
		
		case locationOnSite			= "location_on_site"
		case locationDidEnableHeading = "location_heading_enabled"
		
		case languageSelected		= "language_selected"
		case languageChanged		= "language_changed"
		
		case playAudio		 		= "play_audio"
		case playInterrupted		= "playback_interrupted"
		case playCompleted			= "playback_completed"
		
//		case artworkOpened			= "artwork_opened"
		case tourOpened				= "tour_opened" // tour_title: ...
		case tourStarted			= "tour_started" // source: {related_tours, } // language: ... // start: {overview, artworkTitle}
		case tourLeft				= "tour_left"
		
		case exhibitionOpened		= "exhibition_opened" // exhibition_title: ...
		case exhibitionLinkPressed	= "exhibition_link_pressed"
		
		case eventOpened			= "event_opened" // event_title: ...
		case eventLinkPressed		= "event_link_pressed"
		
		case mapShowExhibition		= "map_show_exhibition" // exhibition_title: ...
		case mapShowArtwork			= "map_show_artwork" // artwork_title: ...
		case mapShowDining			= "map_show_dining"
		case mapShowMemberLounge	= "map_show_member_lounge"
		case mapShowGiftShops		= "map_show_gift_shops"
		case mapShowRestrooms		= "map_show_restrooms"
		
		case memberShowCard			= "member_show_card"
		case memberJoinPressed		= "member_join_pressed"
		
		case searchLoaded			= "search_loaded"
		case searchSelectedArtwork	= "search_selected_artwork"
		case searchSelectedTour		= "search_selected_tour"
		case searchSelectedExhibition = "search_selected_exhibition"
	}
	
    static fileprivate var previousScreen: String? = nil
	static fileprivate var previousScreenClass: String? = nil
    static fileprivate var currentScreen: String? = nil
	static fileprivate var lastSearchText: String = ""
    
    static func configure() {
        FirebaseApp.configure()
		
		// User Properties
		
		var membership = "None"
		if UserDefaults.standard.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) != nil {
			membership = "Member"
		}
		Analytics.setUserProperty(membership, forName: "Membership")
		
		Analytics.setUserProperty(Common.stringForLanguage[Common.currentLanguage], forName: "AppLanguage")
		
		if let deviceLanguage = NSLocale.preferredLanguages.first {
			Analytics.setUserProperty(deviceLanguage, forName: "DeviceLanguage")
		}
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
	
    // MARK: App
    
	static func sendAppOpenEvent() {
		Analytics.logEvent(Event.appOpen.rawValue, parameters: nil)
    }
    
    static func sendAppForegroundEvent() {
		Analytics.logEvent(Event.appForeground.rawValue, parameters: nil)
    }
    
    static func sendAppBackgroundEvent() {
		Analytics.logEvent(Event.appBackground.rawValue, parameters: nil)
    }
	
	// MARK: Language
	
	static func sendLanguageSelectedEvent(language: Common.Language) {
		Analytics.setUserProperty(Common.stringForLanguage[language], forName: "AppLanguage")
		Analytics.logEvent(Event.languageSelected.rawValue, parameters: [
			"language": Common.stringForLanguage[language]! as NSObject
		])
	}
	
	static func sendLanguageChangedEvent(language: Common.Language) {
		Analytics.setUserProperty(Common.stringForLanguage[language], forName: "AppLanguage")
		Analytics.logEvent(Event.languageChanged.rawValue, parameters: [
			"language": Common.stringForLanguage[language]! as NSObject
		])
	}
    
    // MARK: Location
    static func sendLocationEnableHeadingEvent() {
		Analytics.logEvent(Event.locationDidEnableHeading.rawValue, parameters: nil)
    }
    
    static func sendLocationOnSiteEvent() {
		Analytics.logEvent(Event.locationOnSite.rawValue, parameters: nil)
    }
	
	static func updateUserLocationProperty(isOnSite: Bool) {
		Analytics.setUserProperty(isOnSite ? "Yes" : "No", forName: "OnSite")
	}
	
	// MARK: Audio Player
	static func sendPlayAudioFromMapEvent(artwork: AICObjectModel) {
		Analytics.logEvent(Event.playAudio.rawValue, parameters: [
			AnalyticsParameterItemID: artwork.nid as NSObject,
			AnalyticsParameterItemName: artwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject,
			AnalyticsParameterSource: "map" as NSObject
		])
	}
	
	static func sendPlayAudioFromAudioGuideEvent(artwork: AICObjectModel, selectorNumber: Int, language: Common.Language) {
		Analytics.logEvent(Event.playAudio.rawValue, parameters: [
			AnalyticsParameterItemID: artwork.nid as NSObject,
			AnalyticsParameterItemName: artwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject,
			AnalyticsParameterSource: "audio_guide" as NSObject,
			"selector_number": selectorNumber as NSObject,
			"language": Common.stringForLanguage[language]! as NSObject
		])
	}
	
	static func sendPlayAudioFromTourEvent(artwork: AICObjectModel, tour: AICTourModel) {
		Analytics.logEvent(Event.playAudio.rawValue, parameters: [
			AnalyticsParameterItemID: artwork.nid as NSObject,
			AnalyticsParameterItemName: artwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject,
			AnalyticsParameterSource: "tour" as NSObject,
			"tour_name": tour.translations[.english]!.title as NSObject,
			"language": Common.stringForLanguage[tour.language]! as NSObject
		])
	}
	
	static func sendPlayAudioFromTourOverviewEvent(tour: AICTourModel) {
		Analytics.logEvent(Event.playAudio.rawValue, parameters: [
			AnalyticsParameterItemID: tour.nid as NSObject,
			AnalyticsParameterItemName: tour.translations[.english]!.title as NSObject,
			AnalyticsParameterContentType: "tour" as NSObject,
			AnalyticsParameterSource: "tour" as NSObject,
			"tour_name": tour.translations[.english]!.title as NSObject,
			"language": Common.stringForLanguage[tour.language]! as NSObject
		])
	}
	
	static func sendPlayAudioFromSearchedArtworkEvent(artwork: AICObjectModel) {
		Analytics.logEvent(Event.playAudio.rawValue, parameters: [
			AnalyticsParameterItemID: artwork.nid as NSObject,
			AnalyticsParameterItemName: artwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject,
			AnalyticsParameterSource: "search" as NSObject
		])
	}
	
	static func sendPlaybackInterruptedEvent(audio: AICAudioFileModel, pctComplete: Int) {
		Analytics.logEvent(Event.playInterrupted.rawValue, parameters: [
			AnalyticsParameterItemID: audio.nid as NSObject,
			AnalyticsParameterItemName: audio.translations[.english]!.trackTitle as NSObject,
			AnalyticsParameterContentType: "audio" as NSObject,
			"percent_completed": pctComplete as NSObject
		])
	}
	
	static func sendPlaybackCompletedEvent(audio: AICAudioFileModel) {
		Analytics.logEvent(Event.playCompleted.rawValue, parameters: [
			AnalyticsParameterItemID: audio.nid as NSObject,
			AnalyticsParameterItemName: audio.translations[.english]!.trackTitle as NSObject,
			AnalyticsParameterContentType: "audio" as NSObject
		])
	}
    
    // MARK: Tours
    
	static func sendTourOpenedEvent(tour: AICTourModel) {
		Analytics.logEvent(Event.tourOpened.rawValue, parameters: [
			AnalyticsParameterItemID: tour.nid as NSObject,
			AnalyticsParameterItemName: tour.translations[.english]!.title as NSObject,
			AnalyticsParameterContentType: "tour" as NSObject,
			"language": Common.stringForLanguage[tour.language]! as NSObject
		])
	}
	
	static func sendTourStartedEvent(tour: AICTourModel, source: String, tourStopIndex: Int?) {
		var start = "overview"
		if let stopIndex = tourStopIndex {
			if stopIndex < tour.stops.count {
				start = tour.stops[stopIndex].object.title
			}
		}
		
		Analytics.logEvent(Event.tourStarted.rawValue, parameters: [
			AnalyticsParameterItemID: tour.nid as NSObject,
			AnalyticsParameterItemName: tour.translations[.english]!.title as NSObject,
			AnalyticsParameterContentType: "tour" as NSObject,
			AnalyticsParameterSource: source as NSObject,
			"language": Common.stringForLanguage[tour.language]! as NSObject,
			"start": start as NSObject
		])
	}
	
	static func sendTourLeftEvent(tour: AICTourModel) {
		Analytics.logEvent(Event.tourLeft.rawValue, parameters: [
			AnalyticsParameterItemID: tour.nid as NSObject,
			AnalyticsParameterItemName: tour.translations[.english]!.title as NSObject,
			AnalyticsParameterContentType: "tour" as NSObject,
			"language": Common.stringForLanguage[tour.language]! as NSObject
		])
	}
	
	// MARK: Exhibitions
	
	static func sendExhibitionOpenedEvent(exhibition: AICExhibitionModel) {
		Analytics.logEvent(Event.exhibitionOpened.rawValue, parameters: [
			AnalyticsParameterItemID: exhibition.id as NSObject,
			AnalyticsParameterItemName: exhibition.title as NSObject,
			AnalyticsParameterContentType: "exhibition" as NSObject
		])
	}
	
	static func sendExhibitionLinkPressedEvent(exhibition: AICExhibitionModel) {
		Analytics.logEvent(Event.exhibitionLinkPressed.rawValue, parameters: [
			AnalyticsParameterItemID: exhibition.id as NSObject,
			AnalyticsParameterItemName: exhibition.title as NSObject,
			AnalyticsParameterContentType: "exhibition" as NSObject
		])
	}
	
	// MARK: Events
	
	static func sendEventOpenedEvent(event: AICEventModel) {
		Analytics.logEvent(Event.eventOpened.rawValue, parameters: [
			AnalyticsParameterItemID: event.eventId as NSObject,
			AnalyticsParameterItemName: event.title as NSObject,
			AnalyticsParameterContentType: "event" as NSObject
		])
	}
	
	static func sendEventLinkPressedEvent(event: AICEventModel) {
		Analytics.logEvent(Event.eventLinkPressed.rawValue, parameters: [
			AnalyticsParameterItemID: event.eventId as NSObject,
			AnalyticsParameterItemName: event.title as NSObject,
			AnalyticsParameterContentType: "event" as NSObject
		])
	}
	
	// MARK: Map
	
	static func sendMapShowArtworkEvent(artwork: AICObjectModel) {
		Analytics.logEvent(Event.mapShowArtwork.rawValue, parameters: [
			AnalyticsParameterItemID: artwork.nid as NSObject,
			AnalyticsParameterItemName: artwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject
		])
	}
	
	static func sendMapShowSearchedArtworkEvent(searchedArtwork: AICSearchedArtworkModel) {
		Analytics.logEvent(Event.mapShowArtwork.rawValue, parameters: [
			AnalyticsParameterItemID: searchedArtwork.artworkId as NSObject,
			AnalyticsParameterItemName: searchedArtwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject
		])
	}
	
	static func sendMapShowExhibitionEvent(exhibition: AICExhibitionModel) {
		Analytics.logEvent(Event.mapShowExhibition.rawValue, parameters: [
			AnalyticsParameterItemID: exhibition.id as NSObject,
			AnalyticsParameterItemName: exhibition.title as NSObject,
			AnalyticsParameterContentType: "exhibition" as NSObject
		])
	}
	
	static func sendMapShowDiningEvent() {
		Analytics.logEvent(Event.mapShowDining.rawValue, parameters: nil)
	}
	
	static func sendMapShowMemberLoungeEvent() {
		Analytics.logEvent(Event.mapShowMemberLounge.rawValue, parameters: nil)
	}
	
	static func sendMapShowGiftShopsEvent() {
		Analytics.logEvent(Event.mapShowGiftShops.rawValue, parameters: nil)
	}
	
	static func sendMapShowRestroomsEvent() {
		Analytics.logEvent(Event.mapShowRestrooms.rawValue, parameters: nil)
	}
	
    // MARK: Members
	
	static func sendMemberShowCardEvent() {
		Analytics.setUserProperty("Member", forName: "Membership")
		Analytics.logEvent(Event.memberShowCard.rawValue, parameters: nil)
    }
	
    static func sendMemberJoinPressedEvent() {
		Analytics.logEvent(Event.memberJoinPressed.rawValue, parameters: nil)
    }
	
	// MARK: Search
	
	static func sendSearchLoadedEvent(searchText: String, isAutocompleteString: Bool, isPromotedString: Bool) {
		if searchText != lastSearchText {
			lastSearchText = searchText
			
			Analytics.logEvent(Event.searchLoaded.rawValue, parameters: [
				"searchText": searchText as NSObject,
				"is_autocomplete": (isAutocompleteString ? "true" : "false") as NSObject,
				"is_promoted": (isPromotedString ? "true" : "false") as NSObject
			])
		}
	}
	
	static func sendSearchSelectedArtworkEvent(searchedArtwork: AICSearchedArtworkModel, searchText: String) {
		Analytics.logEvent(Event.searchSelectedArtwork.rawValue, parameters: [
			AnalyticsParameterItemID: searchedArtwork.artworkId as NSObject,
			AnalyticsParameterItemName: searchedArtwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject,
			"searchText": searchText as NSObject
		])
	}
	
	static func sendSearchSelectedTourEvent(tour: AICTourModel, searchText: String) {
		Analytics.logEvent(Event.searchSelectedTour.rawValue, parameters: [
			AnalyticsParameterItemID: tour.nid as NSObject,
			AnalyticsParameterItemName: tour.translations[.english]!.title as NSObject,
			AnalyticsParameterContentType: "tour" as NSObject,
			"searchText": searchText as NSObject
		])
	}
	
	static func sendSearchSelectedExhibitionEvent(exhibition: AICExhibitionModel, searchText: String) {
		Analytics.logEvent(Event.searchSelectedExhibition.rawValue, parameters: [
			AnalyticsParameterItemID: exhibition.id as NSObject,
			AnalyticsParameterItemName: exhibition.title as NSObject,
			AnalyticsParameterContentType: "exhibition" as NSObject,
			"searchText": searchText as NSObject
		])
	}
}
