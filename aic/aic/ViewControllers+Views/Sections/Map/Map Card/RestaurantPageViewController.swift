//
//  RestaurantPageViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 3/1/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol RestaurantPageViewControllerDelegate : class {
	func restaurantPageDidChangeTo(restaurant: AICRestaurantModel)
}

class RestaurantPageViewController : UIPageViewController {
	private var restaurants: [AICRestaurantModel]
	
	private var currentPage = -1
	private var totalPages = 0
	
	weak var restaurantPageDelegate: RestaurantPageViewControllerDelegate? = nil
	
	init(restaurants: [AICRestaurantModel]) {
		self.restaurants = restaurants
		totalPages = self.restaurants.count
		super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
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
	
	func restaurantController(_ pageIndex: Int) -> UIViewController? {
		if pageIndex < totalPages {
			currentPage = pageIndex
			let page = UIViewController()
			page.view.tag = currentPage
			
			let restaurantContentView = MapRestaurantContentView(restaurant: restaurants[pageIndex])
			page.view.addSubview(restaurantContentView)
			
			return page
		}
		return nil
	}
	
	func setCurrentPage(pageIndex: Int) {
		if currentPage == pageIndex {
			return
		}
		
		// Set Tour Stop Page
		if let viewController = restaurantController(pageIndex) {
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
extension RestaurantPageViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerBefore viewController: UIViewController) -> UIViewController? {
		var pageIndex = viewController.view.tag
		guard pageIndex != NSNotFound && pageIndex != 0 else { return nil }
		pageIndex = pageIndex - 1
		return restaurantController(pageIndex)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerAfter viewController: UIViewController) -> UIViewController? {
		var pageIndex = viewController.view.tag
		guard pageIndex != NSNotFound else { return nil }
		pageIndex = pageIndex + 1
		guard pageIndex != totalPages else {return nil}
		return restaurantController(pageIndex)
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
extension RestaurantPageViewController : UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed == true {
			if let viewController = self.viewControllers!.first {
				currentPage = viewController.view.tag
				if currentPage < totalPages {
					self.restaurantPageDelegate?.restaurantPageDidChangeTo(restaurant: restaurants[currentPage])
				}
			}
		}
	}
}
