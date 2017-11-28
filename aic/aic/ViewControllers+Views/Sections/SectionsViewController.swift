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
    
    //let locationManager: CLLocationManager = CLLocationManager()
    
    var objectVC:ObjectViewController = ObjectViewController();
    
    // TabBar
    var tabBar: UITabBarController = UITabBarController()
    
    // Sections
    var viewControllers: [UIViewController] = []
    
    var currentViewController:UIViewController? = nil
    var previousViewController:UIViewController? = nil
    
    var viewControllersForTabBarItems: [UITabBarItem: UIViewController] = [:]
    var tabBarItemsForViewControllers: [UIViewController: UITabBarItem] = [:]
	
	var homeVC: HomeNavigationController = HomeNavigationController(section: Common.Sections[.home]!)
    var audioGuideVC:AudioGuideSectionViewController = AudioGuideSectionViewController(section: Common.Sections[.audioGuide]!)
    //var whatsOnVC:WhatsOnSectionViewController = WhatsOnSectionViewController(section: Common.Sections[.whatsOn]!)
    //var toursVC:ToursSectionViewController = ToursSectionViewController(section: Common.Sections[.tours]!)
    //var nearbyVC:NearbySectionViewController = NearbySectionViewController(section: Common.Sections[.map]!)
	var nearbyVC: MapSectionViewController = MapSectionViewController()
	var infoVC:InfoNavigationController = InfoNavigationController(section: Common.Sections[.info]!)
    
    // Messages
    fileprivate var requestedTour:AICTourModel? = nil
    fileprivate var leaveCurrentTourMessageView:UIView? = nil

    //fileprivate var enableLocationMessageView:UIView? = nil
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
			homeVC,
            audioGuideVC,
            nearbyVC,
            infoVC
        ]
        
        // Setup and add the tabbar
		tabBar.view.frame = UIScreen.main.bounds
		tabBar.tabBar.tintColor = .aicHomeColor
        tabBar.tabBar.backgroundColor = .aicTabbarColor
        tabBar.tabBar.barStyle = UIBarStyle.black
		tabBar.viewControllers = self.viewControllers
		
        // Setup and add contentView
        //mapVC.view.alpha = 0.0
        
        // Add Views
        //view.addSubview(mapVC.view)
        view.addSubview(objectVC.view)
		self.tabBar.willMove(toParentViewController: self)
        view.addSubview(self.tabBar.view)
		self.tabBar.didMove(toParentViewController: self)
        
        // Set delegates
        tabBar.delegate         = self
        //mapVC.delegate          = self
        objectVC.delegate       = self
        audioGuideVC.delegate   = self
        
        //whatsOnVC.newsToursDelegate = self
        //whatsOnVC.delegate          = self
        
        //toursVC.newsToursDelegate   = self
        //toursVC.delegate            = self
        
        //locationManager.delegate = mapVC
        
        //startLocationManager()
    }
    
    func setSelectedSection(sectionVC:UIViewController) {
        // If tours tab was pressed when on a tour
        /*if sectionVC == currentViewController && sectionVC == toursVC {
            if toursVC.currentTour != nil {
                showLeaveTourMessage()
                return
            }
        }*/
        
        previousViewController = currentViewController
        currentViewController = sectionVC
        
        // Update colors for this VC
		if let sVC: SectionViewController = sectionVC as? SectionViewController {
			tabBar.tabBar.tintColor = sVC.color
			objectVC.setProgressBarColor(sVC.color)
			//mapVC.color = sVC.color
			// Tell the map what region this view shows
			//mapVC.setViewableArea(frame: sVC.viewableMapArea)
		}
		else if let sNC: SectionNavigationController = sectionVC as? SectionNavigationController {
			tabBar.tabBar.tintColor = sNC.color
		}
        
        // Set the map mode
//        switch sectionVC {
//        //case nearbyVC:
//            //locationManager.delegate = mapVC
//            //mapVC.showAllInformation()
//
//        /*case toursVC:
//            // If we were previously showing a tour,
//            // show it on the map again
//            if let currentTour = toursVC.currentTour {
//                mapVC.showTour(forTour: currentTour, andRestoreState: true)
//                locationManager.delegate = mapVC
//            } else {
//                disableMap(locationManagerDelegate:toursVC)
//            }
//          */
//        default:
//            disableMap(locationManagerDelegate: nil)
//        }
		
		if let sVC: SectionViewController = sectionVC as? SectionViewController {
			sVC.reset()
		}
        sectionVC.view.setNeedsUpdateConstraints()
    }
    
    /*fileprivate func removeCurrentTour() {
        disableMap(locationManagerDelegate: toursVC)
        toursVC.removeCurrentTour()
        toursVC.reset()
    }*/
    
    
    func disableMap(locationManagerDelegate:CLLocationManagerDelegate?) {
        //locationManager.delegate = locationManagerDelegate
        //mapVC.showDisabled()
    }
    
    // Intro animation
    func animateInInitialView() {
        //mapVC.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut,
                                   animations:  {
                                    //self.mapVC.view.alpha = 1.0
            }, completion: { (value:Bool) in

                self.delegate?.sectionsViewControllerDidFinishAnimatingIn()
        })
        Common.DeepLinks.loadedEnoughToLink = true
        (UIApplication.shared.delegate as? AppDelegate)?.triggerDeepLinkIfPresent()
    }
    
    func startTour(tour:AICTourModel) {
        /*if toursVC.currentTour != nil {
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
        AICAnalytics.sendTourStartedFromLinkEvent(forTour: tour)*/
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
//        if currentViewController == toursVC {
//            guard let currentTour = toursVC.currentTour else {
//                print("Could not display object because it isn't on currently displayed tour.")
//                return
//            }
//
//            guard let tourStopIndex = currentTour.getIndex(forStopObject: object) else {
//                print("Could not get index for tour object.")
//                return
//            }
//
//            showTourStop(forTourModel: currentTour, atStopIndex: tourStopIndex)
//        } else {
            showObject(object: object, audioGuideID: nil)
//        }
		
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
//    fileprivate func startLocationManager() {
//        //See if we need to prompt first
//        let defaults = UserDefaults.standard
//        let showEnableLocationMessageValue = defaults.bool(forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
//        
//        // If we do show it
//        if showEnableLocationMessageValue {
//            showEnableLocationMessage()
//        } else {  // Otherwise try to start the location manager
//            // Init location manager
//            locationManager.requestWhenInUseAuthorization()
//            locationManager.startUpdatingLocation()
//            locationManager.startUpdatingHeading()
//        }
//    }
    
    
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
	
//	fileprivate func showEnableLocationMessage() {
//		let enableLocationView = MessageLargeView(model: Common.Messages.enableLocation)
//		enableLocationView.delegate = self
//		
//		self.enableLocationMessageView = enableLocationView
//		view.addSubview(enableLocationView)
//	}
    
//	fileprivate func hideEnableLocationMessage() {
//		if let enableLocationMessageView = self.enableLocationMessageView {
//			// Update user defaults
//			let defaults = UserDefaults.standard
//			defaults.set(false, forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
//			defaults.synchronize()
//			
//			enableLocationMessageView.removeFromSuperview()
//			self.enableLocationMessageView = nil
//		}
//	}
    
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
extension SectionsViewController : UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		setSelectedSection(sectionVC: viewController)
	}
}

// ObjectViewController Delegate
extension SectionsViewController : ObjectViewControllerDelegate {
    // When the Object View Controller Moves up (out of mini player mode)
    // We hide the bottom navigation
    func objectViewController(controller:ObjectViewController, didUpdateYPosition position:CGFloat) {
        let screenHeight = UIScreen.main.bounds.height
        let yPct:CGFloat = (position) / (screenHeight - self.tabBar.tabBar.frame.height - objectVC.getMiniPlayerHeight())
        
        // Set the sectionVC tab bar to hide as we show objectVC
        self.tabBar.tabBar.frame.origin.y = screenHeight - (tabBar.tabBar.bounds.height * yPct)
    }
    
    func objectViewControllerDidShowMiniPlayer(controller: ObjectViewController) {
	}
}



// MARK: Section view controller delegates

// AudioGuide delegate
extension SectionsViewController : AudioGuideSectionViewControllerDelegate {
    func audioGuideDidSelectObject(object: AICObjectModel, audioGuideID: Int) {
        showAudioGuideObject(object: object, audioGuideID: audioGuideID)
    }
}

// NewsTours Delegate methods
extension SectionsViewController : NewsToursSectionViewControllerDelegate {
    func newsToursSectionViewController(_ controller: NewsToursSectionViewController, didCloseReveal reveal: NewsToursRevealView) {
        //mapVC.showDisabled()
    }
}

// WhatsOn Delegate Methods
extension SectionsViewController : WhatsOnSectionViewControllerDelegate {
    func whatsOnSectionViewController(_ whatsOnSectionViewController: WhatsOnSectionViewController, shouldShowNewsItemOnMap item: AICNewsItemModel) {
        //locationManager.delegate = mapVC
        
        //mapVC.showNews(forNewsItem: item)
        
        AICAnalytics.sendNewsItemDidShowOnMapEvent(forNewsItem: item)
    }
}

// Tours Delegate Methods
extension SectionsViewController : ToursSectionViewControllerDelegate {
    func toursSectionDidShowTour(tour: AICTourModel) {
        //locationManager.delegate = mapVC
        //mapVC.showTour(forTour: tour)
        
        // Log Analytics
        AICAnalytics.sendTourDidStartEvent(forTour: tour)
    }
    
    func toursSectionDidFocusOnTourOverview(tour: AICTourModel) {
        //mapVC.showTourOverview(forTourModel: tour)
    }
    
    func toursSectionDidFocusOnTourStop(tour: AICTourModel, stopIndex:Int) {
        //mapVC.highlightTourStop(forTour: tour, atStopIndex: stopIndex)
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
//        if currentViewController == toursVC {
//            toursVC.showTourStop(forStopObjectModel: stopObject)
//        }
    }
}

// MARK: Message Delegate Methods
extension SectionsViewController : MessageViewDelegate {
    func messageViewActionSelected(_ messageView: UIView) {
        if messageView == leaveCurrentTourMessageView {
            hideLeaveTourMessage()
            
            if let requestedTour = self.requestedTour {
                self.requestedTour = nil
//                toursVC.removeCurrentTour()
                startTour(tour: requestedTour)
            } else {
//                removeCurrentTour()
            }
        }
            
        /*else if messageView == enableLocationMessageView {
            hideEnableLocationMessage()
            //startLocationManager()
        }*/
        
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
        
        /*else if messageView == enableLocationMessageView {
            hideEnableLocationMessage()
        }*/
    }
}
