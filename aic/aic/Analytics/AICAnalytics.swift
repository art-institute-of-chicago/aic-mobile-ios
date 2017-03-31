/*
 Abstract:
 Abstracted analytics centralized commands
 currently using Google Analytics
*/

class AICAnalytics {
    // Analytics tracker
    static fileprivate let tracker = GAI.sharedInstance().defaultTracker
    
    // App Events
    static fileprivate let appCategory = "app"
    static fileprivate let appOpenAction = "open"
    static fileprivate let appBackgroundAction = "background"
    static fileprivate let appForegroundAction = "foreground"
    static fileprivate let appIsMemberLabel = "is_member"
    
    
    // Show Object events
    static fileprivate let objectShownCategory = "object_shown"
    static fileprivate let objectShownMapAction = "map"
    static fileprivate let objectShownAudioGuideAction = "audioGuide"
    static fileprivate let objectShownTourAction = "tour"
    
    static fileprivate let objectCategory = "object"
    static fileprivate let objectFinishedPlayingAction = "finished_playing"
    
    static fileprivate let expandedAction = "expanded"
    
    static fileprivate let tourCategory = "tour"
    static fileprivate let tourStartedAction = "started"
    static fileprivate let tourStartedFromLinkAction = "started_from_link"
    static fileprivate let tourOverviewShownAction = "overview_shown"
    static fileprivate let tourLeftAction = "left"
    
    static fileprivate let newsCategory = "news"
    static fileprivate let newsItemShownOnMapAction = "shown_on_map"
    
    static fileprivate let locationCategory = "location"
    static fileprivate let locationOnSiteAction = "on_site"
    static fileprivate let locationDidEnableHeadingAction = "heading_enabled"
    
    static fileprivate let memberCategory = "member"
    static fileprivate let memberShowCardAction = "show_card"
    
    static fileprivate let infoCategory = "info"
    static fileprivate let infoJoinPressedAction = "join_pressed"
    static fileprivate let infoGetTicketsPressedAction = "get_tickets_pressed"
    
    static fileprivate var previousScreen:String? = nil
    static fileprivate var currentScreen:String? = nil
    
    static func configure() {
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
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
        AICAnalytics.sendAnalyticEvent(category:AICAnalytics.appCategory, action:AICAnalytics.appOpenAction, label:appIsMemberLabel, value:isMember as NSNumber)
    }
    
    static func appForegroundEvent() {
        AICAnalytics.sendAnalyticEvent(category:AICAnalytics.appCategory, action:AICAnalytics.appForegroundAction)
    }
    
    static func appBackgroundEvent() {
        AICAnalytics.sendAnalyticEvent(category:AICAnalytics.appCategory, action:AICAnalytics.appBackgroundAction)
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
        AICAnalytics.objectShown(object: object, action: AICAnalytics.objectShownMapAction)
    }
    
    static func sendMapDidEnableHeadingEvent() {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.locationCategory, action: AICAnalytics.locationDidEnableHeadingAction, label: "")
    }
    
    static func sendMapUserOnSiteEvent() {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.locationCategory, action: AICAnalytics.locationOnSiteAction, label: "")
    }
    
    // Tours
    static func sendTourDidShowOverviewEvent(forTour tour:AICTourModel) {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.tourCategory, action: AICAnalytics.tourOverviewShownAction, label: tour.title)
    }
    
    static func sendTourExpandedEvent(forTour tour:AICTourModel) {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.tourCategory, action: AICAnalytics.expandedAction, label: tour.title)
    }
    
    static func sendTourStartedFromLinkEvent(forTour tour:AICTourModel) {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.tourCategory, action: AICAnalytics.tourStartedFromLinkAction, label: tour.title)
    }
    
    static func sendTourDidStartEvent(forTour tour:AICTourModel) {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.tourCategory, action: AICAnalytics.tourStartedAction, label: tour.title)
    }
    
    static func sendTourDidLeaveEvent(forTour tour:AICTourModel) {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.tourCategory, action: AICAnalytics.tourLeftAction, label: tour.title)
    }
    
    static func sendTourDidShowObjectEvent(forObject object:AICObjectModel) {
        AICAnalytics.objectShown(object: object, action: AICAnalytics.objectShownTourAction)
    }
    
    // News
    static func sendNewsItemDidShowOnMapEvent(forNewsItem newsItem:AICNewsItemModel) {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.newsCategory, action: AICAnalytics.newsItemShownOnMapAction, label: newsItem.title)
    }
    
    static func sendNewsItemExpandedEvent(forNewsItem newsItem:AICNewsItemModel) {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.newsCategory, action: AICAnalytics.expandedAction, label: newsItem.title)
    }
    
    // Audio Guide
    static func sendAudioGuideDidShowObjectEvent(forObject object:AICObjectModel) {
        AICAnalytics.objectShown(object: object, action: AICAnalytics.objectShownAudioGuideAction)
    }
    
    // Object View
    static func objectViewAudioItemPlayedEvent(audioItem:AICAudioFileModel, pctComplete:Int) {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.objectCategory, action: AICAnalytics.objectFinishedPlayingAction, label: audioItem.title, value: NSNumber(value: pctComplete as Int))
    }
    
    // Members
    static func memberDidShowMemberCard(memberID:String) {
        // Disabled logging memberID for now, to re-enable:
        // value: String(memberID)
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.memberCategory, action: AICAnalytics.memberShowCardAction)
    }
    
    
    // Info
    static func infoJoinPressedEvent() {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.infoCategory, action:AICAnalytics.infoJoinPressedAction)
    }
    
    static func infoGetTicketsPressedEvent() {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.infoCategory, action:AICAnalytics.infoGetTicketsPressedAction)
    }
    
    // MARK: Private Functions
    
    // Log an object selected
    private static func objectShown(object:AICObjectModel, action:String) {
        AICAnalytics.sendAnalyticEvent(category: AICAnalytics.objectShownCategory, action: action, label: object.title)
    }
    
    private static func sendAnalyticEvent(category:String, action:String, label:String="", value:NSNumber = 0) {
        let event = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value).build() as NSDictionary?
        if event != nil {
            AICAnalytics.tracker?.send(event as? [AnyHashable: Any])
        }
    }
}
