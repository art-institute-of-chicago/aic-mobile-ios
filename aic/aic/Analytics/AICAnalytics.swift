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
		
		case playAudio		 		= "play_audio"
		case playInterrupted		= "playback_interrupted"
		case playCompleted			= "playback_completed"
		
//		case artworkOpened			= "artwork_opened"
		case tourOpened				= "tour_opened" // tour_title: ...
		case tourStarted			= "tour_started" // source: {link, search, card} // language: ... // start: {overview, artworkTitle}
		case tourLeft				= "tour_left"
		
		case exhibitionOpened		= "exhibition_opened" // exhibition_title: ...
		
		case eventOpened			= "event_opened" // event_title: ...
		
		case mapShowExhibition		= "map_show_exhibition" // exhibition_title: ...
		case mapShowArtwork			= "map_show_artwork" // artwork_title: ...
		case mapShowDining			= "map_show_dining"
		case mapShowMemberLounge	= "map_show_member_lounge"
		case mapShowGiftShops		= "map_show_gift_shops"
		case mapShowRestrooms		= "map_show_restrooms"
		
		case memberShowCard			= "member_show_card"
		case memberJoinPressed		= "member_join_pressed"
	}
	
    static fileprivate var previousScreen: String? = nil
	static fileprivate var previousScreenClass: String? = nil
    static fileprivate var currentScreen: String? = nil
    
    static func configure() {
        FirebaseApp.configure()
		
		// User Properties
		
		var membership = "None"
		if let _ = UserDefaults.standard.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) as? NSNumber {
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
    
	static func appOpenEvent() {
		Analytics.logEvent(Event.appOpen.rawValue, parameters: nil)
    }
    
    static func appForegroundEvent() {
		Analytics.logEvent(Event.appForeground.rawValue, parameters: nil)
    }
    
    static func appBackgroundEvent() {
		Analytics.logEvent(Event.appBackground.rawValue, parameters: nil)
    }
    
    // MARK: Location
    static func sendLocationEnableHeadingEvent() {
		Analytics.logEvent(Event.locationDidEnableHeading.rawValue, parameters: nil)
    }
    
    static func sendLocationOnSiteEvent() {
		Analytics.logEvent(Event.locationOnSite.rawValue, parameters: nil)
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
	
	static func sendPlayAudioFromSearchedArtworkEvent(artwork: AICObjectModel, language: Common.Language) {
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
	
	// MARK: Events
	
	static func sendEventOpenedEvent(event: AICEventModel) {
		Analytics.logEvent(Event.eventOpened.rawValue, parameters: [
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
		Analytics.logEvent(Event.memberShowCard.rawValue, parameters: nil)
    }
	
    static func sendMemberJoinPressedEvent() {
		Analytics.logEvent(Event.memberJoinPressed.rawValue, parameters: nil)
    }
	
	// MARK: Search
	
	static func sendSearchLoadedEvent(searchText: String, isAutocompleteString: Bool, isPromotedString: Bool) {
		
	}
	
	static func sendSearchSelectedArtworkEvent(searchedArtwork: AICSearchedArtworkModel, searchText: String) {
		
	}
	
	static func sendSearchSelectedTourEvent(tour: AICTourModel, searchText: String) {
		
	}
	
	static func sendSearchSelectedExhibitionEvent(exhibition: AICExhibitionModel, searchText: String) {
		
	}
}
