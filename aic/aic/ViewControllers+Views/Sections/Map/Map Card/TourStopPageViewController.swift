//
//  TourStopPageViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/5/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol TourStopPageViewControllerDelegate : class {
	func tourStopPageDidChangeTo(tour: AICTourModel)
	func tourStopPageDidChangeTo(tourStop: AICTourStopModel)
	func tourStopPageDidPressPlayAudio(tour: AICTourModel, language: Common.Language)
	func tourStopPageDidPressPlayAudio(tourStop: AICTourStopModel, language: Common.Language)
}

class TourStopPageViewController : UIPageViewController {
	private var tourModel: AICTourModel
	
	private var currentPage = -1
	private var totalPages = 0
	
	weak var tourStopPageDelegate: TourStopPageViewControllerDelegate? = nil
	
	init(tour: AICTourModel) {
		tourModel = tour
		totalPages = tourModel.stops.count + 1 // add overview
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
		pageControl.isUserInteractionEnabled = false // disable tap
		
		setCurrentPage(pageIndex: 0)
	}
	
	func tourStopController(_ pageIndex: Int) -> UIViewController? {
		if pageIndex < totalPages {
			currentPage = pageIndex
			let page = UIViewController()
			page.view.tag = currentPage
			
			if currentPage == 0 {
				// Tour Overview
				let artworkContentView = MapArtworkContentView(tour: tourModel, language: tourModel.language)
				artworkContentView.audioButton.tag = currentPage
				artworkContentView.audioButton.addTarget(self, action: #selector(audioButtonPressed(button:)), for: .touchUpInside)
				page.view.addSubview(artworkContentView)
			}
			else {
				// Stop
				let stopIndex = currentPage-1
				if stopIndex < tourModel.stops.count {
					let stop = tourModel.stops[stopIndex]
					
					let artworkContentView = MapArtworkContentView(tourStop: stop, language: tourModel.language)
					artworkContentView.audioButton.tag = currentPage
					artworkContentView.audioButton.addTarget(self, action: #selector(audioButtonPressed(button:)), for: .touchUpInside)
					page.view.addSubview(artworkContentView)
				}
			}
			
			return page
		}
		return nil
	}
	
	func setCurrentPage(pageIndex: Int) {
		if currentPage == pageIndex {
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
		if button.tag < totalPages {
			if button.tag == 0 {
				self.tourStopPageDelegate?.tourStopPageDidPressPlayAudio(tour: tourModel, language: tourModel.language)
			}
			else {
				let stopIndex = button.tag-1
				if stopIndex < tourModel.stops.count {
					self.tourStopPageDelegate?.tourStopPageDidPressPlayAudio(tourStop: tourModel.stops[stopIndex], language: tourModel.language)
				}
			}
		}
	}
}

// MARK: UIPageViewControllerDataSource
extension TourStopPageViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerBefore viewController: UIViewController) -> UIViewController? {
		var pageIndex = viewController.view.tag
		guard pageIndex != NSNotFound && pageIndex != 0 else { return nil }
		pageIndex = pageIndex - 1
		return tourStopController(pageIndex)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerAfter viewController: UIViewController) -> UIViewController? {
		var pageIndex = viewController.view.tag
		guard pageIndex != NSNotFound else { return nil }
		pageIndex = pageIndex + 1
		guard pageIndex != totalPages else {return nil}
		return tourStopController(pageIndex)
	}
	
	// MARK: UIPageControl
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return totalPages
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return currentPage
	}
}

// MARK: UIPageViewControllerDelegate
extension TourStopPageViewController : UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed == true {
			if let viewController = self.viewControllers!.first {
				currentPage = viewController.view.tag
				if let tour = tourModel as AICTourModel? {
					if currentPage == 0 {
						self.tourStopPageDelegate?.tourStopPageDidChangeTo(tour: tourModel)
					}
					else if currentPage < totalPages {
						let stopIndex = currentPage-1
						if stopIndex < tour.stops.count {
							self.tourStopPageDelegate?.tourStopPageDidChangeTo(tourStop: tour.stops[stopIndex])
						}
					}
				}
			}
		}
	}
}
