/*
 Abstract:
 Main Section controller, contains MapView, UITabBar and Object View.
*/

import UIKit
import MapKit
import Localize_Swift

protocol SectionsViewControllerDelegate: class {
    func sectionsViewControllerDidFinishAnimatingIn()
}

class SectionsViewController: UIViewController {
    weak var delegate: SectionsViewControllerDelegate?

	// AudioPlayer Card
    let audioPlayerCardVC: AudioPlayerNavigationController = AudioPlayerNavigationController()

	// Content Card
	var contentCardVC: ContentCardNavigationController?

	// Search Card
	let searchCardVC: SearchNavigationController = SearchNavigationController()

    // TabBar
    var sectionTabBarController: UITabBarController = UITabBarController()

    // Sections
	var homeVC: HomeNavigationController = HomeNavigationController(section: Common.Sections[.home]!)
	var audioGuideVC: AudioGuideNavigationController = AudioGuideNavigationController(section: Common.Sections[.audioGuide]!)
	var mapVC: MapNavigationController = MapNavigationController(section: Common.Sections[.map]!)
	var infoVC: InfoNavigationController = InfoNavigationController(section: Common.Sections[.info]!)

    var sectionViewControllers: [SectionNavigationController] = []

    var currentViewController: SectionNavigationController
    var previousViewController: SectionNavigationController?

    // Messages
	private var headphonesMessageVC: MessageViewController?
	private var leaveTourMessageVC: MessageViewController?

	// Content on Map
    private var requestedTour: AICTourModel?
	private var requestedArtwork: AICObjectModel?
	private var requestedSearchedArtwork: AICSearchedArtworkModel?
	private var requestedExhibition: AICExhibitionModel?
	private var requestedMapMode: MapViewController.Mode?

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
		sectionTabBarController.willMove(toParent: self)
        view.addSubview(sectionTabBarController.view)
		sectionTabBarController.didMove(toParent: self)

        audioPlayerCardVC.willMove(toParent: sectionTabBarController)
        sectionTabBarController.view.insertSubview(audioPlayerCardVC.view, belowSubview: sectionTabBarController.tabBar)
        audioPlayerCardVC.didMove(toParent: sectionTabBarController)

		searchCardVC.willMove(toParent: self.sectionTabBarController)
		sectionTabBarController.view.insertSubview(searchCardVC.view, belowSubview: audioPlayerCardVC.view)
		searchCardVC.didMove(toParent: self.sectionTabBarController)

		// Set delegates
		homeVC.sectionDelegate = self
		mapVC.sectionDelegate = self
		audioGuideVC.sectionDelegate = self
        sectionTabBarController.delegate = self
		searchCardVC.cardDelegate = self
		searchCardVC.sectionsVC = self
		searchCardVC.resultsVC.sectionsVC = self
        audioPlayerCardVC.cardDelegate = self
		audioPlayerCardVC.sectionDelegate = self

		// Search Buttons
		for sectionVC in sectionViewControllers {
			sectionVC.sectionNavigationBar.searchButton.addTarget(self, action: #selector(searchButtonPressed(button:)), for: .touchUpInside)
		}

		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)

		// Accessibility
		searchCardVC.view.accessibilityElementsHidden = true
		audioPlayerCardVC.view.accessibilityElementsHidden = true
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		updateLanguage()
	}

	// MARK: Accessibility

	private func updateAccessibilityOnCardOpened(cardVC: CardNavigationController) {
		cardVC.view.accessibilityElementsHidden = false

		homeVC.view.accessibilityElementsHidden = true
		mapVC.view.accessibilityElementsHidden = true
		audioGuideVC.view.accessibilityElementsHidden = true
		infoVC.view.accessibilityElementsHidden = true
	}

	private func updateAccessibilityOnCardClosed() {
		searchCardVC.view.accessibilityElementsHidden = true

		homeVC.view.accessibilityElementsHidden = false
		mapVC.view.accessibilityElementsHidden = false
		audioGuideVC.view.accessibilityElementsHidden = false
		infoVC.view.accessibilityElementsHidden = false

		currentViewController.sectionNavigationBar.titleLabel.becomeFirstResponder()
	}

	private func updateAccessibilityOnAudioPlayerMinimized() {
		searchCardVC.view.accessibilityElementsHidden = true

		homeVC.view.accessibilityElementsHidden = false
		mapVC.view.accessibilityElementsHidden = false
		audioGuideVC.view.accessibilityElementsHidden = false
		infoVC.view.accessibilityElementsHidden = false

		currentViewController.sectionNavigationBar.titleLabel.becomeFirstResponder()
	}

	// MARK: Section Navigation

    private func setSelectedSection(sectionVC: SectionNavigationController) {
		if searchCardVC.currentState == .fullscreen {
			searchCardVC.hide()
		}

		if sectionVC == currentViewController {
			return
		}

        previousViewController = currentViewController
        currentViewController = sectionVC

		// Card operations
		if currentViewController != previousViewController {
			if searchCardVC.currentState == .fullscreen {
				searchCardVC.hide()
			}
			if let contentCardVC = self.contentCardVC {
				contentCardVC.hide()
			}

			// Update colors for this VC
			sectionTabBarController.tabBar.tintColor = sectionVC.color
			audioPlayerCardVC.setProgressBarColor(color: sectionVC.color)

			if currentViewController == homeVC && sectionTabBarController.selectedIndex != 0 {
				sectionTabBarController.selectedIndex = 0
			} else if currentViewController == audioGuideVC && sectionTabBarController.selectedIndex != 1 {
				sectionTabBarController.selectedIndex = 1
			} else if currentViewController == mapVC && sectionTabBarController.selectedIndex != 2 {
				sectionTabBarController.selectedIndex = 2
			} else if currentViewController == infoVC && sectionTabBarController.selectedIndex != 3 {
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

		UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut,
                                   animations: {
									self.view.alpha = 1.0
									self.homeVC.view.alpha = 1.0
            }, completion: { (completed) in
				if completed {
					// re-enable parallax effect
					self.homeVC.sectionNavigationBar.enableParallaxEffect()

					// show home tooltip, if needed
					self.homeVC.showHomeTooltip()

					self.delegate?.sectionsViewControllerDidFinishAnimatingIn()

					// Accessibility
					self.homeVC.sectionNavigationBar.titleLabel.becomeFirstResponder()
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
		AICAnalytics.sendTourStartedEvent(tour: tour, language: language)
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

	private func playAudioGuideArtwork(artwork: AICObjectModel, audioGuideID: Int) {
		var audio = AppDataManager.sharedInstance.getAudioFile(forObject: artwork, selectorNumber: audioGuideID)
		audio.language = Common.currentLanguage

        audioPlayerCardVC.playArtworkAudio(artwork: artwork, audio: audio, source: .AudioGuide, audioGuideNumber: audioGuideID)
        showHeadphonesMessage()
		audioPlayerCardVC.showFullscreen()
	}

	private func playAudioGuideTour(tour: AICTourModel) {
        audioPlayerCardVC.playTourOverviewAudio(tour: tour, source: .AudioGuide)
        showHeadphonesMessage()
		audioPlayerCardVC.showFullscreen()
	}

	private func playMapArtwork(artwork: AICObjectModel, isFromSearchIcon: Bool = false) {
		var audio = AppDataManager.sharedInstance.getAudioFile(forObject: artwork, selectorNumber: nil)
		audio.language = Common.currentLanguage

        let source = isFromSearchIcon ? AICAnalytics.PlaybackSource.SearchIcon : AICAnalytics.PlaybackSource.Map

        audioPlayerCardVC.playArtworkAudio(artwork: artwork, audio: audio, source: source)
        showHeadphonesMessage()
		audioPlayerCardVC.showMiniPlayer()
	}

	private func playSearchedArtwork(artwork: AICObjectModel) {
		var audio = AppDataManager.sharedInstance.getAudioFile(forObject: artwork, selectorNumber: nil)
		audio.language = Common.currentLanguage

        audioPlayerCardVC.playArtworkAudio(artwork: artwork, audio: audio, source: .Search)
        showHeadphonesMessage()
		audioPlayerCardVC.showMiniPlayer()
	}

	private func playTourStop(tourStop: AICTourStopModel, tour: AICTourModel) {
		audioPlayerCardVC.playTourStopAudio(tourStop: tourStop, tour: tour)
		audioPlayerCardVC.showMiniPlayer()
	}

	private func playTourOverview(tour: AICTourModel, language: Common.Language) {
		audioPlayerCardVC.playTourOverviewAudio(tour: tour, source: .TourStop)
		audioPlayerCardVC.showMiniPlayer()
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

					audioPlayerCardVC.pause()
					audioPlayerCardVC.hide()

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
		} else {
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
		searchCardVC.showFullscreen()
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

extension SectionsViewController: UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		if let sectionVC = viewController as? SectionNavigationController {
			setSelectedSection(sectionVC: sectionVC)
		}
	}
}

// MARK: Home Delegate

extension SectionsViewController: HomeNavigationControllerDelegate {
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

		// Log analytics
		AICAnalytics.sendExhibitionViewedEvent(exhibition: exhibition)
	}

	func showEventCard(event: AICEventModel) {
		let eventTableVC = EventTableViewController(event: event)
		showContentCard(ContentCardNavigationController(tableVC: eventTableVC))

		// Log analytics
		AICAnalytics.sendEventViewedEvent(event: event)
	}

	func showContentCard(_ contentCardVC: ContentCardNavigationController) {
		if let cardVC = self.contentCardVC {
			cardVC.view.removeFromSuperview()
		}
		self.contentCardVC = contentCardVC
		contentCardVC.cardDelegate = self

		contentCardVC.willMove(toParent: sectionTabBarController)
		sectionTabBarController.view.insertSubview(contentCardVC.view, aboveSubview: searchCardVC.view)
		contentCardVC.didMove(toParent: sectionTabBarController)

		contentCardVC.showFullscreen()
	}
}

// MARK: AudioGuide Delegate

extension SectionsViewController: AudioGuideNavigationControllerDelegate {
	func audioGuideDidSelectObjectAudio(object: AICObjectModel, audioGuideID: Int) {
		playAudioGuideArtwork(artwork: object, audioGuideID: audioGuideID)
	}

	func audioGuideDidSelectTourAudio(tour: AICTourModel, audioGuideID: Int) {
		playAudioGuideTour(tour: tour)
	}
}

// MARK: Map Delegate

extension SectionsViewController: MapNavigationControllerDelegate {
	func mapDidSelectPlayAudioForArtwork(artwork: AICObjectModel, isFromSearchIcon: Bool) {
		playMapArtwork(artwork: artwork, isFromSearchIcon: isFromSearchIcon)
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

extension SectionsViewController: MessageViewControllerDelegate {
    func messageViewActionSelected(messageVC: MessageViewController) {
		if messageVC == headphonesMessageVC {
			hideHeadphonesMessage()
		} else if messageVC == leaveTourMessageVC {
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

extension SectionsViewController: CardNavigationControllerDelegate {
    // When the Audio Player goes fullscreen hide the TabBar
    func cardDidUpdatePosition(cardVC: CardNavigationController, position: CGPoint) {
        if cardVC == audioPlayerCardVC {
            let screenHeight = UIScreen.main.bounds.height

            var percentageY: CGFloat = position.y / (screenHeight - self.sectionTabBarController.tabBar.frame.height - Common.Layout.miniAudioPlayerHeight)
            percentageY = clamp(val: percentageY, minVal: 0.0, maxVal: 1.0)

            // Set the sectionVC tab bar to hide as we show audioPlayerVC
            self.sectionTabBarController.tabBar.frame.origin.y = screenHeight - (sectionTabBarController.tabBar.bounds.height * percentageY)
        }
    }

	func cardWillShowFullscreen(cardVC: CardNavigationController) {
		setSearchButtonEnabled(false)

		// Accessibility
		updateAccessibilityOnCardOpened(cardVC: cardVC)

		// close content card or search card, if open
		if cardVC == audioPlayerCardVC {
			if let contentCard = contentCardVC {
				if contentCard.currentState == .fullscreen {
					contentCard.hide()
				}
			}
			if searchCardVC.currentState == .fullscreen {
				searchCardVC.hide()
			}
		}
	}

	func cardWillShowMiniplayer(cardVC: CardNavigationController) {
		if cardVC.currentState == .fullscreen {
			// Log analytics
			self.currentViewController.topViewController?.viewWillAppear(false)

			// Accessibility
			updateAccessibilityOnAudioPlayerMinimized()
		}
	}

	func cardDidShowMiniplayer(cardVC: CardNavigationController) {
		if cardVC == audioPlayerCardVC {
			// when you play artwork for an artwork you found on the search
			// make sure search is not fullscreen before you re-enable the search button
			if searchCardVC.currentState != .fullscreen {
				setSearchButtonEnabled(true)

				// Accessibility
				updateAccessibilityOnCardClosed()
			}
		}
	}

	func cardWillHide(cardVC: CardNavigationController) {
		if cardVC.currentState == .fullscreen {
			// Log analytics
			self.currentViewController.topViewController?.viewWillAppear(false)

			// Accessibility
			updateAccessibilityOnCardClosed()
		}
	}

	func cardDidHide(cardVC: CardNavigationController) {
		// make sure there's no other card fullscreen, befiore you re-enable the search button
		if audioPlayerCardVC.currentState != .fullscreen {
			setSearchButtonEnabled(true)

			// Accessibility
			updateAccessibilityOnCardClosed()
		}
		if cardVC.isKind(of: ContentCardNavigationController.self) {
			cardVC.view.removeFromSuperview()
		}
	}
}

// MARK: Tour Content Card Delegate

extension SectionsViewController: TourTableViewControllerDelegate {
	// Pressed "Start Tour" or tour stop in content card
	func tourContentCardDidPressStartTour(tour: AICTourModel, language: Common.Language, stopIndex: Int?) {
		showTourOnMap(tour: tour, language: language, stopIndex: stopIndex)
	}
}

// MARK: Artwork Content Card Delegate

extension SectionsViewController: ArtworkTableViewControllerDelegate {
	// Pressed "Play Audio" in content card
	func artworkContentCardDidPressPlayAudio(artwork: AICObjectModel) {
		playSearchedArtwork(artwork: artwork)
	}

	func artworkContentCardDidPressShowOnMap(artwork: AICSearchedArtworkModel) {
		showSearchedArtworkOnMap(searchedArtwork: artwork)
	}
}

// MARK: Exhibition Content Card Delegate

extension SectionsViewController: ExhibitionTableViewControllerDelegate {
	func exhibitionContentCardDidPressShowOnMap(exhibition: AICExhibitionModel) {
		showExhibitionOnMap(exhibition: exhibition)
	}
}

// MARK: Search Map Items Collection Delegate

extension SectionsViewController: MapItemsCollectionContainerDelegate {
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

extension SectionsViewController: AudioPlayerNavigationControllerDelegate {
	func audioPlayerDidFinishPlaying(audio: AICAudioFileModel) {
		if mapVC.currentMode == .tour {
			mapVC.advanceToNextTourStopAfterAudioPlayback(audio: audio)
		}
	}
}
