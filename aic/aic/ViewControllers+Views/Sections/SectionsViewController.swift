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
	private var headphonesMessageVC: MessageViewController? = nil
	private var leaveTourMessageVC: MessageViewController? = nil
	
	// Content on Map
    private var requestedTour: AICTourModel? = nil
	private var requestedArtwork: AICObjectModel? = nil
	private var requestedSearchedArtwork: AICSearchedArtworkModel? = nil
	private var requestedExhibition: AICExhibitionModel? = nil
	private var requestedMapMode: MapViewController.Mode? = nil
    
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
		audioPlayerVC.sectionDelegate = self
		
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
		if searchVC.currentState == .fullscreen {
			searchVC.hide()
		}
		
		if sectionVC == currentViewController {
			return
		}
		
        previousViewController = currentViewController
        currentViewController = sectionVC
		
		// Card operations
		if currentViewController != previousViewController {
			if searchVC.currentState == .fullscreen {
				searchVC.hide()
			}
			if let contentCardVC = self.contentCardVC {
				contentCardVC.hide()
			}
			
			// Update colors for this VC
			sectionTabBarController.tabBar.tintColor = sectionVC.color
			audioPlayerVC.setProgressBarColor(color: sectionVC.color)
			
			if currentViewController == homeVC && sectionTabBarController.selectedIndex != 0 {
				sectionTabBarController.selectedIndex = 0
			}
			else if currentViewController == audioGuideVC && sectionTabBarController.selectedIndex != 1 {
				sectionTabBarController.selectedIndex = 1
			}
			else if currentViewController == mapVC && sectionTabBarController.selectedIndex != 2 {
				sectionTabBarController.selectedIndex = 2
			}
			else if currentViewController == infoVC && sectionTabBarController.selectedIndex != 3 {
				sectionTabBarController.selectedIndex = 3
			}
		}
		
        sectionVC.view.setNeedsUpdateConstraints()
    }
    
    func animateInInitialView() {
		self.view.alpha = 0.0
		self.homeVC.view.alpha = 0.0
		
		// disable parallax effect
		self.homeVC.sectionNavigationBar.disableParallaxEffect()
		
		UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut,
                                   animations:  {
									self.view.alpha = 1.0
									self.homeVC.view.alpha = 1.0
            }, completion: { (completed) in
				if completed {
					// re-enable parallax effect
					self.homeVC.sectionNavigationBar.enableParallaxEffect()
					
					// show home tooltip, if needed
					self.homeVC.showHomeTooltip()
					
					self.delegate?.sectionsViewControllerDidFinishAnimatingIn()
				}
        })
        Common.DeepLinks.loadedEnoughToLink = true
        (UIApplication.shared.delegate as? AppDelegate)?.triggerDeepLinkIfPresent()
    }
	
	// MARK: Show On Map
	
	func showTourOnMapFromLink(tour: AICTourModel, language: Common.Language) {
		showTourOnMap(tour: tour, language: language, stopIndex: nil)
	}
	
	func showTourOnMap(tour: AICTourModel, language: Common.Language, stopIndex: Int?) {
		setSelectedSection(sectionVC: mapVC)
		
		if mapVC.currentMode == .tour && self.requestedMapMode == nil {
			if let currentTour = mapVC.tourModel {
				if currentTour.nid == tour.nid && currentTour.language == tour.language {
					return
				}
			}
			
			self.requestedMapMode = .tour
			self.requestedTour = tour
			showLeaveTourMessage()
			return
		}
		
		mapVC.showTour(tour: tour, language: language, stopIndex: stopIndex)
		
        // Log Analytics
		AICAnalytics.sendTourStartedEvent(tour: tour)
		AICAnalytics.sendLanguageTourEvent(language: language, tour: tour)
    }
	
	func showArtworkOnMap(artwork: AICObjectModel) {
		setSelectedSection(sectionVC: mapVC)
		
		if mapVC.currentMode == .tour && self.requestedMapMode == nil {
			self.requestedMapMode = .artwork
			self.requestedArtwork = artwork
			showLeaveTourMessage()
			return
		}
		
		mapVC.showArtwork(artwork: artwork)
	}
	
	func showSearchedArtworkOnMap(searchedArtwork: AICSearchedArtworkModel) {
		setSelectedSection(sectionVC: mapVC)
		
		if mapVC.currentMode == .tour && self.requestedMapMode == nil {
			self.requestedMapMode = .searchedArtwork
			self.requestedSearchedArtwork = searchedArtwork
			showLeaveTourMessage()
			return
		}
		
		mapVC.showSearchedArtwork(searchedArtwork: searchedArtwork)
	}
	
	func showExhibitionOnMap(exhibition: AICExhibitionModel) {
		setSelectedSection(sectionVC: mapVC)
		
		if mapVC.currentMode == .tour && self.requestedMapMode == nil {
			self.requestedMapMode = .exhibition
			self.requestedExhibition = exhibition
			showLeaveTourMessage()
			return
		}
		
		mapVC.showExhibition(exhibition: exhibition)
	}
	
	func showDiningOnMap() {
		setSelectedSection(sectionVC: mapVC)
		
		if mapVC.currentMode == .tour && self.requestedMapMode == nil {
			self.requestedMapMode = .dining
			showLeaveTourMessage()
			return
		}
		
		mapVC.showDining()
	}
	
	func showMemberLoungeOnMap() {
		setSelectedSection(sectionVC: mapVC)
		
		if mapVC.currentMode == .tour && self.requestedMapMode == nil {
			self.requestedMapMode = .memberLounge
			showLeaveTourMessage()
			return
		}
		
		mapVC.showMemberLounge()
	}
	
	func showGiftShopOnMap() {
		setSelectedSection(sectionVC: mapVC)
		
		if mapVC.currentMode == .tour && self.requestedMapMode == nil {
			self.requestedMapMode = .giftshop
			showLeaveTourMessage()
			return
		}
		
		mapVC.showGiftShop()
	}
	
	func showRestroomsOnMap() {
		setSelectedSection(sectionVC: mapVC)
		
		if mapVC.currentMode == .tour && self.requestedMapMode == nil {
			self.requestedMapMode = .restrooms
			showLeaveTourMessage()
			return
		}
		
		mapVC.showRestrooms()
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
		AICAnalytics.sendPlayAudioFromAudioGuideEvent(artwork: artwork, selectorNumber: audioGuideID, language: audio.language)
    }
    
    private func playMapArtwork(artwork: AICObjectModel) {
		var audio = AppDataManager.sharedInstance.getAudioFile(forObject: artwork, selectorNumber: nil)
		audio.language = Common.currentLanguage
		
		playArtwork(artwork: artwork, audio: audio)
		audioPlayerVC.showMiniPlayer()
		
        // Log analytics
		AICAnalytics.sendPlayAudioFromMapEvent(artwork: artwork)
    }
	
	private func playSearchedArtwork(artwork: AICObjectModel) {
		var audio = AppDataManager.sharedInstance.getAudioFile(forObject: artwork, selectorNumber: nil)
		audio.language = Common.currentLanguage
		
		playArtwork(artwork: artwork, audio: audio)
		audioPlayerVC.showMiniPlayer()
		
		// Log analytics
		AICAnalytics.sendPlayAudioFromSearchedArtworkEvent(artwork: artwork)
	}
	
	private func playTourStop(tourStop: AICTourStopModel, tour: AICTourModel) {
		audioPlayerVC.playTourStopAudio(tourStop: tourStop, tour: tour)
		audioPlayerVC.showMiniPlayer()
		
		// Log analytics
		AICAnalytics.sendPlayAudioFromTourStopEvent(artwork: tourStop.object, tour: tour)
	}
    
    private func playTourOverview(tour: AICTourModel, language: Common.Language) {
		audioPlayerVC.playTourOverviewAudio(tour: tour)
		audioPlayerVC.showMiniPlayer()
		
		// Log analytics
		AICAnalytics.sendPlayAudioFromTourEvent(tour: tour)
    }
	
	// MARK: Show/Hide Search Button
	
	private func setSearchButtonEnabled(_ enabled: Bool) {
		for sectionVC in sectionViewControllers {
			sectionVC.sectionNavigationBar.searchButton.isEnabled = enabled
			sectionVC.sectionNavigationBar.searchButton.isHidden = !enabled
		}
	}
	
    // MARK: Headphones Messages
    
    fileprivate func showHeadphonesMessage() {
        let defaults = UserDefaults.standard
        let showHeadphonesMessage = defaults.bool(forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
        
        if showHeadphonesMessage {
            headphonesMessageVC = MessageViewController(message: Common.Messages.useHeadphones)
            headphonesMessageVC!.delegate = self
			
            // Modal presentation style
            headphonesMessageVC!.definesPresentationContext = true
            headphonesMessageVC!.providesPresentationContextTransitionStyle = true
            headphonesMessageVC!.modalPresentationStyle = .overFullScreen
            headphonesMessageVC!.modalTransitionStyle = .crossDissolve
            
            self.present(headphonesMessageVC!, animated: true, completion: nil)
        }
    }
    
    fileprivate func hideHeadphonesMessage() {
        if let messageView = headphonesMessageVC {
            // Update user defaults
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
            defaults.synchronize()
            
            messageView.dismiss(animated: true, completion: nil)
            headphonesMessageVC = nil
        }
    }
	
	// MARK: Leave Tour Message
	
	private func showLeaveTourMessage() {
		leaveTourMessageVC = MessageViewController(message: Common.Messages.leavingTour)
		leaveTourMessageVC!.delegate = self
		
		// Modal presentation style
		leaveTourMessageVC!.definesPresentationContext = true
		leaveTourMessageVC!.providesPresentationContextTransitionStyle = true
		leaveTourMessageVC!.modalPresentationStyle = .overFullScreen
		leaveTourMessageVC!.modalTransitionStyle = .crossDissolve
		
		self.present(leaveTourMessageVC!, animated: true, completion: nil)
	}
	
	private func hideLeaveTourMessage() {
		if let messageView = leaveTourMessageVC {
			messageView.dismiss(animated: true, completion: nil)
			leaveTourMessageVC = nil
		}
	}
	
	// MARK: Requested Content
	// Functions used when user wants to open content on the Map and a Tour is open
	
	func showRequestedMapContentIfNeeded() {
		if let mapMode = self.requestedMapMode {
			switch mapMode {
			case .tour:
				if var tour = self.requestedTour {
					if let previousTour = mapVC.tourModel {
						tour.language = previousTour.language
					}
					
					audioPlayerVC.pause()
					audioPlayerVC.hide()
					
					showTourOnMap(tour: tour, language: tour.language, stopIndex: nil)
				}
				break
			case .artwork:
				if let artwork = self.requestedArtwork {
					showArtworkOnMap(artwork: artwork)
				}
				break
			case .allInformation:
				break
			case .searchedArtwork:
				if let searchedArtwork = self.requestedSearchedArtwork {
					showSearchedArtworkOnMap(searchedArtwork: searchedArtwork)
				}
				break
			case .exhibition:
				if let exhibition = self.requestedExhibition {
					showExhibitionOnMap(exhibition: exhibition)
				}
				break
			case .dining:
				showDiningOnMap()
				break
			case .memberLounge:
				showMemberLoungeOnMap()
				break
			case .giftshop:
				showGiftShopOnMap()
				break
			case .restrooms:
				showRestroomsOnMap()
				break
			}
		}
		else {
			mapVC.showAllInformation()
		}
	}
	
	func resetRequestedMapContent() {
		self.requestedMapMode = nil
		self.requestedTour = nil
		self.requestedArtwork = nil
		self.requestedSearchedArtwork = nil
		self.requestedExhibition = nil
	}
	
	// MARK: Search Button Pressed
	
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

// MARK: SectionTabBarController Delegate

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
		
		// Log analytics
		AICAnalytics.sendTourOpenedEvent(tour: tour)
	}
	
	func showExhibitionCard(exhibition: AICExhibitionModel) {
		let exhibitionTableVC = ExhibitionTableViewController(exhibition: exhibition)
		exhibitionTableVC.exhibitionTableDelegate = self
		showContentCard(ContentCardNavigationController(tableVC: exhibitionTableVC))
		
		// Log analytics
		AICAnalytics.sendExhibitionOpenedEvent(exhibition: exhibition)
	}
	
	func showEventCard(event: AICEventModel) {
		let eventTableVC = EventTableViewController(event: event)
		showContentCard(ContentCardNavigationController(tableVC: eventTableVC))
		
		// Log analytics
		AICAnalytics.sendEventOpenedEvent(event: event)
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
	
	func mapDidPresseCloseTourButton() {
		showLeaveTourMessage()
	}
}

// MARK: Message Delegate

extension SectionsViewController : MessageViewControllerDelegate {
    func messageViewActionSelected(messageVC: MessageViewController) {
		if messageVC == headphonesMessageVC {
			hideHeadphonesMessage()
		}
		else if messageVC == leaveTourMessageVC {
			hideLeaveTourMessage()
			
			// Log analytics
			if let tour = mapVC.tourModel {
				AICAnalytics.sendTourLeftEvent(tour: tour)
			}
			
			showRequestedMapContentIfNeeded()
			resetRequestedMapContent()
		}
    }
    
    func messageViewCancelSelected(messageVC: MessageViewController) {
        if messageVC == leaveTourMessageVC {
            hideLeaveTourMessage()
			
			resetRequestedMapContent()
        }
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
	
	func cardWillShowMiniplayer(cardVC: CardNavigationController) {
		if cardVC.currentState == .fullscreen {
			// Log analytics
			self.currentViewController.topViewController?.viewWillAppear(false)
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
	
	func cardWillHide(cardVC: CardNavigationController) {
		if cardVC.currentState == .fullscreen {
			// Log analytics
			self.currentViewController.topViewController?.viewWillAppear(false)
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
		showTourOnMap(tour: tour, language: language, stopIndex: stopIndex)
	}
}

// MARK: Artwork Content Card Delegate

extension SectionsViewController : ArtworkTableViewControllerDelegate {
	// Pressed "Play Audio" in content card
	func artworkContentCardDidPressPlayAudio(artwork: AICObjectModel) {
		playSearchedArtwork(artwork: artwork)
		
		// Log Analytics
		let searchTextField = searchVC.searchBar.value(forKey: "searchField") as? UITextField
		let searchText = (searchTextField!.text ?? "")
		AICAnalytics.sendSearchArtworkAndPlayedAudioEvent(artwork: artwork, searchText: searchText)
	}
	
	func artworkContentCardDidPressShowOnMap(artwork: AICSearchedArtworkModel) {
		showSearchedArtworkOnMap(searchedArtwork: artwork)
	}
}

// MARK: Exhibition Content Card Delegate

extension SectionsViewController : ExhibitionTableViewControllerDelegate {
	func exhibitionContentCardDidPressShowOnMap(exhibition: AICExhibitionModel) {
		showExhibitionOnMap(exhibition: exhibition)
	}
}

// MARK: Search Map Items Collection Delegate

extension SectionsViewController : MapItemsCollectionContainerDelegate {
	func mapItemDiningSelected() {
		showDiningOnMap()
	}
	
	func mapItemMemberLoungeSelected() {
		showMemberLoungeOnMap()
	}
	
	func mapItemGiftShopSelected() {
		showGiftShopOnMap()
	}
	
	func mapItemRestroomSelected() {
		showRestroomsOnMap()
	}
	
	func mapItemArtworkSelected(artwork: AICObjectModel) {
		showArtworkOnMap(artwork: artwork)
	}
}

// MARK: Audio Player Delegate

extension SectionsViewController : AudioPlayerNavigationControllerDelegate {
	func audioPlayerDidFinishPlaying(audio: AICAudioFileModel) {
		if mapVC.currentMode == .tour {
			mapVC.advanceToNextTourStopAfterAudioPlayback(audio: audio)
		}
	}
}

