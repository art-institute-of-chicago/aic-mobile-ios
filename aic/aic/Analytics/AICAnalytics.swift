/*
 Abstract:
 Abstracted analytics centralized commands
 currently using Google Analytics
*/

class AICAnalytics {
    // Analytics tracker
    static fileprivate let tracker = GAI.sharedInstance().defaultTracker
	
	fileprivate enum Category : String {
		case app 			= "app"
		case objectShown 	= "object_shown"
		case object 		= "object"
		case tour 			= "tour"
		case news 			= "news"
		case location 		= "location"
		case member 		= "member"
		case info 			= "info"
	}
	
	fileprivate enum Action : String {
		case appOpen				= "open"
		case appBackground			= "background"
		case appForeground			= "foreground"
		
		case objectShownMap 		= "map"
		case objectShownAudioGuide	= "audioGuide"
		case objectShownTour		= "tour"
		
		case objectFinishedPlaying	= "finished_playing"
		
		case expanded				= "expanded"
		
		case tourStarted			= "started"
		case tourStartedFromLink	= "started_from_link"
		case tourOverviewShown		= "overview_shown"
		case tourLeft				= "left"
		
		case newsItemShownOnMap		= "shown_on_map"
		
		case locationOnSite			= "on_site"
		case locationDidEnableHeading = "heading_enabled"
		
		case memberShowCard			= "show_card"
		
		case infoJoinPressed		= "join_pressed"
		case infoGetTicketsPressed	= "get_tickets_pressed"
	}
	
	fileprivate enum Label : String {
		case appIsMember	= "is_member"
	}
	
    static fileprivate var previousScreen:String? = nil
    static fileprivate var currentScreen:String? = nil
    
    static func configure() {
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        if let error = configureError {
            assert(configureError == nil, "Error configuring Google services: \(error)")
        }
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.dispatchInterval = 30
        gai?.trackUncaughtExceptions = false  // report uncaught exceptions
        
        #if APP_STORE
            gai.logger.logLevel = GAILogLevel.Error
        #else
            gai?.logger.logLevel = GAILogLevel.warning
        #endif
    }
    
    // App
    
    static func appOpenEvent(isMember:Bool) {
        AICAnalytics.sendAnalyticEvent(category:Category.app, action:Action.appOpen, label:Label.appIsMember.rawValue, value:isMember as NSNumber)
    }
    
    static func appForegroundEvent() {
        AICAnalytics.sendAnalyticEvent(category:Category.app, action:Action.appForeground)
    }
    
    static func appBackgroundEvent() {
        AICAnalytics.sendAnalyticEvent(category:Category.app, action:Action.appBackground)
    }
    
    // Screens
    static func trackScreen(named screenName:String) {
        if screenName != currentScreen {
            AICAnalytics.tracker?.set(kGAIScreenName, value: screenName)
            
            let builder = GAIDictionaryBuilder.createScreenView()
            let dictionary = builder?.build() as NSDictionary?
            
            AICAnalytics.tracker?.send(dictionary as? [AnyHashable : Any])
            previousScreen = currentScreen
            currentScreen = screenName
        }
    }
    
    static func restorePreviousScreen() {
        if let previousScreen = AICAnalytics.previousScreen {
            trackScreen(named: previousScreen)
        }
    }
    
    // Map
    static func sendMapDidShowObjectEvent(forObject object:AICObjectModel) {
        AICAnalytics.objectShown(object: object, action: Action.objectShownMap)
    }
    
    static func sendMapDidEnableHeadingEvent() {
        AICAnalytics.sendAnalyticEvent(category: Category.location, action: Action.locationDidEnableHeading, label: "")
    }
    
    static func sendMapUserOnSiteEvent() {
        AICAnalytics.sendAnalyticEvent(category: Category.location, action: Action.locationOnSite, label: "")
    }
    
    // Tours
    static func sendTourDidShowOverviewEvent(forTour tour:AICTourModel) {
        AICAnalytics.sendAnalyticEvent(category: Category.tour, action: Action.tourOverviewShown, label: tour.title)
    }
    
	static func sendTourExpandedEvent(forTour tour:AICTourModel) {
		AICAnalytics.sendAnalyticEvent(category: Category.tour, action: Action.expanded, label: tour.title)
	}
    
    static func sendTourStartedFromLinkEvent(forTour tour:AICTourModel) {
        AICAnalytics.sendAnalyticEvent(category: Category.tour, action: Action.tourStartedFromLink, label: tour.title)
    }
    
    static func sendTourDidStartEvent(forTour tour:AICTourModel) {
        AICAnalytics.sendAnalyticEvent(category: Category.tour, action: Action.tourStarted, label: tour.title)
    }
    
    static func sendTourDidLeaveEvent(forTour tour:AICTourModel) {
        AICAnalytics.sendAnalyticEvent(category: Category.tour, action: Action.tourLeft, label: tour.title)
    }
    
    static func sendTourDidShowObjectEvent(forObject object:AICObjectModel) {
        AICAnalytics.objectShown(object: object, action: Action.objectShownTour)
    }
    
    // News
    static func sendNewsItemDidShowOnMapEvent(forNewsItem newsItem:AICNewsItemModel) {
        AICAnalytics.sendAnalyticEvent(category: Category.news, action: Action.newsItemShownOnMap, label: newsItem.title)
    }
    
    static func sendNewsItemExpandedEvent(forNewsItem newsItem:AICNewsItemModel) {
        AICAnalytics.sendAnalyticEvent(category: Category.news, action: Action.expanded, label: newsItem.title)
    }
    
    // Audio Guide
    static func sendAudioGuideDidShowObjectEvent(forObject object:AICObjectModel) {
        AICAnalytics.objectShown(object: object, action: Action.objectShownAudioGuide)
    }
    
    // Object View
    static func objectViewAudioItemPlayedEvent(audioItem:AICAudioFileModel, pctComplete:Int) {
        AICAnalytics.sendAnalyticEvent(category: Category.object, action: Action.objectFinishedPlaying, label: audioItem.title, value: NSNumber(value: pctComplete as Int))
    }
    
    // Members
    static func memberDidShowMemberCard(memberID:String) {
        // Disabled logging memberID for now, to re-enable:
        // value: String(memberID)
        AICAnalytics.sendAnalyticEvent(category: Category.member, action: Action.memberShowCard)
    }
    
    
    // Info
    static func infoJoinPressedEvent() {
        AICAnalytics.sendAnalyticEvent(category: Category.info, action:Action.infoJoinPressed)
    }
    
    static func infoGetTicketsPressedEvent() {
        AICAnalytics.sendAnalyticEvent(category: Category.info, action:Action.infoGetTicketsPressed)
    }
    
    // MARK: Private Functions
    
    // Log an object selected
    private static func objectShown(object:AICObjectModel, action:Action) {
        AICAnalytics.sendAnalyticEvent(category: Category.objectShown, action: action, label: object.title)
    }
    
    private static func sendAnalyticEvent(category:Category, action:Action, label:String="", value:NSNumber = 0) {
        let event = GAIDictionaryBuilder.createEvent(withCategory: category.rawValue, action: action.rawValue, label: label, value: value).build() as NSDictionary?
        if event != nil {
            AICAnalytics.tracker?.send(event as? [AnyHashable: Any])
        }
    }
}
