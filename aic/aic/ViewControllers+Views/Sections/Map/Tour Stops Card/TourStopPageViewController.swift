//
//  TourStopPageViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/5/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class TourStopPageViewController : UIPageViewController {
	private var tourModel: AICTourModel? = nil
	
	private var tourStopViewControllers: [TourStopViewController] = []
	
	private var currentIndex = 0
	
	init() {
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
	}
	
	func tourStopController(_ index: Int) -> TourStopViewController? {
		if let tour = tourModel {
			if index < tour.stops.count + 1 {
				let page = TourStopViewController()
				
				if index == 0 {
					// Tour Overview
					page.titleLabel.text = tour.overview.title
					page.imageView.kf.setImage(with: tour.overview.imageUrl)
					page.stopIndex = index
				}
				else {
					// Stop
					if index-1 < tour.stops.count {
						let stop = tour.stops[index-1]
						page.titleLabel.text = stop.object.title
						page.imageView.kf.setImage(with: stop.object.imageUrl)
						page.stopIndex = index
					}
				}
				return page
			}
		}
		return nil
	}
	
	func setTour(tour: AICTourModel) {
		tourModel = tour
		setCurrentPage(pageIndex: 0)
	}
	
	func setCurrentPage(pageIndex: Int) {
		// Set Tour Stop Page
		if let viewController = tourStopController(pageIndex) {
			currentIndex = pageIndex
			
			let viewControllers = [viewController]
			
			setViewControllers(
				viewControllers,
				direction: .forward,
				animated: false,
				completion: nil
			)
		}
	}
}

// MARK: UIPageViewControllerDataSource
extension TourStopPageViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		if let viewController = viewController as? TourStopViewController {
			var index = viewController.stopIndex
			currentIndex = index
			guard index != NSNotFound && index != 0 else { return nil }
			index = index - 1
			return tourStopController(index)
		}
		
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		if let viewController = viewController as? TourStopViewController {
			if let tour = tourModel {
				var index = viewController.stopIndex
				currentIndex = index
				guard index != NSNotFound else { return nil }
				index = index + 1
				guard index != tour.stops.count else {return nil}
				
				return tourStopController(index)
			}
		}
		
		return nil
	}
	
	// MARK: UIPageControl
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		if let tour = tourModel {
			return tour.stops.count + 1
		}
		return 0
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
		
	}
}
