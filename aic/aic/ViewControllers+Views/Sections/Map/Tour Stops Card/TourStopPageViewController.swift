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
	
	private var currentIndex = 0
	private var currentPage = 0
	
	init() {
		super.init(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedContentHeight)
		self.view.clipsToBounds = true
		
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
			let page = TourStopViewController()
			
			page.titleLabel.text = tour.stops[index].object.title
			page.imageView.kf.setImage(with: tour.stops[index].object.imageUrl)
			page.stopIndex = index
			
			return page
		}
		
		return nil
	}
	
	func setTour(tour: AICTourModel, stopIndex: Int) {
		tourModel = tour
		currentPage = stopIndex
		currentIndex = stopIndex
		
		// Set Tour Stop Page
		if let viewController = tourStopController(currentPage) {
			let viewControllers = [viewController]
			
			// Set them
			setViewControllers(
				viewControllers,
				direction: .forward,
				animated: false,
				completion: nil
			)
		}
	}
	
//	// Override to put the page view controller on top
//	override func viewDidLayoutSubviews() {
//		super.viewDidLayoutSubviews()
//
//		var scrollView: UIScrollView? = nil
//		var pageControl: UIPageControl? = nil
//		let subViews: NSArray = view.subviews as NSArray
//
//		for view in subViews {
//			if view is UIScrollView {
//				scrollView = view as? UIScrollView
//			}
//			else if view is UIPageControl {
//				pageControl = (view as? UIPageControl)
//				pageControl!.frame.origin.y = UIScreen.main.bounds.height - pageControl!.frame.height - pageControlMarginBottom
//
//				for view in pageControl!.subviews {
//					view.layer.borderColor = UIColor.white.cgColor
//					view.layer.borderWidth = 1
//				}
//			}
//		}
//
//		if (scrollView != nil && pageControl != nil) {
//			scrollView?.frame = view.bounds
//			view.bringSubview(toFront: pageControl!)
//		}
//	}
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
			return tour.stops.count
		}
		return 0
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
		
	}
}
