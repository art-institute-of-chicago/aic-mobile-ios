//
//  TourStopPageViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/5/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol TourStopPageViewControllerDelegate : class {
	func tourStopPageDidChangeTo(tourOverview: AICTourOverviewModel)
	func tourStopPageDidChangeTo(tourStop: AICTourStopModel)
	func tourStopPageDidPressPlayAudio(tourStop: AICTourStopModel, language: Common.Language)
}

class TourStopPageViewController : UIPageViewController {
	private var tourModel: AICTourModel
	
	private var currentIndex = -1
	
	weak var tourStopPageDelegate: TourStopPageViewControllerDelegate? = nil
	
	init(tour: AICTourModel) {
		tourModel = tour
		super.init(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.clipsToBounds = false
		
		// Init the first item view controller
		
		self.delegate = self
		self.dataSource = self
		
		// Set page control styles
		let pageControl = UIPageControl.appearance()
		pageControl.backgroundColor = .clear
		pageControl.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.3)
		pageControl.currentPageIndicatorTintColor = .white
		pageControl.layer.borderColor = UIColor.white.cgColor
		pageControl.layer.borderWidth = 1
		
		setCurrentPage(pageIndex: 0)
	}
	
	func tourStopController(_ index: Int) -> UIViewController? {
		if index < tourModel.stops.count {
			currentIndex = index
			let page = UIViewController()
			
//				if index == 0 {
//					// Tour Overview
//					page.titleLabel.text = tour.overview.title
//					page.imageView.kf.setImage(with: tour.overview.imageUrl)
//					page.locationLabel.text = Common.Map.stringForFloorNumber[tour.stops.first!.object.location.floor]
//					page.view.tag = index
//
//					page.audioButton.tag = -1
//				}
//				else {
				// Stop
//					if index < tour.stops.count {
			let stop = tourModel.stops[index]
			
			let artworkContentView = MapArtworkContentView(tourStop: stop, language: tourModel.language)
			artworkContentView.audioButton.tag = index
			page.view.addSubview(artworkContentView)
			artworkContentView.audioButton.addTarget(self, action: #selector(audioButtonPressed(button:)), for: .touchUpInside)
			page.view.tag = index
//					}
//
//				}
			
			return page
		}
		return nil
	}
	
	func setCurrentPage(pageIndex: Int) {
		if currentIndex == pageIndex {
			return
		}
		
		// Set Tour Stop Page
		if let viewController = tourStopController(pageIndex) {
			let viewControllers = [viewController]
			
			setViewControllers(
				viewControllers,
				direction: .forward,
				animated: false,
				completion: nil
			)
		}
	}
	
	@objc func audioButtonPressed(button: UIButton) {
		if tourModel.stops.indices.contains(button.tag) {
			self.tourStopPageDelegate?.tourStopPageDidPressPlayAudio(tourStop: tourModel.stops[button.tag], language: tourModel.language)
		}
	}
}

// MARK: UIPageViewControllerDataSource
extension TourStopPageViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerBefore viewController: UIViewController) -> UIViewController? {
		var index = viewController.view.tag
		guard index != NSNotFound && index != 0 else { return nil }
		index = index - 1
		return tourStopController(index)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerAfter viewController: UIViewController) -> UIViewController? {
		var index = viewController.view.tag
		guard index != NSNotFound else { return nil }
		index = index + 1
		guard index != tourModel.stops.count else {return nil}
		return tourStopController(index)
	}
	
	// MARK: UIPageControl
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return tourModel.stops.count
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return currentIndex
	}
}

// MARK: UIPageViewControllerDelegate
extension TourStopPageViewController : UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed == true {
			if let viewController = self.viewControllers!.first {
				currentIndex = viewController.view.tag
				if let tour = tourModel as AICTourModel? {
					if currentIndex <= tour.stops.count-1 {
						self.tourStopPageDelegate?.tourStopPageDidChangeTo(tourStop: tour.stops[currentIndex])
					}
				}
			}
		}
	}
}
