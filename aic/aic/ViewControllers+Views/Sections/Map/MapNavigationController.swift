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
	func mapDidSelectPlayAudioForTourStop(tourStop: AICTourStopModel, language: Common.Language)
}

class MapNavigationController : SectionNavigationController {
	var currentMode: MapViewController.Mode = .allInformation
	
	// Models for content modes
	var tourModel: AICTourModel? = nil
	var tourStopIndex: Int? = nil
	var artworkModel: AICSearchedArtworkModel? = nil
	
	let mapVC: MapViewController = MapViewController()
	var mapContentCardVC: MapContentCardNavigationController? = nil
	var tourStopPageVC: TourStopPageViewController? = nil
	
	private var enableLocationMessageView: MessageViewController? = nil
	
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
		if currentMode == .tour {
			showTour(tour: tourModel!, language: tourModel!.language, stopIndex: tourStopIndex)
			
			mapVC.setViewableArea(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: mapContentCardVC!.view.frame.origin.y))
		}
		else if currentMode == .artwork {
			showArtwork(artwork: artworkModel!)
			
			mapVC.setViewableArea(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: mapContentCardVC!.view.frame.origin.y))
		}
		else if currentMode == .giftshop {
			showGiftShop()
			
			mapVC.setViewableArea(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: mapContentCardVC!.view.frame.origin.y))
		}
		else if currentMode == .restrooms {
			showRestrooms()
			
			mapVC.setViewableArea(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: mapContentCardVC!.view.frame.origin.y))
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
	
	func showMapTooltips() {
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
	
	func hideMapTooltips() {
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
	
	// MARK: Show
	
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
			if let index = stopIndex {
				tourStopPageVC!.setCurrentPage(pageIndex: index)
			}
			else {
				tourStopPageVC!.setCurrentPage(pageIndex: 0)
			}
			
			// Crate Content Card
			if mapContentCardVC != nil {
				mapContentCardVC!.view.removeFromSuperview()
			}
			mapContentCardVC = MapContentCardNavigationController(contentVC: tourStopPageVC!)
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// Set delegates
			mapContentCardVC!.cardDelegate = self
			tourStopPageVC!.tourStopPageDelegate = self
			
			// Tour title
			mapContentCardVC!.titleLabel.text = tourModel!.title
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))
			
			// Set map state
			mapVC.showTour(forTour: tour)
		
			showMapContentCard()
		}
	}
	
	func showArtwork(artwork: AICSearchedArtworkModel) {
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
			let artworkContentView = MapArtworkContentView(searchedArtwork: artwork)
			artworkVC.view.addSubview(artworkContentView)
			mapContentCardVC = MapContentCardNavigationController(contentVC: artworkVC)
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// Set delegates
			mapContentCardVC!.cardDelegate = self
			
			// Artwork title
			mapContentCardVC!.titleLabel.text = artwork.title
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))
			
			// Set map state
			mapVC.showArtwork(artwork: artwork)
		
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
			mapContentCardVC = MapContentCardNavigationController(contentVC: UIViewController())
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// Set delegates
			mapContentCardVC!.cardDelegate = self
			
			// Artwork title
			mapContentCardVC!.titleLabel.text = "Restrooms"
			
			// in case the tour card is open, to tell the map to animate the floor selector
			self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))
			
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
			mapContentCardVC = MapContentCardNavigationController(contentVC: UIViewController())
			
			// Add card to view
			mapContentCardVC!.willMove(toParentViewController: self)
			self.view.addSubview(mapContentCardVC!.view)
			mapContentCardVC!.didMove(toParentViewController: self)
			
			// Set delegates
			mapContentCardVC!.cardDelegate = self
			
			// Artwork title
			mapContentCardVC!.titleLabel.text = "Gift Shops"
			
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
}

// MARK: Message Delegate Methods

extension MapNavigationController : MessageViewControllerDelegate {
	func messageViewActionSelected(messageVC: MessageViewController) {
		if messageVC == enableLocationMessageView {
			hideEnableLocationMessage()
			startLocationManager()
		}
	}
	
	func messageViewCancelSelected(messageVC: MessageViewController) {
		if messageVC == enableLocationMessageView {
			hideEnableLocationMessage()
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
					self.sectionDelegate?.mapDidSelectPlayAudioForTourStop(tourStop: tourStop, language: tour.language)
				}
			}
		}
		else {
			self.sectionDelegate?.mapDidSelectPlayAudioForArtwork(artwork: artwork)
		}
	}
	
	func mapDidSelectTourStop(artwork: AICObjectModel) {
		if let tour = tourModel {
			let pageIndex = tour.getIndex(forStopObject: artwork)
			tourStopPageVC!.setCurrentPage(pageIndex: pageIndex!)
		}
	}
}

// MARK: CardNavigationControllerDelegate

extension MapNavigationController : CardNavigationControllerDelegate {
	// update the view area of the map as the card slides
	func cardDidUpdatePosition(cardVC: CardNavigationController, position: CGPoint) {
		self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: position.y)))
	}
	
	func cardDidHide(cardVC: CardNavigationController) {
		if mapContentCardVC != nil {
			mapContentCardVC!.view.removeFromSuperview()
		}
		currentMode = .allInformation
		mapVC.showAllInformation()
		mapContentCardVC = nil
		tourModel = nil
		tourStopPageVC = nil
	}
}

// MARK: TourStopPageViewControllerDelegate

extension MapNavigationController : TourStopPageViewControllerDelegate {
	func tourStopPageDidChangeTo(tourOverview: AICTourOverviewModel) {
		mapVC.showTourOverview()
	}
	
	func tourStopPageDidChangeTo(tourStop: AICTourStopModel) {
		mapVC.highlightTourStop(tourStop: tourStop)
	}
	
	func tourStopPageDidPressPlayAudio(tourStop: AICTourStopModel, language: Common.Language) {
		self.sectionDelegate?.mapDidSelectPlayAudioForTourStop(tourStop: tourStop, language: language)
	}
}

// MARK: TourStopPageViewControllerDelegate

extension MapNavigationController : TooltipViewControllerDelegate {
	func tooltipsCompleted(tooltipVC: TooltipViewController) {
		hideMapTooltips()
	}
}



