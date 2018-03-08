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

protocol MapNavigationControllerDelegate : class {
	func mapDidSelectPlayAudioForArtwork(artwork: AICObjectModel)
	func mapDidSelectPlayAudioForTour(tour: AICTourModel, language: Common.Language)
	func mapDidSelectPlayAudioForTourStop(tourStop: AICTourStopModel, tour: AICTourModel, language: Common.Language)
}

class MapNavigationController : SectionNavigationController {
	var currentMode: MapViewController.Mode = .allInformation
	
	// Models for content modes
	var tourModel: AICTourModel? = nil
	var tourStopIndex: Int? = nil
	var artworkModel: AICObjectModel? = nil
	var searchedArtworkModel: AICSearchedArtworkModel? = nil
	var exhibitionModel: AICExhibitionModel? = nil
	
	let mapVC: MapViewController = MapViewController()
	var mapContentCardVC: MapContentCardNavigationController? = nil
	var tourStopPageVC: TourStopPageViewController? = nil
	var restaurantPageVC: RestaurantPageViewController? = nil
	
	private var enableLocationMessageView: MessageViewController? = nil
	private var leaveTourMessageView: MessageViewController? = nil
	
	private var mapTooltipVC: TooltipViewController? = nil
	
	weak var sectionDelegate: MapNavigationControllerDelegate? = nil
	
	var isMapTabOpen: Bool = false
	
	override init(section: AICSectionModel) {
		super.init(section: section)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup delegates
		mapVC.delegate = self
		Common.Map.locationManager.delegate = self.mapVC
		
		// Add root viewcontroller
		self.pushViewController(mapVC, animated: false)
		
		// Initial map state
		self.mapVC.setViewableArea(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeight))
		self.mapVC.showAllInformation()
		
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		self.view.layoutSubviews()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		isMapTabOpen = true
		
		mapVC.setViewableArea(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeight))
		
		// Location
		startLocationManager()
		
		// Tooltips
		if enableLocationMessageView == nil {
			showMapTooltips()
		}
		
		if mapTooltipVC == nil {
			showContentIfNeeded()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		isMapTabOpen = false
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
			break
		case .exhibition:
			showExhibition(exhibition: exhibitionModel!)
			break
		case .dining:
			showDining()
			break
		case .giftshop:
			showGiftShop()
			break
		case .restrooms:
			showRestrooms()
			break
		case .tour:
			showTour(tour: tourModel!, language: tourModel!.language, stopIndex: tourStopIndex)
			break
		}
		if let contentCard = mapContentCardVC {
			mapVC.setViewableArea(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: contentCard.view.frame.origin.y))
		}
	}
	
	// MARK: Location Manager
	
	fileprivate func startLocationManager() {
		//See if we need to prompt first
		let defaults = UserDefaults.standard
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
        enableLocationMessageView = MessageViewController(message: Common.Messages.enableLocation)
		enableLocationMessageView!.delegate = self
        
        // Modal presentation style
        enableLocationMessageView!.definesPresentationContext = true
        enableLocationMessageView!.providesPresentationContextTransitionStyle = true
        enableLocationMessageView!.modalPresentationStyle = .overFullScreen
        enableLocationMessageView!.modalTransitionStyle = .crossDissolve
        
		self.present(enableLocationMessageView!, animated: true, completion: nil)
	}
	
	fileprivate func hideEnableLocationMessage() {
		if let messageView = enableLocationMessageView {
			// Update user defaults
			let defaults = UserDefaults.standard
			defaults.set(false, forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
			defaults.synchronize()
			
			messageView.dismiss(animated: true, completion: nil)
			enableLocationMessageView = nil
		}
		
		showMapTooltips()
	}
	
	// MARK: Map Tooltips
	
	private func showMapTooltips() {
		//See if we need to prompt first
		let defaults = UserDefaults.standard
		let showMapTooltipsMessageValue = defaults.bool(forKey: Common.UserDefaults.showMapTooltipsDefaultsKey)
		
		if showMapTooltipsMessageValue {
			var tooltips = [AICTooltipModel]()
			tooltips.append(Common.Tooltips.mapPopupTooltip)
			
			Common.Tooltips.mapFloorTooltip.arrowPosition = mapVC.floorSelectorVC.getCurrentFloorPosition()
			var floorText = "Map Tooltip Floor".localized(using: "Tooltips")
			floorText += Common.Map.stringForFloorNumber[mapVC.floorSelectorVC.getCurrentFloorNumber()]!
			Common.Tooltips.mapFloorTooltip.text = floorText
			tooltips.append(Common.Tooltips.mapFloorTooltip)
			
			Common.Tooltips.mapOrienationTooltip.arrowPosition = mapVC.floorSelectorVC.getOrientationButtonPosition()
			Common.Tooltips.mapOrienationTooltip.text = "Map Tooltip Orientation".localized(using: "Tooltips")
			tooltips.append(Common.Tooltips.mapOrienationTooltip)
			
			mapTooltipVC = TooltipViewController(tooltips: tooltips)
			mapTooltipVC!.delegate = self
			
			mapTooltipVC!.definesPresentationContext = true
			mapTooltipVC!.providesPresentationContextTransitionStyle = true
			mapTooltipVC!.modalPresentationStyle = .overFullScreen
			mapTooltipVC!.modalTransitionStyle = .crossDissolve
			
			self.present(mapTooltipVC!, animated: true, completion: nil)
		}
	}
	
	private func hideMapTooltips() {
		if let tooltipVC = mapTooltipVC {
			// Update user defaults
			let defaults = UserDefaults.standard
			defaults.set(false, forKey: Common.UserDefaults.showMapTooltipsDefaultsKey)
			defaults.synchronize()
			
			tooltipVC.dismiss(animated: true, completion: nil)
			mapTooltipVC = nil
		}
		
		showContentIfNeeded()
	}
	
	// MARK: Leave Tour
	
	private func showLeaveTourMessage() {
		leaveTourMessageView = MessageViewController(message: Common.Messages.leavingTour)
		leaveTourMessageView!.delegate = self
		
		// Modal presentation style
		leaveTourMessageView!.definesPresentationContext = true
		leaveTourMessageView!.providesPresentationContextTransitionStyle = true
		leaveTourMessageView!.modalPresentationStyle = .overFullScreen
		leaveTourMessageView!.modalTransitionStyle = .crossDissolve
		
		self.present(leaveTourMessageView!, animated: true, completion: nil)
	}
	
	private func hideLeaveTourMessage() {
		if let messageView = leaveTourMessageView {
			messageView.dismiss(animated: true, completion: nil)
			leaveTourMessageView = nil
		}
	}
	
	// MARK: Show
	
	func showAllInformation() {
		currentMode = .allInformation
		mapVC.showAllInformation()
		if mapContentCardVC != nil {
			mapContentCardVC!.hide()
		}
		mapContentCardVC = nil
		tourModel = nil
		tourStopPageVC = nil
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
		
		// if we are on the Map tab, open tour immediately
		// otherwise open it at viewWillAppear, so the card opens after the view layout is completed
		if isMapTabOpen {
			if sectionNavigationBar.currentState != .hidden {
				sectionNavigationBar.hide()
			}
			
			// Creeate Tour Stops card
			tourStopPageVC = TourStopPageViewController(tour: tourModel!)
			
			// Crate Content Card
			if mapContentCardVC != nil {
				mapContentCardVC!.view.removeFromSuperview()
			}
			mapContentCardVC = MapContentCardNavigationController(contentVC: tourStopPageVC!)
			mapContentCardVC!.titleLabel.text = tourModel!.title
			mapContentCardVC!.cardDelegate = self
			tourStopPageVC!.tourStopPageDelegate = self
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))
			
			// Set map state
			mapVC.showTour(forTour: tour)
			
			// Set TourStopPageVC to the right stop
			if let index = tourStopIndex {
				mapVC.highlightTourStop(identifier: tourModel!.stops[index].object.nid, location: tourModel!.stops[index].object.location)
				tourStopPageVC!.setCurrentPage(pageIndex: index + 1) // add +1 for tour overview
			}
			else {
				tourStopPageVC!.setCurrentPage(pageIndex: 0)
			}
		
			showMapContentCard()
		}
	}
	
	func showArtwork(artwork: AICObjectModel) {
		currentMode = .artwork
		artworkModel = artwork
		
		// if we are on the Map tab, open tour immediately
		// otherwise open it at viewWillAppear, so the card opens after the view layout is completed
		if isMapTabOpen {
			if sectionNavigationBar.currentState != .hidden {
				sectionNavigationBar.hide()
			}
			
			// Crate Content Card
			if mapContentCardVC != nil {
				mapContentCardVC!.view.removeFromSuperview()
			}
			let artworkVC = UIViewController()
			let artworkContentView = MapArtworkContentView(artwork: artwork)
			artworkContentView.audioButton.addTarget(self, action: #selector(mapArtworkAudioButtonPressed(button:)), for: .touchUpInside)
			artworkContentView.imageButton.addTarget(self, action: #selector(mapArtworkImageButtonPressed(button:)), for: .touchUpInside)
			artworkVC.view.addSubview(artworkContentView)
			mapContentCardVC = MapContentCardNavigationController(contentVC: artworkVC)
			mapContentCardVC!.titleLabel.text = artwork.title
			mapContentCardVC!.cardDelegate = self
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))
			
			// Set map state
			mapVC.showArtwork(artwork: artwork)
			
			showMapContentCard()
		}
	}
	
	func showSearchedArtwork(searchedArtwork: AICSearchedArtworkModel) {
		currentMode = .searchedArtwork
		searchedArtworkModel = searchedArtwork
		
		// if we are on the Map tab, open tour immediately
		// otherwise open it at viewWillAppear, so the card opens after the view layout is completed
		if isMapTabOpen {
			if sectionNavigationBar.currentState != .hidden {
				sectionNavigationBar.hide()
			}
			
			// Crate Content Card
			if mapContentCardVC != nil {
				mapContentCardVC!.view.removeFromSuperview()
			}
			let artworkVC = UIViewController()
			let artworkContentView = MapArtworkContentView(searchedArtwork: searchedArtwork)
			artworkContentView.audioButton.addTarget(self, action: #selector(mapArtworkAudioButtonPressed(button:)), for: .touchUpInside)
			artworkContentView.imageButton.addTarget(self, action: #selector(mapArtworkImageButtonPressed(button:)), for: .touchUpInside)
			artworkVC.view.addSubview(artworkContentView)
			mapContentCardVC = MapContentCardNavigationController(contentVC: artworkVC)
			mapContentCardVC!.titleLabel.text = searchedArtwork.title
			mapContentCardVC!.cardDelegate = self
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))
			
			// Set map state
			mapVC.showSearchedArtwork(searchedArtwork: searchedArtwork)
		
			showMapContentCard()
		}
	}
	
	func showExhibition(exhibition: AICExhibitionModel) {
		currentMode = .exhibition
		exhibitionModel = exhibition
		
		// if we are on the Map tab, open tour immediately
		// otherwise open it at viewWillAppear, so the card opens after the view layout is completed
		if isMapTabOpen {
			if sectionNavigationBar.currentState != .hidden {
				sectionNavigationBar.hide()
			}
			
			// Crate Content Card
			if mapContentCardVC != nil {
				mapContentCardVC!.view.removeFromSuperview()
			}
			let exhibitionVC = UIViewController()
			mapContentCardVC = MapContentCardNavigationController(contentVC: exhibitionVC)
			mapContentCardVC!.titleLabel.text = exhibitionModel!.title
			mapContentCardVC!.cardDelegate = self
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))
			
			// Set map state
			mapVC.showExhibition(exhibition: exhibition)
			
			showMapContentCard()
		}
	}
	
	func showDining() {
		currentMode = .dining
		
		// if we are on the Map tab, open tour immediately
		// otherwise open it at viewWillAppear, so the card opens after the view layout is completed
		if isMapTabOpen {
			if sectionNavigationBar.currentState != .hidden {
				sectionNavigationBar.hide()
			}
			
			// Create Restaurants card
			if mapContentCardVC != nil {
				mapContentCardVC!.view.removeFromSuperview()
			}
			restaurantPageVC = RestaurantPageViewController(restaurants: AppDataManager.sharedInstance.app.restaurants)
			mapContentCardVC = MapContentCardNavigationController(contentVC: restaurantPageVC!)
			mapContentCardVC!.titleLabel.text = "Dining"
			mapContentCardVC!.cardDelegate = self
			restaurantPageVC!.restaurantPageDelegate = self
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))
			
			// Set first restaurant
			restaurantPageVC!.setCurrentPage(pageIndex: 0)
			
			// Set map state
			mapVC.showDining()
			
			showMapContentCard()
		}
	}
	
	func showRestrooms() {
		currentMode = .restrooms
		
		// if we are on the Map tab, open tour immediately
		// otherwise open it at viewWillAppear, so the card opens after the view layout is completed
		if isMapTabOpen {
			if sectionNavigationBar.currentState != .hidden {
				sectionNavigationBar.hide()
			}
			
			// Crate Content Card
			if mapContentCardVC != nil {
				mapContentCardVC!.view.removeFromSuperview()
			}
			let restroomsContentView = MapTextContentView(text: "Close to explore everything.")
			mapContentCardVC = MapContentCardNavigationController(contentView: restroomsContentView)
			mapContentCardVC!.titleLabel.text = "Restrooms"
			mapContentCardVC!.cardDelegate = self
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))
			
			// Set map state
			mapVC.showRestrooms()
		
			showMapContentCard()
		}
	}
	
	func showGiftShop() {
		currentMode = .giftshop
		
		// if we are on the Map tab, open tour immediately
		// otherwise open it at viewWillAppear, so the card opens after the view layout is completed
		if isMapTabOpen {
			if sectionNavigationBar.currentState != .hidden {
				sectionNavigationBar.hide()
			}
			
			// Crate Content Card
			if mapContentCardVC != nil {
				mapContentCardVC!.view.removeFromSuperview()
			}
			let giftshopContentView = MapTextContentView(text: "Close to exlpore everything.")
			mapContentCardVC = MapContentCardNavigationController(contentView: giftshopContentView)
			mapContentCardVC!.titleLabel.text = "Gift Shops"
			mapContentCardVC!.cardDelegate = self
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))
			
			// Set map state
			mapVC.showGiftShop()
		
			showMapContentCard()
		}
	}
	
	private func showMapContentCard() {
		if mapContentCardVC!.currentState == .hidden {
			mapContentCardVC!.showMinimized()
		}
	}
	
	// MARK: Audio Button
	@objc private func mapArtworkAudioButtonPressed(button: UIButton) {
		if let searchedArtwork = searchedArtworkModel {
			if let object = searchedArtwork.audioObject {
				self.sectionDelegate?.mapDidSelectPlayAudioForArtwork(artwork: object)
			}
		}
		else if let artwork = artworkModel {
			self.sectionDelegate?.mapDidSelectPlayAudioForArtwork(artwork: artwork)
		}
	}
	
	@objc func mapArtworkImageButtonPressed(button: UIButton) {
		if let searchedArtwork = searchedArtworkModel {
			mapVC.highlightArtwork(identifier: searchedArtwork.artworkId, location: searchedArtwork.location)
		}
		else if let artwork = artworkModel {
			mapVC.highlightArtwork(identifier: artwork.nid, location: artwork.location)
		}
	}
}

// MARK: Message Delegate Methods

extension MapNavigationController : MessageViewControllerDelegate {
	func messageViewActionSelected(messageVC: MessageViewController) {
		if messageVC == enableLocationMessageView {
			hideEnableLocationMessage()
			startLocationManager()
		}
		else if messageVC == leaveTourMessageView {
			showAllInformation()
			hideLeaveTourMessage()
		}
	}
	
	func messageViewCancelSelected(messageVC: MessageViewController) {
		if messageVC == enableLocationMessageView {
			hideEnableLocationMessage()
		}
		else if messageVC == leaveTourMessageView {
			hideLeaveTourMessage()
		}
	}
}

// MARK: Map Delegate Methods

extension MapNavigationController : MapViewControllerDelegate {
	func mapWasPressed() {
		sectionNavigationBar.hide()
	}
	
	func mapDidPressArtworkPlayButton(artwork: AICObjectModel) {
		if mapVC.mode == .tour {
			if let tour = tourModel {
				if let stopIndex = tour.getIndex(forStopObject: artwork) {
					let tourStop = tour.stops[stopIndex]
					self.sectionDelegate?.mapDidSelectPlayAudioForTourStop(tourStop: tourStop, tour: tourModel!, language: tour.language)
				}
			}
		}
		else {
			self.sectionDelegate?.mapDidSelectPlayAudioForArtwork(artwork: artwork)
		}
	}
	
	func mapDidSelectTourStop(stopId: Int) {
		if let tour = tourModel {
			if tour.nid == stopId {
				tourStopPageVC!.setCurrentPage(pageIndex: 0)
			}
			else if let artwork = AppDataManager.sharedInstance.getObject(forID: stopId) {
				let pageIndex = tour.getIndex(forStopObject: artwork)! + 1 // add 1 for the overview
				tourStopPageVC!.setCurrentPage(pageIndex: pageIndex)
			}
		}
	}
	
	func mapDidSelectRestaurant(restaurant: AICRestaurantModel) {
		for index in 0...AppDataManager.sharedInstance.app.restaurants.count-1 {
			let restaurantModel = AppDataManager.sharedInstance.app.restaurants[index]
			if restaurantModel.nid == restaurant.nid {
				restaurantPageVC?.setCurrentPage(pageIndex: index)
			}
		}
	}
}

// MARK: CardNavigationControllerDelegate

extension MapNavigationController : CardNavigationControllerDelegate {
	// update the view area of the map as the card slides
	func cardDidUpdatePosition(cardVC: CardNavigationController, position: CGPoint) {
		self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: position.y)))
	}
	
	func cardShouldHide(cardVC: CardNavigationController) -> Bool {
		if currentMode == .tour {
			showLeaveTourMessage()
			return false
		}
		return true
	}
	
	func cardDidHide(cardVC: CardNavigationController) {
		if mapContentCardVC != nil {
			mapContentCardVC!.view.removeFromSuperview()
		}
		showAllInformation()
	}
}

// MARK: TourStopPageViewControllerDelegate

extension MapNavigationController : TourStopPageViewControllerDelegate {
	func tourStopPageDidChangeTo(tour: AICTourModel) {
		mapVC.highlightTourStop(identifier: tour.nid, location: tour.location)
	}
	
	func tourStopPageDidChangeTo(tourStop: AICTourStopModel) {
		mapVC.highlightTourStop(identifier: tourStop.object.nid, location: tourStop.object.location)
	}
	
	func tourStopPageDidPressPlayAudio(tour: AICTourModel, language: Common.Language) {
		self.sectionDelegate?.mapDidSelectPlayAudioForTour(tour: tour, language: language)
	}
	
	func tourStopPageDidPressPlayAudio(tourStop: AICTourStopModel, language: Common.Language) {
		self.sectionDelegate?.mapDidSelectPlayAudioForTourStop(tourStop: tourStop, tour: tourModel!, language: language)
	}
}

// MARK: RestaurantPageViewControllerDelegate

extension MapNavigationController : RestaurantPageViewControllerDelegate {
	func restaurantPageDidChangeTo(restaurant: AICRestaurantModel) {
		mapVC.highlightRestaurant(identifier: restaurant.nid, location: restaurant.location)
	}
}

// MARK: TourStopPageViewControllerDelegate

extension MapNavigationController : TooltipViewControllerDelegate {
	func tooltipsCompleted(tooltipVC: TooltipViewController) {
		hideMapTooltips()
	}
}



