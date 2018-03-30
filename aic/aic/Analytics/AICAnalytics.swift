/*
 Abstract:
 Abstracted analytics centralized commands
 currently using Google Analytics
*/

import Firebase
import Answers

class AICAnalytics {
	// Analytics tracker
	static fileprivate var tracker: GAITracker? = nil
	
	fileprivate enum Event : String {
		case appOpen				= "app_open"
		case appBackground			= "app_background"
		case appForeground			= "app_foreground"
		
		case languageSelected		= "language_selected"
		case languageChanged		= "language_changed"
		
		case locationOnSite			= "location_on_site"
		case locationDidEnableHeading = "location_heading_enabled"
		
		case playAudio		 		= "play_audio"
		case playInterrupted		= "playback_interrupted"
		case playCompleted			= "playback_completed"
		
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
		var membership = "None"
		if UserDefaults.standard.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) != nil {
			membership = "Member"
		}
		let deviceLanguage = NSLocale.preferredLanguages.first!
		
		// Firebase
		let firebaseOptions = FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "GoogleService-Info-Firebase", ofType: ".plist")!)
		FirebaseApp.configure(options: firebaseOptions!)
		
		// Firebase User Properties
		Analytics.setUserProperty(membership, forName: "Membership")
		Analytics.setUserProperty(Common.stringForLanguage[Common.currentLanguage], forName: "AppLanguage")
		Analytics.setUserProperty(deviceLanguage, forName: "DeviceLanguage")
		
		// Fabric
		Fabric.with([Answers.self])
		
		// Google Analytics
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
		
		// Google Analytics User Properties
		AICAnalytics.tracker?.set("Membership", value: membership)
		AICAnalytics.tracker?.set("AppLanguage", value: Common.stringForLanguage[Common.currentLanguage])
		AICAnalytics.tracker?.set("DeviceLanguage", value: deviceLanguage)
    }
	
	// MARK: Track Screens
	
	static func trackScreenView(_ screenName: String, screenClass: String) {
		if screenName != currentScreen {
			Analytics.setScreenName(screenName, screenClass: screenClass)
			
			Answers.logContentView(withName: screenName,
								   contentType: "Screen View",
								   contentId: "",
								   customAttributes: nil)
			
			AICAnalytics.tracker?.set(kGAIScreenName, value: screenName)
			let builder = GAIDictionaryBuilder.createScreenView()
			let dictionary = builder?.build() as NSDictionary?
			AICAnalytics.tracker?.send(dictionary as? [AnyHashable : Any])
			
			previousScreen = currentScreen
			currentScreen = screenName
		}
	}
	
	// MARK: Track Events
	
    // MARK: App
    
	static func sendAppOpenEvent() {
		Analytics.logEvent(Event.appOpen.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.appOpen.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "app", action: "open", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
    }
    
    static func sendAppForegroundEvent() {
		Analytics.logEvent(Event.appForeground.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.appForeground.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "app", action: "foreground", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
    }
    
    static func sendAppBackgroundEvent() {
		Analytics.logEvent(Event.appBackground.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.appBackground.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "app", action: "background", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
    }
	
	// MARK: Language
	
	static func sendLanguageSelectedEvent(language: Common.Language) {
		Analytics.setUserProperty(Common.stringForLanguage[language], forName: "AppLanguage")
		Analytics.logEvent(Event.languageSelected.rawValue, parameters: [
			"language" : Common.stringForLanguage[language]! as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.languageSelected.rawValue, customAttributes: [
			"language" : Common.stringForLanguage[language]!
		])
		
		AICAnalytics.tracker?.set("AppLanguage", value: Common.stringForLanguage[language]!)
		let event = GAIDictionaryBuilder.createEvent(withCategory: "language", action: "selected", label: Common.stringForLanguage[language]!, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendLanguageChangedEvent(language: Common.Language) {
		Analytics.setUserProperty(Common.stringForLanguage[language], forName: "AppLanguage")
		Analytics.logEvent(Event.languageChanged.rawValue, parameters: [
			"language": Common.stringForLanguage[language]! as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.languageChanged.rawValue, customAttributes: [
			"language" : Common.stringForLanguage[language]!
		])
		
		AICAnalytics.tracker?.set("AppLanguage", value: Common.stringForLanguage[language]!)
		let event = GAIDictionaryBuilder.createEvent(withCategory: "language", action: "changed", label: Common.stringForLanguage[language]!, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
    
    // MARK: Location
    static func sendLocationEnableHeadingEvent() {
		Analytics.logEvent(Event.locationDidEnableHeading.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.locationDidEnableHeading.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "location", action: "heading_enabled", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
    }
    
    static func sendLocationOnSiteEvent() {
		Analytics.logEvent(Event.locationOnSite.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.locationOnSite.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "location", action: "on_site", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
    }
	
	static func updateUserLocationProperty(isOnSite: Bool) {
		Analytics.setUserProperty(isOnSite ? "Yes" : "No", forName: "OnSite")
		
		// GA
		AICAnalytics.tracker?.set("OnSite", value: isOnSite ? "Yes" : "No")
	}
	
	// MARK: Audio Player
	static func sendPlayAudioFromMapEvent(artwork: AICObjectModel) {
		Analytics.logEvent(Event.playAudio.rawValue, parameters: [
			AnalyticsParameterItemID: artwork.nid as NSObject,
			AnalyticsParameterItemName: artwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject,
			AnalyticsParameterSource: "Map" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.playAudio.rawValue, customAttributes: [
			"artwork_id" : artwork.nid,
			"artwork_title" : artwork.title,
			"source" : "map"
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "play_audio", action: "map", label: artwork.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
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
		
		Answers.logCustomEvent(withName: Event.playAudio.rawValue, customAttributes: [
			"artwork_id" : artwork.nid,
			"artwork_title" : artwork.title,
			"source" : "AudioGuide",
			"selector_number" : selectorNumber,
			"language" : Common.stringForLanguage[language]!
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "play_audio", action: "audio_guide", label: artwork.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
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
		
		Answers.logCustomEvent(withName: Event.playAudio.rawValue, customAttributes: [
			"artwork_id" : artwork.nid,
			"artwork_title" : artwork.title,
			"source" : "Tour",
			"tour_name" : tour.translations[.english]!.title,
			"language" : Common.stringForLanguage[tour.language]!
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "play_audio", action: "tour", label: artwork.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
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
		
		Answers.logCustomEvent(withName: Event.playAudio.rawValue, customAttributes: [
			"tour_id" : tour.nid,
			"tour_title" : tour.translations[.english]!.title,
			"source" : "Tour",
			"language" : Common.stringForLanguage[tour.language]!
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "play_audio", action: "tour", label: tour.translations[.english]!.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendPlayAudioFromSearchedArtworkEvent(artwork: AICObjectModel) {
		Analytics.logEvent(Event.playAudio.rawValue, parameters: [
			AnalyticsParameterItemID: artwork.nid as NSObject,
			AnalyticsParameterItemName: artwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject,
			AnalyticsParameterSource: "search" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.playAudio.rawValue, customAttributes: [
			"artwork_id" : artwork.nid,
			"artwork_title" : artwork.title,
			"source" : "Search"
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "play_audio", action: "search", label: artwork.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendPlaybackInterruptedEvent(audio: AICAudioFileModel, pctComplete: Int) {
		Analytics.logEvent(Event.playInterrupted.rawValue, parameters: [
			AnalyticsParameterItemID: audio.nid as NSObject,
			AnalyticsParameterItemName: audio.translations[.english]!.trackTitle as NSObject,
			AnalyticsParameterContentType: "audio" as NSObject,
			"percent_completed": pctComplete as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.playInterrupted.rawValue, customAttributes: [
			"audio_id" : audio.nid,
			"audio_title" : audio.translations[.english]!.trackTitle,
			"percent_completed" : pctComplete
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "playback", action: "interrupted", label: audio.translations[.english]!.trackTitle, value: NSNumber(value: pctComplete as Int)).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendPlaybackCompletedEvent(audio: AICAudioFileModel) {
		Analytics.logEvent(Event.playCompleted.rawValue, parameters: [
			AnalyticsParameterItemID: audio.nid as NSObject,
			AnalyticsParameterItemName: audio.translations[.english]!.trackTitle as NSObject,
			AnalyticsParameterContentType: "audio" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.playCompleted.rawValue, customAttributes: [
			"audio_id" : audio.nid,
			"audio_title" : audio.translations[.english]!.trackTitle
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "playback", action: "completed", label: audio.translations[.english]!.trackTitle, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
    
    // MARK: Tours
    
	static func sendTourOpenedEvent(tour: AICTourModel) {
		Analytics.logEvent(Event.tourOpened.rawValue, parameters: [
			AnalyticsParameterItemID: tour.nid as NSObject,
			AnalyticsParameterItemName: tour.translations[.english]!.title as NSObject,
			AnalyticsParameterContentType: "tour" as NSObject,
			"language": Common.stringForLanguage[tour.language]! as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.tourOpened.rawValue, customAttributes: [
			"tour_id" : tour.nid,
			"tour_title" : tour.translations[.english]!.title,
			"language" : Common.stringForLanguage[tour.language]!
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "tour", action: "opened", label: tour.translations[.english]!.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
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
		
		Answers.logCustomEvent(withName: Event.tourStarted.rawValue, customAttributes: [
			"tour_id" : tour.nid,
			"tour_title" : tour.translations[.english]!.title,
			"language" : Common.stringForLanguage[tour.language]!,
			"source" : source,
			"start_from" : start
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "tour", action: "started", label: tour.translations[.english]!.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendTourLeftEvent(tour: AICTourModel) {
		Analytics.logEvent(Event.tourLeft.rawValue, parameters: [
			AnalyticsParameterItemID: tour.nid as NSObject,
			AnalyticsParameterItemName: tour.translations[.english]!.title as NSObject,
			AnalyticsParameterContentType: "tour" as NSObject,
			"language": Common.stringForLanguage[tour.language]! as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.tourStarted.rawValue, customAttributes: [
			"tour_id" : tour.nid,
			"tour_title" : tour.translations[.english]!.title,
			"language" : Common.stringForLanguage[tour.language]!
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "tour", action: "left", label: tour.translations[.english]!.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	// MARK: Exhibitions
	
	static func sendExhibitionOpenedEvent(exhibition: AICExhibitionModel) {
		Analytics.logEvent(Event.exhibitionOpened.rawValue, parameters: [
			AnalyticsParameterItemID: exhibition.id as NSObject,
			AnalyticsParameterItemName: exhibition.title as NSObject,
			AnalyticsParameterContentType: "exhibition" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.exhibitionOpened.rawValue, customAttributes: [
			"exhibition_id" : exhibition.id,
			"exhibition_title" : exhibition.title
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "exhibition", action: "opened", label: exhibition.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendExhibitionLinkPressedEvent(exhibition: AICExhibitionModel) {
		Analytics.logEvent(Event.exhibitionLinkPressed.rawValue, parameters: [
			AnalyticsParameterItemID: exhibition.id as NSObject,
			AnalyticsParameterItemName: exhibition.title as NSObject,
			AnalyticsParameterContentType: "exhibition" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.exhibitionLinkPressed.rawValue, customAttributes: [
			"exhibition_id" : exhibition.id,
			"exhibition_title" : exhibition.title
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "exhibition", action: "link_pressed", label: exhibition.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	// MARK: Events
	
	static func sendEventOpenedEvent(event: AICEventModel) {
		Analytics.logEvent(Event.eventOpened.rawValue, parameters: [
			AnalyticsParameterItemID: event.eventId as NSObject,
			AnalyticsParameterItemName: event.title as NSObject,
			AnalyticsParameterContentType: "event" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.eventOpened.rawValue, customAttributes: [
			"event_id" : event.eventId,
			"event_title" : event.title
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "event", action: "opened", label: event.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendEventLinkPressedEvent(event: AICEventModel) {
		Analytics.logEvent(Event.eventLinkPressed.rawValue, parameters: [
			AnalyticsParameterItemID: event.eventId as NSObject,
			AnalyticsParameterItemName: event.title as NSObject,
			AnalyticsParameterContentType: "event" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.eventLinkPressed.rawValue, customAttributes: [
			"event_id" : event.eventId,
			"event_title" : event.title
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "event", action: "link_pressed", label: event.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	// MARK: Map
	
	static func sendMapShowArtworkEvent(artwork: AICObjectModel) {
		Analytics.logEvent(Event.mapShowArtwork.rawValue, parameters: [
			AnalyticsParameterItemID: artwork.nid as NSObject,
			AnalyticsParameterItemName: artwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.mapShowArtwork.rawValue, customAttributes: [
			"artwork_id" : artwork.nid,
			"artwork_title" : artwork.title
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "map", action: "show_artwork", label: artwork.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendMapShowSearchedArtworkEvent(searchedArtwork: AICSearchedArtworkModel) {
		Analytics.logEvent(Event.mapShowArtwork.rawValue, parameters: [
			AnalyticsParameterItemID: searchedArtwork.artworkId as NSObject,
			AnalyticsParameterItemName: searchedArtwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.mapShowArtwork.rawValue, customAttributes: [
			"artwork_id" : searchedArtwork.artworkId,
			"artwork_title" : searchedArtwork.title
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "map", action: "show_artwork", label: searchedArtwork.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendMapShowExhibitionEvent(exhibition: AICExhibitionModel) {
		Analytics.logEvent(Event.mapShowExhibition.rawValue, parameters: [
			AnalyticsParameterItemID: exhibition.id as NSObject,
			AnalyticsParameterItemName: exhibition.title as NSObject,
			AnalyticsParameterContentType: "exhibition" as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.mapShowExhibition.rawValue, customAttributes: [
			"exhibition_id" : exhibition.id,
			"exhibition_title" : exhibition.title
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "map", action: "show_exhibition", label: exhibition.title, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendMapShowDiningEvent() {
		Analytics.logEvent(Event.mapShowDining.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.mapShowDining.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "map", action: "show_dining", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendMapShowMemberLoungeEvent() {
		Analytics.logEvent(Event.mapShowMemberLounge.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.mapShowMemberLounge.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "map", action: "show_member_lounge", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendMapShowGiftShopsEvent() {
		Analytics.logEvent(Event.mapShowGiftShops.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.mapShowGiftShops.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "map", action: "show_gift_shops", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendMapShowRestroomsEvent() {
		Analytics.logEvent(Event.mapShowRestrooms.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.mapShowRestrooms.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "map", action: "show_restrooms", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
    // MARK: Members
	
	static func sendMemberShowCardEvent() {
		Analytics.setUserProperty("Member", forName: "Membership")
		Analytics.logEvent(Event.memberShowCard.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.memberShowCard.rawValue, customAttributes: nil)
		
		AICAnalytics.tracker?.set("Membership", value: "Member")
		let event = GAIDictionaryBuilder.createEvent(withCategory: "member", action: "show_card", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
    }
	
    static func sendMemberJoinPressedEvent() {
		Analytics.logEvent(Event.memberJoinPressed.rawValue, parameters: nil)
		
		Answers.logCustomEvent(withName: Event.memberJoinPressed.rawValue, customAttributes: nil)
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "member", action: "join_pressed", label: "", value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
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
			
			Answers.logCustomEvent(withName: Event.searchLoaded.rawValue, customAttributes: [
				"searchText": searchText,
				"is_autocomplete": (isAutocompleteString ? "true" : "false"),
				"is_promoted": (isPromotedString ? "true" : "false")
			])
			
			let event = GAIDictionaryBuilder.createEvent(withCategory: "search", action: "loaded", label: searchText, value: 0).build() as NSDictionary?
			if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
		}
	}
	
	static func sendSearchSelectedArtworkEvent(searchedArtwork: AICSearchedArtworkModel, searchText: String) {
		Analytics.logEvent(Event.searchSelectedArtwork.rawValue, parameters: [
			AnalyticsParameterItemID: searchedArtwork.artworkId as NSObject,
			AnalyticsParameterItemName: searchedArtwork.title as NSObject,
			AnalyticsParameterContentType: "artwork" as NSObject,
			"searchText": searchText as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.searchSelectedArtwork.rawValue, customAttributes: [
			"artwork_id" : searchedArtwork.artworkId,
			"artwork_title" : searchedArtwork.title,
			"searchText": searchText
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "search_artwork", action: searchedArtwork.title, label: searchText, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendSearchSelectedTourEvent(tour: AICTourModel, searchText: String) {
		Analytics.logEvent(Event.searchSelectedTour.rawValue, parameters: [
			AnalyticsParameterItemID: tour.nid as NSObject,
			AnalyticsParameterItemName: tour.translations[.english]!.title as NSObject,
			AnalyticsParameterContentType: "tour" as NSObject,
			"searchText": searchText as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.searchSelectedTour.rawValue, customAttributes: [
			"tour_id" : tour.nid,
			"tour_title" : tour.translations[.english]!.title,
			"searchText": searchText
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "search_tour", action: tour.translations[.english]!.title, label: searchText, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
	
	static func sendSearchSelectedExhibitionEvent(exhibition: AICExhibitionModel, searchText: String) {
		Analytics.logEvent(Event.searchSelectedExhibition.rawValue, parameters: [
			AnalyticsParameterItemID: exhibition.id as NSObject,
			AnalyticsParameterItemName: exhibition.title as NSObject,
			AnalyticsParameterContentType: "exhibition" as NSObject,
			"searchText": searchText as NSObject
		])
		
		Answers.logCustomEvent(withName: Event.searchSelectedExhibition.rawValue, customAttributes: [
			"exhibition_id" : exhibition.id,
			"exhibition_title" : exhibition.title,
			"searchText": searchText
		])
		
		let event = GAIDictionaryBuilder.createEvent(withCategory: "search_exhibition", action: exhibition.title, label: searchText, value: 0).build() as NSDictionary?
		if event != nil { AICAnalytics.tracker?.send(event as? [AnyHashable: Any]) }
	}
}
