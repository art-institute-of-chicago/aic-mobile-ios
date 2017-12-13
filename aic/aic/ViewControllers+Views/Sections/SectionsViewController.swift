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
	
	// Object Audio Card
    let objectVC: ObjectViewController = ObjectViewController();
	
	// Search Card
	let searchVC: SearchNavigationController = SearchNavigationController()
	
	// Search Button
	let searchButton: UIButton = UIButton()
    
    // TabBar
    var sectionTabBarController: UITabBarController = UITabBarController()
    
    // Sections
    var viewControllers: [UIViewController] = []
    
    var currentViewController:UIViewController? = nil
    var previousViewController:UIViewController? = nil
    
    var viewControllersForTabBarItems: [UITabBarItem: UIViewController] = [:]
    var tabBarItemsForViewControllers: [UIViewController: UITabBarItem] = [:]
	
	var homeVC: HomeNavigationController = HomeNavigationController(section: Common.Sections[.home]!)
    var audioGuideVC:AudioGuideNavigationController = AudioGuideNavigationController(section: Common.Sections[.audioGuide]!)
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
    
    override func viewDidLoad() {
        // Set the view controllers for the tab bar
        self.viewControllers = [
			homeVC,
            audioGuideVC,
            nearbyVC,
            infoVC
        ]
        
        // Setup and add the tabbar
		sectionTabBarController.view.frame = UIScreen.main.bounds
		sectionTabBarController.tabBar.tintColor = .aicHomeColor
        sectionTabBarController.tabBar.backgroundColor = .aicTabbarColor
        sectionTabBarController.tabBar.barStyle = UIBarStyle.black
		sectionTabBarController.viewControllers = self.viewControllers
		
		// Setup Search Button
		searchButton.setImage(#imageLiteral(resourceName: "iconSearch"), for: .normal)
		searchButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
		searchButton.addTarget(self, action: #selector(searchButtonPressed(button:)), for: .touchUpInside)
		
        // Setup and add contentView
        //mapVC.view.alpha = 0.0
        
        // Add Views
		sectionTabBarController.willMove(toParentViewController: self)
        view.addSubview(sectionTabBarController.view)
		sectionTabBarController.didMove(toParentViewController: self)
		
		view.addSubview(searchButton)
		
		objectVC.willMove(toParentViewController: sectionTabBarController)
		sectionTabBarController.view.insertSubview(objectVC.view, belowSubview: sectionTabBarController.tabBar)
		objectVC.willMove(toParentViewController: sectionTabBarController)
		
		searchVC.willMove(toParentViewController: self.sectionTabBarController)
		sectionTabBarController.view.insertSubview(searchVC.view, belowSubview:self.objectVC.view)
		searchVC.didMove(toParentViewController: self.sectionTabBarController)
		
		// Set delegates
		sectionTabBarController.delegate = self
		objectVC.delegate = self
		audioGuideVC.audioGuideDelegate = self
		searchVC.searchCardDelegate = self
        
        //whatsOnVC.newsToursDelegate = self
        //whatsOnVC.delegate          = self
        
        //toursVC.newsToursDelegate   = self
        //toursVC.delegate            = self
        
        //locationManager.delegate = mapVC
        
        //startLocationManager()
		
		createViewConstraints()
    }
	
	func createViewConstraints() {
		searchButton.autoSetDimensions(to: CGSize(width: 44, height: 44))
		searchButton.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -6)
		searchButton.autoPinEdge(.bottom, to: .top, of: self.view, withOffset: Common.Layout.navigationBarMinimizedHeight - 3)
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
		if let sVC = sectionVC as? SectionNavigationController {
			sectionTabBarController.tabBar.tintColor = sVC.color
			objectVC.setProgressBarColor(sVC.color)
			//mapVC.color = sVC.color
			// Tell the map what region this view shows
			//mapVC.setViewableArea(frame: sVC.viewableMapArea)
		}
			// TODO: instead of checking for mapVC, make mapVC a SectionNavigationController
		else if let sVC = sectionVC as? MapSectionViewController {
			sectionTabBarController.tabBar.tintColor = .aicMapColor
			objectVC.setProgressBarColor(.aicMapColor)
		}
		
		// Card operations
		if currentViewController != previousViewController {
			if searchVC.currentState == .fullscreen {
				searchVC.hide()
			}
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
		sectionTabBarController.view.alpha = 0.0
        homeVC.view.alpha = 0.0
		searchButton.isHidden = true
		searchButton.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut,
                                   animations:  {
									self.sectionTabBarController.view.alpha = 1.0
                                    self.homeVC.view.alpha = 1.0
            }, completion: { (value:Bool) in
				self.searchButton.isHidden = false
				self.searchButton.isEnabled = true
				
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
	
	@objc func searchButtonPressed(button: UIButton) {
		searchButton.isHidden = true
		searchButton.isEnabled = false
		searchVC.showFullscreen()
	}
}

// MARK: SectionTabBarController Delegate Methods
extension SectionsViewController : UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		setSelectedSection(sectionVC: viewController)
	}
}

// MARK: ObjectViewController Delegate
extension SectionsViewController : ObjectViewControllerDelegate {
    // When the Object View Controller Moves up (out of mini player mode)
    // We hide the bottom navigation
    func objectViewController(controller:ObjectViewController, didUpdateYPosition position:CGFloat) {
        let screenHeight = UIScreen.main.bounds.height
        let yPct:CGFloat = (position) / (screenHeight - self.sectionTabBarController.tabBar.frame.height - objectVC.getMiniPlayerHeight())
        
        // Set the sectionVC tab bar to hide as we show objectVC
        self.sectionTabBarController.tabBar.frame.origin.y = screenHeight - (sectionTabBarController.tabBar.bounds.height * yPct)
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

// MARK: Search Card Delegate
extension SectionsViewController : SearchCardDelegate {
	func searchCardDidHide() {
		searchButton.isHidden = false
		searchButton.isEnabled = true
	}
}
