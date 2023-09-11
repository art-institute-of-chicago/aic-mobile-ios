//
//  MapNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/25/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import CoreLocation
import Localize_Swift

protocol MapNavigationControllerDelegate: AnyObject {
	func mapDidSelectPlayAudioForArtwork(artwork: AICObjectModel, isFromSearchIcon: Bool)
	func mapDidSelectPlayAudioForTour(tour: AICTourModel, language: Common.Language)
	func mapDidSelectPlayAudioForTourStop(tourStop: AICTourStopModel, tour: AICTourModel, language: Common.Language)
	func mapDidPresseCloseTourButton()
}

class MapNavigationController: SectionNavigationController {
  var shouldShowLeaveTourMessage = false
	var currentMode = MapPointOfInterestType.allInformation
  var tourModel: AICTourModel?
  weak var sectionDelegate: MapNavigationControllerDelegate?

  private let defaults = UserDefaults.standard
  private var tourStopIndex: Int?
  private var nextTourModel: AICTourModel?
  private var nextTourStopIndex: Int?
  private var artworkModel: AICObjectModel?
  private var searchedArtworkModel: AICSearchedArtworkModel?
  private var exhibitionModel: AICExhibitionModel?

  private lazy var mapViewController: MapViewController = {
    let viewController = MapViewController()
    viewController.delegate = self

    let viewableArea = CGRect(x: 0,
                              y: 0,
                              width: UIScreen.main.bounds.width,
                              height: UIScreen.main.bounds.height - Common.Layout.tabBarHeight)
    viewController.setViewableArea(frame: viewableArea)
    viewController.view.accessibilityElementsHidden = true
    return viewController
  }()

  private var mapContentCardNavigationController: MapContentCardNavigationController?
  private var tourStopPageViewController: TourStopPageViewController?
  private var restaurantPageViewController: RestaurantPageViewController?

	private var enableLocationMessageViewController: MessageViewController?
	private var mapTooltipViewController: TooltipViewController?

	override init(section: AICSectionModel) {
		super.init(section: section)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
        setup()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Location
		Common.Map.locationManager.delegate = mapViewController
		startLocationManager()

		// Tooltips
		if enableLocationMessageViewController == nil {
			showMapTooltips()
		}

		// Adjust viewable area to position floor menu, if needed
		if let contentCard = mapContentCardNavigationController {
			mapViewController.setViewableArea(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: contentCard.view.frame.origin.y))
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Accessibility
		tabBarController?.tabBar.isAccessibilityElement = true
		sectionNavigationBar.titleLabel.becomeFirstResponder()
		self.perform(#selector(accessibilityReEnableTabBar), with: nil, afterDelay: 2.0)
	}

	@objc private func accessibilityReEnableTabBar() {
		tabBarController?.tabBar.isAccessibilityElement = false
	}

	// MARK: Language

	@objc override func updateLanguage() {
		super.updateLanguage()

		if let contentCard = mapContentCardNavigationController {
			switch currentMode {
			case .allInformation, .dining, .tour:
				break

			case .artwork, .searchedArtwork:
				contentCard.setTitleText(text: "map_card_artwork_title".localized(using: "Search"))

			case .exhibition:
				contentCard.setTitleText(text: "map_card_exhibition_title".localized(using: "Search"))

			case .memberLounge:
				contentCard.setTitleText(text: AppDataManager.sharedInstance.app.generalInfo.membersLoungeTitle)
				if let textContentView = contentCard.contentVC.view as? MapTextContentView {
					textContentView.setText(text: AppDataManager.sharedInstance.app.generalInfo.membersLoungeText)
				}

			case .giftshop:
				contentCard.setTitleText(text: AppDataManager.sharedInstance.app.generalInfo.giftShopsTitle)
				if let textContentView = contentCard.contentVC.view as? MapTextContentView {
					textContentView.setText(text: AppDataManager.sharedInstance.app.generalInfo.giftShopsText)
				}

			case .restrooms:
				contentCard.setTitleText(text: AppDataManager.sharedInstance.app.generalInfo.restroomsTitle)
				if let textContentView = contentCard.contentVC.view as? MapTextContentView {
					textContentView.setText(text: AppDataManager.sharedInstance.app.generalInfo.restroomsText)
				}
			}
		}
	}

	// MARK: Show Content

	private func showContentIfNeeded() {
		switch currentMode {
		case .allInformation:
			break

		case .artwork:
			showArtwork(artwork: artworkModel!)

		case .searchedArtwork:
			showSearchedArtwork(searchedArtwork: searchedArtworkModel!)

		case .exhibition:
			showExhibition(exhibition: exhibitionModel!)

		case .dining:
			showDining()

		case .memberLounge:
			showMemberLounge()

		case .giftshop:
			showGiftShop()

		case .restrooms:
			showRestrooms()

		case .tour:
			showTour(tour: tourModel!, language: tourModel!.language, stopIndex: tourStopIndex)
		}
	}

	// MARK: Advance to next Tour Stop after Audio playback

	func advanceToNextTourStopAfterAudioPlayback(audio: AICAudioFileModel) {
		if let tour = tourModel {
			if let tourStopsVC = self.tourStopPageViewController {
				// page for audio track
				var previousStopPage = -1
				var nextTourStopIndex = -1
				if audio.nid == tour.audioCommentary.audioFile.nid {
					nextTourStopIndex = 0
					previousStopPage = 0
				} else if let audioIndex = tour.getIndex(forStopAudio: audio) {
					nextTourStopIndex = audioIndex + 1
					previousStopPage = audioIndex + 1 // pages include overview
				}

				// if the tour card is still on the stop of the audio that just played
				// move to the next stop
				if tourStopsVC.getCurrentPage() == previousStopPage {
					tourStopsVC.setCurrentPage(pageIndex: previousStopPage + 1)

					if nextTourStopIndex < tour.stops.count {
						mapViewController.highlightTourStop(identifier: tour.stops[nextTourStopIndex].object.nid, location: tour.stops[nextTourStopIndex].object.location)
					}
				}
			}
		}
	}

	// MARK: Notify Tour Stops VC of audio playback status

	func audioPlaybackDidStart(audio: AICAudioFileModel) {
		guard let tour = tourModel,
			let tourStopsVC = tourStopPageViewController
			else { return }

		if audio.nid == tour.audioCommentary.audioFile.nid {
			tourStopsVC.currentlyPlayingAudioTourIndex = 0
		} else if let audioIndex = tour.getIndex(forStopAudio: audio) {
			tourStopsVC.currentlyPlayingAudioTourIndex = audioIndex + 1
		}
	}

	func audioPlaybackDidPause(audio: AICAudioFileModel) {
		guard let tourStopsVC = tourStopPageViewController else { return }

		tourStopsVC.currentlyPlayingAudioTourIndex = -1
	}

	func audioPlaybackDidFinish(audio: AICAudioFileModel) {
		guard let tourStopsVC = tourStopPageViewController else { return }

		tourStopsVC.currentlyPlayingAudioTourIndex = -1
	}

	// MARK: Location Manager

	fileprivate func startLocationManager() {
		//See if we need to prompt first
		let showEnableLocationMessageValue = defaults.bool(forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)

		// If we do show it
		if showEnableLocationMessageValue {
			showEnableLocationMessage()
		} else {  // Otherwise try to start the location manager
			// Init location manager
			Common.Map.locationManager.requestWhenInUseAuthorization()
			Common.Map.locationManager.startUpdatingLocation()
			Common.Map.locationManager.startUpdatingHeading()
		}
	}

	fileprivate func showEnableLocationMessage() {
		enableLocationMessageViewController = MessageViewController(message: Common.Messages.enableLocation)
		enableLocationMessageViewController!.delegate = self

		// Modal presentation style
		enableLocationMessageViewController!.definesPresentationContext = true
		enableLocationMessageViewController!.providesPresentationContextTransitionStyle = true
		enableLocationMessageViewController!.modalPresentationStyle = .overFullScreen
		enableLocationMessageViewController!.modalTransitionStyle = .crossDissolve

		self.present(enableLocationMessageViewController!, animated: true, completion: nil)
	}

	fileprivate func hideEnableLocationMessage() {
		if let messageView = enableLocationMessageViewController {
			// Update user defaults
			defaults.set(false, forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
			defaults.synchronize()

			messageView.dismiss(animated: true, completion: nil)
			enableLocationMessageViewController = nil
		}

		showMapTooltips()
	}

	// MARK: Map Tooltips

	private func showMapTooltips() {
		//See if we need to prompt first
		let showMapTooltipsMessageValue = defaults.bool(forKey: Common.UserDefaults.showTooltipsDefaultsKey)

		if showMapTooltipsMessageValue {
			// Page Tooltips
			mapTooltipViewController = TooltipViewController()
			mapTooltipViewController!.showPageTooltips(tooltips: [Common.Tooltips.mapPinchTooltip, Common.Tooltips.mapArtworkTooltip], tooltipIndex: 0)
			mapTooltipViewController!.delegate = self

			mapTooltipViewController!.definesPresentationContext = true
			mapTooltipViewController!.providesPresentationContextTransitionStyle = true
			mapTooltipViewController!.modalPresentationStyle = .overFullScreen
			mapTooltipViewController!.modalTransitionStyle = .crossDissolve

			self.present(mapTooltipViewController!, animated: true, completion: nil)
		}
	}

	private func hideMapTooltips() {
		if let tooltipVC = mapTooltipViewController {
			defaults.set(false, forKey: Common.UserDefaults.showTooltipsDefaultsKey)
			defaults.synchronize()

			tooltipVC.dismiss(animated: true, completion: nil)
			mapTooltipViewController = nil
		}

		showContentIfNeeded()
	}

	// MARK: Show

	func showAllInformation() {
		currentMode = .allInformation
		mapViewController.showAllInformation()
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.hide()
		}
		mapContentCardNavigationController = nil
		tourModel = nil
		tourStopPageViewController = nil
		artworkModel = nil
		searchedArtworkModel = nil
		exhibitionModel = nil
	}

	func showTour(tour: AICTourModel, language: Common.Language, stopIndex: Int?) {
		currentMode = .tour
		tourModel = tour
		if tourModel!.availableLanguages.contains(language) {
			tourModel!.language = language
		}
		tourStopIndex = stopIndex

		if sectionNavigationBar.currentState != .hidden {
			sectionNavigationBar.hide()
		}

		// Creeate Tour Stops card
		tourStopPageViewController = TourStopPageViewController(tour: tourModel!)

		// Crate Content Card
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.view.removeFromSuperview()
		}
		mapContentCardNavigationController = MapContentCardNavigationController(contentVC: tourStopPageViewController!)
		mapContentCardNavigationController!.setTitleText(text: tourModel!.title)
		mapContentCardNavigationController!.cardDelegate = self
		tourStopPageViewController!.tourStopPageDelegate = self

		// Add card to view
		mapContentCardNavigationController!.willMove(toParent: self)
		self.view.addSubview(mapContentCardNavigationController!.view)
		mapContentCardNavigationController!.didMove(toParent: self)

		// Set TourStopPageVC to the right stop
		if let index = tourStopIndex {
			tourStopPageViewController!.setCurrentPage(pageIndex: index + 1) // add +1 for tour overview
		} else {
			tourStopPageViewController!.setCurrentPage(pageIndex: 0)
		}

		// in case the tour card is open, to tell the map to animate the floor selector
		self.mapViewController.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))

		// Set map state
		mapViewController.showTour(forTour: tourModel!)

		showMapContentCard()

		self.perform(#selector(highlightTourStop), with: nil, afterDelay: 1.0)
	}

	@objc private func highlightTourStop() {
		var tourStopId = tourModel!.nid
		if let index = tourStopIndex {
			tourStopId = tourModel!.stops[index].object.nid
		}

		mapViewController.highlightTourStop(identifier: tourStopId, location: tourModel!.location)
	}

	func showArtwork(artwork: AICObjectModel) {
		currentMode = .artwork
		artworkModel = artwork

		if sectionNavigationBar.currentState != .hidden {
			sectionNavigationBar.hide()
		}

		// Crate Content Card
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.view.removeFromSuperview()
		}
		let artworkVC = UIViewController()
		let artworkContentView = MapArtworkContentView(artwork: artwork)
		artworkContentView.audioButton.addTarget(self, action: #selector(mapArtworkAudioButtonPressed(button:)), for: .touchUpInside)
		artworkContentView.imageButton.addTarget(self, action: #selector(mapArtworkImageButtonPressed(button:)), for: .touchUpInside)
		artworkVC.view.addSubview(artworkContentView)
		mapContentCardNavigationController = MapContentCardNavigationController(contentVC: artworkVC)
		mapContentCardNavigationController!.setTitleText(text: "map_card_artwork_title".localized(using: "Search"))
		mapContentCardNavigationController!.cardDelegate = self

		// Add card to view
		mapContentCardNavigationController!.willMove(toParent: self)
		self.view.addSubview(mapContentCardNavigationController!.view)
		mapContentCardNavigationController!.didMove(toParent: self)

		// in case the tour card is open, to tell the map to animate the floor selector
		self.mapViewController.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))

		// Set map state
		mapViewController.showArtwork(artwork: artwork)

		showMapContentCard()

		// Log analytics
		AICAnalytics.sendSearchIconMapEvent(artwork: artwork)
	}

	func showSearchedArtwork(searchedArtwork: AICSearchedArtworkModel) {
		currentMode = .searchedArtwork
		searchedArtworkModel = searchedArtwork

		if sectionNavigationBar.currentState != .hidden {
			sectionNavigationBar.hide()
		}

		// Crate Content Card
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.view.removeFromSuperview()
		}
		let artworkVC = UIViewController()
		let artworkContentView = MapArtworkContentView(searchedArtwork: searchedArtwork)
		artworkContentView.audioButton.addTarget(self, action: #selector(mapArtworkAudioButtonPressed(button:)), for: .touchUpInside)
		artworkContentView.imageButton.addTarget(self, action: #selector(mapArtworkImageButtonPressed(button:)), for: .touchUpInside)
		artworkVC.view.addSubview(artworkContentView)
		mapContentCardNavigationController = MapContentCardNavigationController(contentVC: artworkVC)
		mapContentCardNavigationController!.setTitleText(text: "map_card_artwork_title".localized(using: "Search"))
		mapContentCardNavigationController!.cardDelegate = self

		// Add card to view
		mapContentCardNavigationController!.willMove(toParent: self)
		self.view.addSubview(mapContentCardNavigationController!.view)
		mapContentCardNavigationController!.didMove(toParent: self)

		// in case the tour card is open, to tell the map to animate the floor selector
		self.mapViewController.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))

		// Set map state
		mapViewController.showSearchedArtwork(searchedArtwork: searchedArtwork)

		showMapContentCard()

		// Log analytics
		AICAnalytics.sendSearchArtworkMapEvent(searchedArtwork: searchedArtwork)
	}

	func showExhibition(exhibition: AICExhibitionModel) {
		currentMode = .exhibition
		exhibitionModel = exhibition

		if sectionNavigationBar.currentState != .hidden {
			sectionNavigationBar.hide()
		}

		// Crate Content Card
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.view.removeFromSuperview()
		}
		let exhibitionView = MapArtworkContentView(exhibition: exhibitionModel!)
		mapContentCardNavigationController = MapContentCardNavigationController(contentView: exhibitionView)
		mapContentCardNavigationController!.setTitleText(text: "map_card_exhibition_title".localized(using: "Search"))
		mapContentCardNavigationController!.cardDelegate = self

		// Add card to view
		mapContentCardNavigationController!.willMove(toParent: self)
		self.view.addSubview(mapContentCardNavigationController!.view)
		mapContentCardNavigationController!.didMove(toParent: self)

		// in case the tour card is open, to tell the map to animate the floor selector
		self.mapViewController.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))

		// Set map state
		mapViewController.showExhibition(exhibition: exhibition)

		showMapContentCard()

		// Log analytics
		AICAnalytics.sendExhibitionMapEvent(exhibition: exhibition)
	}

	func showDining() {
		currentMode = .dining

		if sectionNavigationBar.currentState != .hidden {
			sectionNavigationBar.hide()
		}

		// Create Restaurants card
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.view.removeFromSuperview()
		}
		restaurantPageViewController = RestaurantPageViewController(restaurants: AppDataManager.sharedInstance.app.restaurants)
		mapContentCardNavigationController = MapContentCardNavigationController(contentVC: restaurantPageViewController!)
		mapContentCardNavigationController!.cardDelegate = self
		restaurantPageViewController!.restaurantPageDelegate = self

		// Add card to view
		mapContentCardNavigationController!.willMove(toParent: self)
		self.view.addSubview(mapContentCardNavigationController!.view)
		mapContentCardNavigationController!.didMove(toParent: self)

		// in case the tour card is open, to tell the map to animate the floor selector
		self.mapViewController.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))

		// Set first restaurant
		restaurantPageViewController!.setCurrentPage(pageIndex: 0)

		// Set map state
		mapViewController.showDining()

		showMapContentCard()

		// Log analytics
		AICAnalytics.sendSearchFacilitiesEvent(facility: AICAnalytics.Facility.Dining)
	}

	func showMemberLounge() {
		currentMode = .memberLounge

		if sectionNavigationBar.currentState != .hidden {
			sectionNavigationBar.hide()
		}

		// Crate Content Card
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.view.removeFromSuperview()
		}
		let memberLoungeContentView = MapTextContentView(text: AppDataManager.sharedInstance.app.generalInfo.membersLoungeText)
		mapContentCardNavigationController = MapContentCardNavigationController(contentView: memberLoungeContentView)
		mapContentCardNavigationController!.setTitleText(text: AppDataManager.sharedInstance.app.generalInfo.membersLoungeTitle)
		mapContentCardNavigationController!.cardDelegate = self

		// Add card to view
		mapContentCardNavigationController!.willMove(toParent: self)
		self.view.addSubview(mapContentCardNavigationController!.view)
		mapContentCardNavigationController!.didMove(toParent: self)

		// in case the tour card is open, to tell the map to animate the floor selector
		self.mapViewController.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))

		// Set map state
		mapViewController.showMemberLounge()

		showMapContentCard()

		// Log analytics
		AICAnalytics.sendSearchFacilitiesEvent(facility: AICAnalytics.Facility.MemberLounge)
	}

	func showGiftShop() {
		currentMode = .giftshop

		if sectionNavigationBar.currentState != .hidden {
			sectionNavigationBar.hide()
		}

		// Crate Content Card
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.view.removeFromSuperview()
		}
		let giftshopContentView = MapTextContentView(text: AppDataManager.sharedInstance.app.generalInfo.giftShopsText)
		mapContentCardNavigationController = MapContentCardNavigationController(contentView: giftshopContentView)
		mapContentCardNavigationController!.setTitleText(text: AppDataManager.sharedInstance.app.generalInfo.giftShopsTitle)
		mapContentCardNavigationController!.cardDelegate = self

		// Add card to view
		mapContentCardNavigationController!.willMove(toParent: self)
		self.view.addSubview(mapContentCardNavigationController!.view)
		mapContentCardNavigationController!.didMove(toParent: self)

		// in case the tour card is open, to tell the map to animate the floor selector
		self.mapViewController.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))

		// Set map state
		mapViewController.showGiftShop()

		showMapContentCard()

		// Log analytics
		AICAnalytics.sendSearchFacilitiesEvent(facility: AICAnalytics.Facility.GiftShop)
	}

	func showRestrooms() {
		currentMode = .restrooms

		if sectionNavigationBar.currentState != .hidden {
			sectionNavigationBar.hide()
		}

		// Crate Content Card
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.view.removeFromSuperview()
		}

		let restroomsContentView = MapTextContentView(text: AppDataManager.sharedInstance.app.generalInfo.restroomsText)
		mapContentCardNavigationController = MapContentCardNavigationController(contentView: restroomsContentView)
		mapContentCardNavigationController!.setTitleText(text: AppDataManager.sharedInstance.app.generalInfo.restroomsTitle)
		mapContentCardNavigationController!.cardDelegate = self

		// Add card to view
		mapContentCardNavigationController!.willMove(toParent: self)
		self.view.addSubview(mapContentCardNavigationController!.view)
		mapContentCardNavigationController!.didMove(toParent: self)

		// in case the tour card is open, to tell the map to animate the floor selector
		self.mapViewController.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))

		// Set map state
		mapViewController.showRestrooms()

		showMapContentCard()

		// Log analytics
		AICAnalytics.sendSearchFacilitiesEvent(facility: AICAnalytics.Facility.Restroom)
	}

	private func showMapContentCard() {
		if mapContentCardNavigationController!.currentState == .hidden {
			mapContentCardNavigationController!.showMinimized()
		}

		// Accessibility
		self.accessibilityElements = [sectionNavigationBar,
                                  mapContentCardNavigationController?.view,
                                  tabBarController?.tabBar].compactMap { $0 }
		if currentMode == .tour {
			mapContentCardNavigationController!.closeButton.accessibilityLabel = "Leave Tour"
		} else {
			mapContentCardNavigationController!.closeButton.accessibilityLabel = "Close"
		}
	}

	// MARK: Audio Button

	@objc private func mapArtworkAudioButtonPressed(button: UIButton) {
		if let searchedArtwork = searchedArtworkModel {
			if let object = searchedArtwork.audioObject {
				self.sectionDelegate?.mapDidSelectPlayAudioForArtwork(artwork: object, isFromSearchIcon: false)
			}
		} else if let artwork = artworkModel {
			self.sectionDelegate?.mapDidSelectPlayAudioForArtwork(artwork: artwork, isFromSearchIcon: true)
		}
	}

	@objc func mapArtworkImageButtonPressed(button: UIButton) {
		if let searchedArtwork = searchedArtworkModel {
			mapViewController.highlightArtwork(identifier: searchedArtwork.artworkId, location: searchedArtwork.location)
		} else if let artwork = artworkModel {
			mapViewController.highlightArtwork(identifier: artwork.nid, location: artwork.location)
		}
	}
}

// MARK: - MessageViewControllerDelegate
extension MapNavigationController: MessageViewControllerDelegate {

	func messageViewActionSelected(messageVC: MessageViewController) {
		if messageVC == enableLocationMessageViewController {
			hideEnableLocationMessage()
			startLocationManager()
		}
	}

	func messageViewCancelSelected(messageVC: MessageViewController) {
		if messageVC == enableLocationMessageViewController {
			hideEnableLocationMessage()

			// Log analytics
			AICAnalytics.sendLocationDetectedEvent(location: AICAnalytics.LocationState.NotNow)
		}
	}
}

// MARK: - MapViewControllerDelegate
extension MapNavigationController: MapViewControllerDelegate {

	func mapWasPressed() {
		sectionNavigationBar.hide()
	}

	func mapDidPressArtworkPlayButton(artwork: AICObjectModel) {
		if mapViewController.displayPointOfInterest == .tour {
			if let tour = tourModel {
				if let stopIndex = tour.getIndex(forStopObject: artwork) {
					let tourStop = tour.stops[stopIndex]
					self.sectionDelegate?.mapDidSelectPlayAudioForTourStop(tourStop: tourStop, tour: tourModel!, language: tour.language)
				}
			}
		} else {
			self.sectionDelegate?.mapDidSelectPlayAudioForArtwork(artwork: artwork, isFromSearchIcon: currentMode == .artwork)
		}
	}

	func mapDidSelectTourStop(stopId: Int) {
		if let tour = tourModel {
			if tour.nid == stopId {
				tourStopPageViewController!.setCurrentPage(pageIndex: 0)
			} else if let artwork = AppDataManager.sharedInstance.getObject(forID: stopId) {
				let pageIndex = tour.getIndex(forStopObject: artwork)! + 1 // add 1 for the overview
				tourStopPageViewController!.setCurrentPage(pageIndex: pageIndex)
			}
		}
	}

	func mapDidSelectRestaurant(restaurant: AICRestaurantModel) {
		for index in 0...AppDataManager.sharedInstance.app.restaurants.count-1 {
			let restaurantModel = AppDataManager.sharedInstance.app.restaurants[index]
			if restaurantModel.nid == restaurant.nid {
				restaurantPageViewController?.setCurrentPage(pageIndex: index)
			}
		}
	}

}

// MARK: - CardNavigationControllerDelegate
extension MapNavigationController: CardNavigationControllerDelegate {
	// update the view area of the map as the card slides
	func cardDidUpdatePosition(cardVC: CardNavigationController, position: CGPoint) {
		self.mapViewController.setViewableArea(frame: CGRect(origin: CGPoint.zero,
                                                         size: CGSize(width: UIScreen.main.bounds.width, height: position.y)))
	}

	func cardShouldHide(cardVC: CardNavigationController) -> Bool {
		if currentMode == .tour {
			self.sectionDelegate?.mapDidPresseCloseTourButton()
			return false
		}
		return true
	}

	func cardDidHide(cardVC: CardNavigationController) {
		if mapContentCardNavigationController != nil {
			mapContentCardNavigationController!.view.removeFromSuperview()
			mapContentCardNavigationController = nil
		}
		showAllInformation()

		// Accessibility
		self.accessibilityElements = [sectionNavigationBar, tabBarController!.tabBar]
		UIAccessibility.post(notification: .screenChanged, argument: sectionNavigationBar.titleLabel)
	}

}

// MARK: - TourStopPageViewControllerDelegate
extension MapNavigationController: TourStopPageViewControllerDelegate {

	func tourStopPageDidChangeTo(tour: AICTourModel) {
		mapViewController.highlightTourStop(identifier: tour.nid, location: tour.location)
	}

	func tourStopPageDidChangeTo(tourStop: AICTourStopModel) {
		mapViewController.highlightTourStop(identifier: tourStop.object.nid, location: tourStop.object.location)
	}

	func tourStopPageDidPressPlayAudio(tour: AICTourModel, language: Common.Language) {
		self.sectionDelegate?.mapDidSelectPlayAudioForTour(tour: tour, language: language)
	}

	func tourStopPageDidPressPlayAudio(tourStop: AICTourStopModel, language: Common.Language) {
		self.sectionDelegate?.mapDidSelectPlayAudioForTourStop(tourStop: tourStop, tour: tourModel!, language: language)
	}

}

// MARK: RestaurantPageViewControllerDelegate
extension MapNavigationController: RestaurantPageViewControllerDelegate {

	func restaurantPageDidChangeTo(restaurant: AICRestaurantModel) {
		mapViewController.highlightRestaurant(identifier: restaurant.nid, location: restaurant.location)
	}

}

// MARK: TooltipViewControllerDelegate
extension MapNavigationController: TooltipViewControllerDelegate {

	func tooltipsDismissedTooltip(index: Int) {
		if index == 0 {
			// Orientation Tooltip
			Common.Tooltips.mapOrientationTooltip.arrowPosition = mapViewController.floorSelectorOrientationButtonPosition()
			Common.Tooltips.mapOrientationTooltip.text = "map_tutorial_orient_map".localized(using: "Map")

			// Floor Tooltip
			var floorNumber = mapViewController.currentFloor
			if let userFloor = mapViewController.currentUserFloor {
				floorNumber = userFloor
			}
      Common.Tooltips.mapFloorTooltip.arrowPosition = mapViewController.floorSelectorFloorButtonPosition(at: floorNumber)
			Common.Tooltips.mapFloorTooltip.text = "map_tutorial_floor_picker_prompt"
				.localizedFormat(arguments: Common.Map.stringForFloorNumber[floorNumber] ?? "", using: "Map")

			mapViewController.setCurrentFloor(forFloorNum: floorNumber)

			mapTooltipViewController!.showArrowTooltips(tooltips: [Common.Tooltips.mapOrientationTooltip, Common.Tooltips.mapFloorTooltip], tooltipIndex: 1)
		} else {
			hideMapTooltips()
		}
	}

}

// MARK: - Private - SetUps
private extension MapNavigationController {

  func setup() {
    setupMapView()

    view.setNeedsLayout()
    view.layoutIfNeeded()
    view.layoutSubviews()
  }

  func setupMapView() {
    self.setViewControllers([mapViewController], animated: false)
    mapViewController.showAllInformation()
  }

  func setupAccessibility() {
    guard let tabBar = tabBarController?.tabBar else { return }
    accessibilityElements = [sectionNavigationBar, tabBar]
  }

}
