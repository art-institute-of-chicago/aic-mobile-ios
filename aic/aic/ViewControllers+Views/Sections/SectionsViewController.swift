/*
 Abstract:
 Main Section controller, contains MapView, UITabBar and Object View.
*/

import UIKit
import MapKit
import Localize_Swift

protocol SectionsViewControllerDelegate : class {
    func sectionsViewControllerDidFinishAnimatingIn()
}

class SectionsViewController : UIViewController {
    weak var delegate: SectionsViewControllerDelegate? = nil
	
	// AudioPlayer Card
    let audioPlayerVC: AudioPlayerNavigationController = AudioPlayerNavigationController()
	
	// Content Card
	var contentCardVC: ContentCardNavigationController? = nil
	
	// Search Card
	let searchVC: SearchNavigationController = SearchNavigationController()
    
    // TabBar
    var sectionTabBarController: UITabBarController = UITabBarController()
    
    // Sections
	var homeVC: HomeNavigationController = HomeNavigationController(section: Common.Sections[.home]!)
	var audioGuideVC: AudioGuideNavigationController = AudioGuideNavigationController(section: Common.Sections[.audioGuide]!)
	var mapVC: MapNavigationController = MapNavigationController(section: Common.Sections[.map]!)
	var infoVC: InfoNavigationController = InfoNavigationController(section: Common.Sections[.info]!)
	
    var sectionViewControllers: [SectionNavigationController] = []
    
    var currentViewController: SectionNavigationController
    var previousViewController: SectionNavigationController? = nil
    
    // Messages
	fileprivate var headphonesMessageView: MessageViewController? = nil
	
    fileprivate var requestedTour: AICTourModel? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		currentViewController = homeVC
        super.init(nibName: nil, bundle: nil)
    }
	
	required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
    
    override func viewDidLoad() {
        // Set the view controllers for the tab bar
        sectionViewControllers = [
			homeVC,
            audioGuideVC,
            mapVC,
            infoVC
        ]
        
        // Setup and add the tabbar
		sectionTabBarController.view.frame = UIScreen.main.bounds
		sectionTabBarController.tabBar.tintColor = .aicHomeColor
        sectionTabBarController.tabBar.backgroundColor = .aicTabbarColor
        sectionTabBarController.tabBar.barStyle = UIBarStyle.black
		sectionTabBarController.viewControllers = sectionViewControllers
        
        // Add Views
		sectionTabBarController.willMove(toParentViewController: self)
        view.addSubview(sectionTabBarController.view)
		sectionTabBarController.didMove(toParentViewController: self)
		
        audioPlayerVC.willMove(toParentViewController: sectionTabBarController)
        sectionTabBarController.view.insertSubview(audioPlayerVC.view, belowSubview: sectionTabBarController.tabBar)
        audioPlayerVC.didMove(toParentViewController: sectionTabBarController)
		
		searchVC.willMove(toParentViewController: self.sectionTabBarController)
		sectionTabBarController.view.insertSubview(searchVC.view, belowSubview: audioPlayerVC.view)
		searchVC.didMove(toParentViewController: self.sectionTabBarController)
		
		// Set delegates
		homeVC.sectionDelegate = self
		mapVC.sectionDelegate = self
		audioGuideVC.sectionDelegate = self
        sectionTabBarController.delegate = self
		searchVC.cardDelegate = self
		searchVC.sectionsVC = self
		searchVC.resultsVC.sectionsVC = self
        audioPlayerVC.cardDelegate = self
		
		// Search Buttons
		for sectionVC in sectionViewControllers {
			sectionVC.sectionNavigationBar.searchButton.addTarget(self, action: #selector(searchButtonPressed(button:)), for: .touchUpInside)
		}
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLanguage()
	}
	
	// MARK: Section Navigation
	
    private func setSelectedSection(sectionVC: SectionNavigationController) {
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
		sectionTabBarController.tabBar.tintColor = sectionVC.color
		audioPlayerVC.setProgressBarColor(color: sectionVC.color)
		
		// Card operations
		if currentViewController != previousViewController {
			if searchVC.currentState == .fullscreen {
				searchVC.hide()
			}
			if let contentCardVC = self.contentCardVC {
				contentCardVC.hide()
			}
		}
		
        sectionVC.view.setNeedsUpdateConstraints()
    }
    
    /*fileprivate func removeCurrentTour() {
        disableMap(locationManagerDelegate: toursVC)
        toursVC.removeCurrentTour()
        toursVC.reset()
    }*/
    
	// MARK: Intro animation (deprecated)
	// TODO: remove function but keep deep link to related tour
    func animateInInitialView() {
		sectionTabBarController.view.alpha = 0.0
        homeVC.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut,
                                   animations:  {
									self.sectionTabBarController.view.alpha = 1.0
                                    self.homeVC.view.alpha = 1.0
            }, completion: { (value:Bool) in
                self.delegate?.sectionsViewControllerDidFinishAnimatingIn()
        })
        Common.DeepLinks.loadedEnoughToLink = true
        (UIApplication.shared.delegate as? AppDelegate)?.triggerDeepLinkIfPresent()
    }
	
	// MARK: Show On Map
    
	func showTourOnMap(tour: AICTourModel, language: Common.Language, stopIndex: Int?) {
        /*if toursVC.currentTour != nil {
            self.requestedTour = tour
            showLeaveTourMessage()
            return
        }*/
		
		if currentViewController != mapVC {
			setSelectedSection(sectionVC: mapVC)
		}
		mapVC.showTour(tour: tour, language: language, stopIndex: stopIndex)
		sectionTabBarController.selectedIndex = 2
		
        // If this is coming from an object view,
        //show the mini player to reveal tour below
//        if objectVC.mode != .hidden {
//            objectVC.showMiniPlayer()
//        }
		
        // Log Analytics
//        AICAnalytics.sendTourStartedFromLinkEvent(forTour: tour)
    }
	
	func showArtworkOnMap(artwork: AICObjectModel) {
		if currentViewController != mapVC {
			setSelectedSection(sectionVC: mapVC)
		}
		mapVC.showArtwork(artwork: artwork)
		sectionTabBarController.selectedIndex = 2
	}
	
	func showSearchedArtworkOnMap(searchedArtwork: AICSearchedArtworkModel) {
		if currentViewController != mapVC {
			setSelectedSection(sectionVC: mapVC)
		}
		mapVC.showSearchedArtwork(searchedArtwork: searchedArtwork)
		sectionTabBarController.selectedIndex = 2
	}
	
	func showExhibitionOnMap(exhibition: AICExhibitionModel) {
		if currentViewController != mapVC {
			setSelectedSection(sectionVC: mapVC)
		}
		mapVC.showExhibition(exhibition: exhibition)
		sectionTabBarController.selectedIndex = 2
	}
	
	func showDiningOnMap() {
		if currentViewController != mapVC {
			setSelectedSection(sectionVC: mapVC)
		}
		mapVC.showDining()
		sectionTabBarController.selectedIndex = 2
	}
	
	func showRestroomsOnMap() {
		if currentViewController != mapVC {
			setSelectedSection(sectionVC: mapVC)
		}
		mapVC.showRestrooms()
		sectionTabBarController.selectedIndex = 2
	}
	
	func showGiftShopOnMap() {
		if currentViewController != mapVC {
			setSelectedSection(sectionVC: mapVC)
		}
		mapVC.showGiftShop()
		sectionTabBarController.selectedIndex = 2
	}
    
    // MARK: Play Audio
	
	private func playArtwork(artwork: AICObjectModel, audio: AICAudioFileModel) {
		audioPlayerVC.playArtworkAudio(artwork: artwork, audio: audio)
		showHeadphonesMessage()
    }
    
    private func playAudioGuideArtwork(artwork: AICObjectModel, audioGuideID: Int) {
		var audio = AppDataManager.sharedInstance.getAudioFile(forObject: artwork, selectorNumber: audioGuideID)
		audio.language = Common.currentLanguage
		
		playArtwork(artwork: artwork, audio: audio)
		audioPlayerVC.showFullscreen()
        
        // Log analytics
//        AICAnalytics.sendAudioGuideDidShowObjectEvent(forObject: object)
    }
    
    private func playMapArtwork(artwork: AICObjectModel) {
		var audio = AppDataManager.sharedInstance.getAudioFile(forObject: artwork, selectorNumber: nil)
		audio.language = Common.currentLanguage
		
		playArtwork(artwork: artwork, audio: audio)
		audioPlayerVC.showMiniPlayer()
		
        // Log analytics
		// TODO: Log as played map object
//        AICAnalytics.sendMapDidShowObjectEvent(forObject: object)
    }
	
	private func playSearchedArtwork(artwork: AICObjectModel) {
		var audio = AppDataManager.sharedInstance.getAudioFile(forObject: artwork, selectorNumber: nil)
		audio.language = Common.currentLanguage
		
		playArtwork(artwork: artwork, audio: audio)
		audioPlayerVC.showMiniPlayer()
		
		// Log analytics
		// TODO: Log as played search object
//        AICAnalytics.sendMapDidShowObjectEvent(forObject: object)
	}
	
	private func playTourStop(tourStop: AICTourStopModel, tour: AICTourModel) {
		audioPlayerVC.playTourStopAudio(tourStop: tourStop, tour: tour)
		audioPlayerVC.showMiniPlayer()
		
		// Log analytics
		//        AICAnalytics.sendTourDidShowObjectEvent(forObject: tour.stops[stopIndex].object)
	}
    
    private func playTourOverview(tour: AICTourModel, language: Common.Language) {
		audioPlayerVC.playTourOverviewAudio(tour: tour)
		audioPlayerVC.showMiniPlayer()
		
        // Log analytics
//        AICAnalytics.sendTourDidShowOverviewEvent(forTour: tour)
    }
	
	// MARK: Show/Hide Search Button
	
	private func setSearchButtonEnabled(_ enabled: Bool) {
		for sectionVC in sectionViewControllers {
			sectionVC.sectionNavigationBar.searchButton.isEnabled = enabled
			sectionVC.sectionNavigationBar.searchButton.isHidden = !enabled
		}
	}
	
    // MARK: Messages
    
    fileprivate func showHeadphonesMessage() {
        let defaults = UserDefaults.standard
        let showHeadphonesMessage = defaults.bool(forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
        
        if showHeadphonesMessage {
            headphonesMessageView = MessageViewController(message: Common.Messages.useHeadphones)
            headphonesMessageView!.delegate = self
			
            // Modal presentation style
            headphonesMessageView!.definesPresentationContext = true
            headphonesMessageView!.providesPresentationContextTransitionStyle = true
            headphonesMessageView!.modalPresentationStyle = .overFullScreen
            headphonesMessageView!.modalTransitionStyle = .crossDissolve
            
            self.present(headphonesMessageView!, animated: true, completion: nil)
        }
    }
    
    fileprivate func hideHeadphonesMessage() {
        if let messageView = headphonesMessageView {
            // Update user defaults
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
            defaults.synchronize()
            
            messageView.dismiss(animated: true, completion: nil)
            headphonesMessageView = nil
        }
    }
	
	@objc func searchButtonPressed(button: UIButton) {
		searchVC.showFullscreen()
	}
	
	// MARK: Language
	@objc func updateLanguage() {
		sectionTabBarController.tabBar.items![0].title = "Home".localized(using: "TabMenu")
		sectionTabBarController.tabBar.items![1].title = "Audio".localized(using: "TabMenu")
		sectionTabBarController.tabBar.items![2].title = "Map".localized(using: "TabMenu")
		sectionTabBarController.tabBar.items![3].title = "Info".localized(using: "TabMenu")
	}
}

// MARK: SectionTabBarController Delegate Methods
extension SectionsViewController : UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		if let sectionVC = viewController as? SectionNavigationController {
			setSelectedSection(sectionVC: sectionVC)
		}
	}
}

// MARK: Home Delegate

extension SectionsViewController : HomeNavigationControllerDelegate {
	func showMemberCard() {
		setSelectedSection(sectionVC: infoVC)
		infoVC.shouldShowMemberCard = true
		sectionTabBarController.selectedIndex = 3
	}
	
	func showTourCard(tour: AICTourModel) {
		let tourTableVC = TourTableViewController(tour: tour)
		tourTableVC.tourTableDelegate = self
		showContentCard(ContentCardNavigationController(tableVC: tourTableVC))
	}
	
	func showExhibitionCard(exhibition: AICExhibitionModel) {
		let exhibitionTableVC = ExhibitionTableViewController(exhibition: exhibition)
		exhibitionTableVC.exhibitionTableDelegate = self
		showContentCard(ContentCardNavigationController(tableVC: exhibitionTableVC))
	}
	
	func showEventCard(event: AICEventModel) {
		let eventTableVC = EventTableViewController(event: event)
		showContentCard(ContentCardNavigationController(tableVC: eventTableVC))
	}
	
	func showContentCard(_ contentCardVC: ContentCardNavigationController) {
		if let cardVC = self.contentCardVC {
			cardVC.view.removeFromSuperview()
		}
		self.contentCardVC = contentCardVC
		contentCardVC.cardDelegate = self
		
		contentCardVC.willMove(toParentViewController: sectionTabBarController)
		sectionTabBarController.view.insertSubview(contentCardVC.view, aboveSubview: searchVC.view)
		contentCardVC.didMove(toParentViewController: sectionTabBarController)
		
		contentCardVC.showFullscreen()
	}
}

// MARK: AudioGuide Delegate
extension SectionsViewController : AudioGuideNavigationControllerDelegate {
    func audioGuideDidSelectObject(object: AICObjectModel, audioGuideID: Int) {
        playAudioGuideArtwork(artwork: object, audioGuideID: audioGuideID)
    }
}

// Tours Delegate Methods
//extension SectionsViewController : ToursSectionViewControllerDelegate {
//    func toursSectionDidShowTour(tour: AICTourModel) {
//        //locationManager.delegate = mapVC
//        //mapVC.showTour(forTour: tour)
//
//        // Log Analytics
//        AICAnalytics.sendTourDidStartEvent(forTour: tour)
//    }
//
//    func toursSectionDidFocusOnTourOverview(tour: AICTourModel) {
//        //mapVC.showTourOverview(forTourModel: tour)
//    }
//
//    func toursSectionDidFocusOnTourStop(tour: AICTourModel, stopIndex: Int) {
//        //mapVC.highlightTourStop(forTour: tour, atStopIndex: stopIndex)
//    }
//
//    func toursSectionDidSelectTourOverview(tour:AICTourModel) {
//        playTourOverview(forTourModel: tour)
//    }
//
//    func toursSectionDidSelectTourStop(tour: AICTourModel, stopIndex:Int) {
//        playTourStop(forTourModel: tour, atStopIndex:stopIndex)
//    }
//
//    func toursSectionDidLeaveTour(tour: AICTourModel) {
//        // Log analytics
//        AICAnalytics.sendTourDidLeaveEvent(forTour: tour)
//    }
//}

// MARK: Map Delegate
extension SectionsViewController : MapNavigationControllerDelegate {
	func mapDidSelectPlayAudioForArtwork(artwork: AICObjectModel) {
		playMapArtwork(artwork: artwork)
	}
	
	func mapDidSelectPlayAudioForTour(tour: AICTourModel, language: Common.Language) {
		playTourOverview(tour: tour, language: language)
	}
	
	func mapDidSelectPlayAudioForTourStop(tourStop: AICTourStopModel, tour: AICTourModel, language: Common.Language) {
		var tourModel = tour
		tourModel.language = language
		playTourStop(tourStop: tourStop, tour: tourModel)
	}
}

// MARK: Message Delegate
extension SectionsViewController : MessageViewControllerDelegate {
    func messageViewActionSelected(messageVC: MessageViewController) {
		if messageVC == headphonesMessageView {
			hideHeadphonesMessage()
		}
//        if messageVC.view == leaveCurrentTourMessageView {
//            hideLeaveTourMessage()
//
//            if let requestedTour = self.requestedTour {
//                self.requestedTour = nil
////                toursVC.removeCurrentTour()
//                //startTour(tour: requestedTour)
//            } else {
////                removeCurrentTour()
//            }
//        }
    }
    
    func messageViewCancelSelected(messageVC: MessageViewController) {
//        if messageVC.view == leaveCurrentTourMessageView {
//            hideLeaveTourMessage()
//            requestedTour = nil
//        }
    }
}

// MARK: Card Delegate
extension SectionsViewController : CardNavigationControllerDelegate {
    // When the Audio Player goes fullscreen hide the TabBar
    func cardDidUpdatePosition(cardVC: CardNavigationController, position: CGPoint) {
        if cardVC == audioPlayerVC {
            let screenHeight = UIScreen.main.bounds.height
            
            var percentageY: CGFloat = position.y / (screenHeight - self.sectionTabBarController.tabBar.frame.height - Common.Layout.miniAudioPlayerHeight)
            percentageY = clamp(val: percentageY, minVal: 0.0, maxVal: 1.0)
            
            // Set the sectionVC tab bar to hide as we show audioPlayerVC
            self.sectionTabBarController.tabBar.frame.origin.y = screenHeight - (sectionTabBarController.tabBar.bounds.height * percentageY)
        }
    }
	
	func cardWillShowFullscreen(cardVC: CardNavigationController) {
		setSearchButtonEnabled(false)
		
		// close content card or search card, if open
		if cardVC == audioPlayerVC {
			if let contentCard = contentCardVC {
				if contentCard.currentState == .fullscreen {
					contentCard.hide()
				}
			}
			if searchVC.currentState == .fullscreen {
				searchVC.hide()
			}
		}
	}
	
	func cardDidShowMiniplayer(cardVC: CardNavigationController) {
		if cardVC == audioPlayerVC {
			// when you play artwork for an artwork you found on the search
			// make sure search is not fullscreen before you re-enable the search button
			if searchVC.currentState != .fullscreen {
				setSearchButtonEnabled(true)
			}
		}
	}
    
	func cardDidHide(cardVC: CardNavigationController) {
		// make sure there's no other card fullscreen, befiore you re-enable the search button
		if audioPlayerVC.currentState != .fullscreen {
			setSearchButtonEnabled(true)
		}
		if cardVC.isKind(of: ContentCardNavigationController.self) {
			cardVC.view.removeFromSuperview()
		}
	}
}

// MARK: Tour Content Card Delegate
extension SectionsViewController : TourTableViewControllerDelegate {
	// Pressed "Start Tour" or tour stop in content card
	func tourContentCardDidPressStartTour(tour: AICTourModel, language: Common.Language, stopIndex: Int?) {
		if searchVC.currentState == .fullscreen {
			searchVC.hide()
		}
		showTourOnMap(tour: tour, language: language, stopIndex: stopIndex)
	}
}

// MARK: Artwork Content Card Delegate
extension SectionsViewController : ArtworkTableViewControllerDelegate {
	// Pressed "Start Tour" or tour stop in content card
	func artworkContentCardDidPressPlayAudio(artwork: AICObjectModel) {
		playSearchedArtwork(artwork: artwork)
	}
	
	func artworkContentCardDidPressShowOnMap(artwork: AICSearchedArtworkModel) {
		if searchVC.currentState == .fullscreen {
			searchVC.hide()
		}
		showSearchedArtworkOnMap(searchedArtwork: artwork)
	}
}

//MARK: Exhibition Content Card Delegate
extension SectionsViewController : ExhibitionTableViewControllerDelegate {
	func exhibitionContentCardDidPressShowOnMap(exhibition: AICExhibitionModel) {
		showExhibitionOnMap(exhibition: exhibition)
	}
}

// MARK: Search Map Items Collection Delegate
extension SectionsViewController : MapItemsCollectionContainerDelegate {
	func mapItemDiningSelected() {
		if searchVC.currentState == .fullscreen {
			searchVC.hide()
		}
		showDiningOnMap()
	}
	
	func mapItemGiftShopSelected() {
		if searchVC.currentState == .fullscreen {
			searchVC.hide()
		}
		showGiftShopOnMap()
	}
	
	func mapItemRestroomSelected() {
		if searchVC.currentState == .fullscreen {
			searchVC.hide()
		}
		showRestroomsOnMap()
	}
	
	func mapItemArtworkSelected(artwork: AICObjectModel) {
		if searchVC.currentState == .fullscreen {
			searchVC.hide()
		}
		showArtworkOnMap(artwork: artwork)
	}
}
