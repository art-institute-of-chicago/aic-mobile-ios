/*
 Abstract:
 Main Section controller, contains MapView, UITabBar and Object View.
*/

import UIKit
import MapKit

protocol SectionsViewControllerDelegate : class {
    func sectionsViewControllerDidFinishAnimatingIn()
}

class SectionsViewController : UIViewController {
    weak var delegate:SectionsViewControllerDelegate? = nil
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    var mapVC = MapViewController()
    var objectVC:ObjectViewController = ObjectViewController();
    
    // TabBar
    var tabBar:UITabBar = UITabBar()
    
    // Sections
    var viewControllers: [SectionViewController] = []
    
    var currentViewController:SectionViewController? = nil
    var previousViewController:SectionViewController? = nil
    
    var viewControllersForTabBarItems: [UITabBarItem: SectionViewController] = [:]
    var tabBarItemsForViewControllers: [SectionViewController: UITabBarItem] = [:]
    
    var contentView = SectionsContentView() // Holder for selected view controller
    
    var audioGuideVC:AudioGuideSectionViewController = AudioGuideSectionViewController(section: Common.Sections[.audioGuide]!)
    var whatsOnVC:WhatsOnSectionViewController = WhatsOnSectionViewController(section: Common.Sections[.whatsOn]!)
    var toursVC:ToursSectionViewController = ToursSectionViewController(section: Common.Sections[.tours]!)
    var nearbyVC:NearbySectionViewController = NearbySectionViewController(section: Common.Sections[.map]!)
    var infoVC:InfoSectionViewController = InfoSectionViewController(section: Common.Sections[.info]!)
    
    // Messages
    fileprivate var requestedTour:AICTourModel? = nil
    fileprivate var leaveCurrentTourMessageView:UIView? = nil

    fileprivate var enableLocationMessageView:UIView? = nil
    fileprivate var headphonesMessageView:UIView? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView(frame:UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        // Set the view controllers for the tab bar
        self.viewControllers = [
            audioGuideVC,
            whatsOnVC,
            toursVC,
            nearbyVC,
            infoVC
        ]
        
        // Store the relationship between items and view controllers
        var tabBarItems:[UITabBarItem] = []
        
        for controller in viewControllers {
            let controllerItem = controller.tabBarItem
            
            tabBarItemsForViewControllers[controller]       = controllerItem
            viewControllersForTabBarItems[controllerItem!]   = controller
            
            controller.viewableAreaDelegate = self
            
            tabBarItems.append(controllerItem!)
        }
        
        // Setup and add the tabbar
        tabBar.backgroundColor = .aicTabbarColor
        tabBar.backgroundImage = UIImage()
        tabBar.barStyle = UIBarStyle.black
        tabBar.setItems(tabBarItems, animated: false)
        tabBar.frame = CGRect(x: 0,
                                   y: UIScreen.main.bounds.size.height - Common.Layout.tabBarHeight,
                                   width: UIScreen.main.bounds.size.width,
                                   height: Common.Layout.tabBarHeight)
        
        // Setup and add contentView
        contentView.frame = UIScreen.main.bounds
        contentView.alpha = 0.0
        mapVC.view.alpha = 0.0
        
        // Add Views
        view.addSubview(mapVC.view)
        view.addSubview(contentView)
        view.addSubview(objectVC.view)
        view.addSubview(tabBar)
        
        // Set delegates
        tabBar.delegate         = self
        mapVC.delegate          = self
        objectVC.delegate       = self
        audioGuideVC.delegate   = self
        
        whatsOnVC.newsToursDelegate = self
        whatsOnVC.delegate          = self
        
        toursVC.newsToursDelegate   = self
        toursVC.delegate            = self
        
        locationManager.delegate = mapVC
        
        startLocationManager()
    }
    
    func setSelectedSection(sectionVC:SectionViewController) {
        // If tours tab was pressed when on a tour
        if sectionVC == currentViewController && sectionVC == toursVC {
            if toursVC.currentTour != nil {
                showLeaveTourMessage()
                return
            }
        }
        
        previousViewController = currentViewController
        currentViewController = sectionVC
        
        // Clear current view controller
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // Update colors for this VC
        tabBar.tintColor = sectionVC.color
        objectVC.setProgressBarColor(sectionVC.color)
        mapVC.color = sectionVC.color
        // Tell the map what region this view shows
        mapVC.setViewableArea(frame: sectionVC.viewableMapArea)
        
        // Set the map mode
        switch sectionVC {
        case nearbyVC:
            locationManager.delegate = mapVC
            mapVC.showAllInformation()
            
        case whatsOnVC:
            disableMap(locationManagerDelegate:whatsOnVC)
            
        case toursVC:
            // If we were previously showing a tour,
            // show it on the map again
            if let currentTour = toursVC.currentTour {
                mapVC.showTour(forTour: currentTour, andRestoreState: true)
                locationManager.delegate = mapVC
            } else {
                disableMap(locationManagerDelegate:toursVC)
            }
            
        default:
            disableMap(locationManagerDelegate: nil)
        }
        
        // Update and add VC
        contentView.addSubview(sectionVC.view)
        sectionVC.reset()
        sectionVC.view.setNeedsUpdateConstraints()
        
        
        
        // Set the Tab bar item
        tabBar.selectedItem = tabBarItemsForViewControllers[sectionVC]
    }
    
    fileprivate func removeCurrentTour() {
        disableMap(locationManagerDelegate: toursVC)
        toursVC.removeCurrentTour()
        toursVC.reset()
    }
    
    
    func disableMap(locationManagerDelegate:CLLocationManagerDelegate?) {
        locationManager.delegate = locationManagerDelegate
        mapVC.showDisabled()
    }
    
    // Intro animation
    func animateInInitialView() {
        contentView.alpha = 0.0
        mapVC.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseOut,
                                   animations: {
                                        self.contentView.alpha = 1.0
                                   },
                                   completion:nil
        )
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut,
                                   animations:  {
                                    self.mapVC.view.alpha = 1.0
            }, completion: { (value:Bool) in

                self.delegate?.sectionsViewControllerDidFinishAnimatingIn()
        })
        Common.DeepLinks.loadedEnoughToLink = true
        (UIApplication.shared.delegate as? AppDelegate)?.triggerDeepLinkIfPresent()
    }
    
    func startTour(tour:AICTourModel) {
        if toursVC.currentTour != nil {
            self.requestedTour = tour
            showLeaveTourMessage()
            return
        }
        
        setSelectedSection(sectionVC: toursVC)
        
        locationManager.delegate = mapVC
        toursVC.showTour(forTourModel: tour)
        
        // If this is coming from an object view,
        //show the mini player to reveal tour below
        if objectVC.mode != .hidden {
            objectVC.showMiniPlayer()
        }
        
        // Log Analytics
        AICAnalytics.sendTourStartedFromLinkEvent(forTour: tour)
    }
    
    // MARK: Object view showing methods
    func showObject(object:AICObjectModel, audioGuideID: Int?) {
        self.objectVC.setContent(forObjectModel: object, audioGuideID: audioGuideID)
        self.objectVC.showFullscreen()
        self.showHeadphonesMessage()
        
        updateTabBarHeightWithMiniPlayer()
    }
    
    func showAudioGuideObject(object:AICObjectModel, audioGuideID: Int) {
        showObject(object: object, audioGuideID: audioGuideID)
        
        // Log analytics
        AICAnalytics.sendAudioGuideDidShowObjectEvent(forObject: object)
    }
    
    func showMapObject(forObjectModel object:AICObjectModel) {
        if currentViewController == toursVC {
            guard let currentTour = toursVC.currentTour else {
                print("Could not display object because it isn't on currently displayed tour.")
                return
            }
            
            guard let tourStopIndex = currentTour.getIndex(forStopObject: object) else {
                print("Could not get index for tour object.")
                return
            }
            
            showTourStop(forTourModel: currentTour, atStopIndex: tourStopIndex)
        } else {
            showObject(object: object, audioGuideID: nil)
        }
        
        // Log analytics
        AICAnalytics.sendMapDidShowObjectEvent(forObject: object)
    }
    
    fileprivate func showTourOverview(forTourModel tour:AICTourModel) {
        self.objectVC.setContent(forTourOverviewModel: tour.overview)
        self.objectVC.showMiniPlayer()
        self.showHeadphonesMessage()
        
        updateTabBarHeightWithMiniPlayer()
        
        // Log analytics
        AICAnalytics.sendTourDidShowOverviewEvent(forTour: tour)
    }
    
    fileprivate func showTourStop(forTourModel tour:AICTourModel, atStopIndex stopIndex:Int) {
        self.objectVC.setContent(forTour: tour, atStopIndex: stopIndex)
        self.objectVC.showMiniPlayer()
        self.showHeadphonesMessage()
        
        updateTabBarHeightWithMiniPlayer()
        
        // Log analytics
        AICAnalytics.sendTourDidShowObjectEvent(forObject: tour.stops[stopIndex].object)
    }
    
    // Update bottom margin for tab bar + audio player in case any views need to adjust
    private func updateTabBarHeightWithMiniPlayer() {
        if Common.Layout.tabBarHeight == Common.Layout.tabBarHeightWithMiniAudioPlayerHeight {
            Common.Layout.tabBarHeightWithMiniAudioPlayerHeight = Common.Layout.tabBarHeight + objectVC.getMiniPlayerHeight()
        }
    }
    
    // MARK: Location
    fileprivate func startLocationManager() {
        //See if we need to prompt first
        let defaults = UserDefaults.standard
        let showEnableLocationMessageValue = defaults.bool(forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
        
        // If we do show it
        if showEnableLocationMessageValue {
            showEnableLocationMessage()
        } else {  // Otherwise try to start the location manager
            // Init location manager
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    
    // MARK: Messages
    fileprivate func showLeaveTourMessage() {
        let leaveCurrentTourMessageView = MessageSmallView(model: Common.Messages.leaveTour)
        leaveCurrentTourMessageView.delegate = self
        
        view.addSubview(leaveCurrentTourMessageView)
        self.leaveCurrentTourMessageView = leaveCurrentTourMessageView
    }
    
    fileprivate func hideLeaveTourMessage() {
        if let leaveCurrentTourMessageView = leaveCurrentTourMessageView {
            leaveCurrentTourMessageView.removeFromSuperview()
            self.leaveCurrentTourMessageView = nil
        }
    }
    
    fileprivate func showEnableLocationMessage() {
        let enableLocationView = MessageLargeView(model: Common.Messages.enableLocation)
        enableLocationView.delegate = self
        
        self.enableLocationMessageView = enableLocationView
        view.addSubview(enableLocationView)
    }
    
    fileprivate func hideEnableLocationMessage() {
        if let enableLocationMessageView = self.enableLocationMessageView {
            // Update user defaults
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
            defaults.synchronize()
            
            enableLocationMessageView.removeFromSuperview()
            self.enableLocationMessageView = nil
        }
    }
    
    fileprivate func showHeadphonesMessage() {
        let defaults = UserDefaults.standard
        let showHeadphonesMessage = defaults.bool(forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
        
        if showHeadphonesMessage {
            let headphonesMessageView = MessageLargeView(model: Common.Messages.useHeadphones)
            headphonesMessageView.delegate = self
            
            self.headphonesMessageView = headphonesMessageView
            view.addSubview(headphonesMessageView)
        }
    }
    
    fileprivate func hideHeadphonesMessage() {
        if let headphonesMessageView = self.headphonesMessageView {
            // Update user defaults
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
            defaults.synchronize()
            
            // Get rid of view
            headphonesMessageView.removeFromSuperview()
            self.headphonesMessageView = nil
        }
    }
}

// MARK: SectionsTabBar Delegate Methods
extension SectionsViewController : UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let selectedViewController = viewControllersForTabBarItems[item] else {
            return
        }
        
        setSelectedSection(sectionVC: selectedViewController)
    }
}

// ObjectViewController Delegate
extension SectionsViewController : ObjectViewControllerDelegate {
    // When the Object View Controller Moves up (out of mini player mode)
    // We hide the bottom navigation
    func objectViewController(controller:ObjectViewController, didUpdateYPosition position:CGFloat) {
        let screenHeight = UIScreen.main.bounds.height
        let yPct:CGFloat = (position) / (screenHeight - self.tabBar.frame.height - objectVC.getMiniPlayerHeight())
        
        // Set the sectionVC tab bar to hide as we show objectVC
        self.tabBar.frame.origin.y = screenHeight - (tabBar.bounds.height * yPct)
    }
    
    func objectViewControllerDidShowMiniPlayer(controller: ObjectViewController) {
        currentViewController?.recalculateViewableMapArea()
    }
}



// MARK: Section view controller delegates

// Generic delegate for any view controller changing the size they want to display the map
extension SectionsViewController : SectionViewControllerDelegate {
    func sectionViewController(_ sectionViewController: SectionViewController, viewableMapAreaDidChange viewableArea: CGRect) {
        mapVC.setViewableArea(frame: viewableArea)
    }
}

// AudioGuide delegate
extension SectionsViewController : AudioGuideSectionViewControllerDelegate {
    func audioGuideDidSelectObject(object: AICObjectModel, audioGuideID: Int) {
        showAudioGuideObject(object: object, audioGuideID: audioGuideID)
    }
}

// NewsTours Delegate methods
extension SectionsViewController : NewsToursSectionViewControllerDelegate {
    func newsToursSectionViewController(_ controller: NewsToursSectionViewController, didCloseReveal reveal: NewsToursRevealView) {
        mapVC.showDisabled()
    }
}

// WhatsOn Delegate Methods
extension SectionsViewController : WhatsOnSectionViewControllerDelegate {
    func whatsOnSectionViewController(_ whatsOnSectionViewController: WhatsOnSectionViewController, shouldShowNewsItemOnMap item: AICNewsItemModel) {
        locationManager.delegate = mapVC
        
        mapVC.showNews(forNewsItem: item)
        
        AICAnalytics.sendNewsItemDidShowOnMapEvent(forNewsItem: item)
    }
}

// Tours Delegate Methods
extension SectionsViewController : ToursSectionViewControllerDelegate {
    func toursSectionDidShowTour(tour: AICTourModel) {
        locationManager.delegate = mapVC
        mapVC.showTour(forTour: tour)
        
        // Log Analytics
        AICAnalytics.sendTourDidStartEvent(forTour: tour)
    }
    
    func toursSectionDidFocusOnTourOverview(tour: AICTourModel) {
        mapVC.showTourOverview(forTourModel: tour)
    }
    
    func toursSectionDidFocusOnTourStop(tour: AICTourModel, stopIndex:Int) {
        mapVC.highlightTourStop(forTour: tour, atStopIndex: stopIndex)
    }
    
    func toursSectionDidSelectTourOverview(tour:AICTourModel) {
        showTourOverview(forTourModel: tour)
    }
    
    func toursSectionDidSelectTourStop(tour: AICTourModel, stopIndex:Int) {
        showTourStop(forTourModel: tour, atStopIndex:stopIndex)
    }
    
    func toursSectionDidLeaveTour(tour: AICTourModel) {
        // Log analytics
        AICAnalytics.sendTourDidLeaveEvent(forTour: tour)
    }
}

// MARK: Map Delegate Methods
extension SectionsViewController : MapViewControllerDelegate {
    func mapViewControllerObjectPlayRequested(_ object: AICObjectModel) {
        showMapObject(forObjectModel: object)
    }
    
    func mapViewControllerDidSelectTourStop(_ stopObject: AICObjectModel) {
        if currentViewController == toursVC {
            toursVC.showTourStop(forStopObjectModel: stopObject)
        }
    }
}

// MARK: Message Delegate Methods
extension SectionsViewController : MessageViewDelegate {
    func messageViewActionSelected(_ messageView: UIView) {
        if messageView == leaveCurrentTourMessageView {
            hideLeaveTourMessage()
            
            if let requestedTour = self.requestedTour {
                self.requestedTour = nil
                toursVC.removeCurrentTour()
                startTour(tour: requestedTour)
            } else {
                removeCurrentTour()
            }
        }
            
        else if messageView == enableLocationMessageView {
            hideEnableLocationMessage()
            startLocationManager()
        }
        
        else if messageView == headphonesMessageView {
            hideHeadphonesMessage()
        }
        
        else {
            print("Unhandled message view action")
        }
    }
    
    func messageViewCancelSelected(_ messageView: UIView) {
        if messageView == leaveCurrentTourMessageView {
            hideLeaveTourMessage()
            requestedTour = nil
        }
        
        else if messageView == enableLocationMessageView {
            hideEnableLocationMessage()
        }
    }
}
