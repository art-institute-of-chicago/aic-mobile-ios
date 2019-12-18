//
//  TooltipViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/22/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol TooltipViewControllerDelegate: class {
	func tooltipsDismissedTooltip(index: Int)
}

class TooltipViewController: UIViewController {
	private var tooltipIndex: Int = 0
	private var tooltips: [AICTooltipModel] = []

	private var currentPage: Int = -1 {
		didSet {
			previousButton.isHidden = currentPage == 0
			if currentPage == tooltips.count-1 {
				nextButton.setTitle("Dismiss".localized(using: "Tooltips").uppercased(), for: .normal)
			} else {
				nextButton.setTitle("Next".localized(using: "Tooltips").uppercased(), for: .normal)
			}
		}
	}
	private let popupView: UIView = UIView()
	private let pageVC: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
	private let nextButton: UIButton = UIButton()
	private let previousButton: UIButton = UIButton()

	weak var delegate: TooltipViewControllerDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = UIColor(white: 51.0 / 255.0, alpha: 0.65)

		popupView.frame = CGRect(x: 24.0, y: 100.0 + Common.Layout.safeAreaTopMargin, width: UIScreen.main.bounds.width - 48.0, height: 260.0)
		popupView.backgroundColor = .aicTooltipBackgroundColor

		pageVC.view.frame = CGRect(x: 0, y: 0, width: popupView.frame.width, height: 254.0)
		pageVC.view.backgroundColor = .clear
		pageVC.view.clipsToBounds = true
		pageVC.delegate = self
		pageVC.dataSource = self

		nextButton.backgroundColor = .clear
		nextButton.setTitleColor(.white, for: .normal)
		nextButton.setTitle("Next".localized(using: "Tooltips").uppercased(), for: .normal)
		nextButton.titleLabel?.font = .aicTooltipDismissFont
		nextButton.titleLabel?.textAlignment = .right
		nextButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)

		previousButton.backgroundColor = .clear
		previousButton.setTitleColor(.white, for: .normal)
		previousButton.setTitle("Previous".localized(using: "Tooltips").uppercased(), for: .normal)
		previousButton.titleLabel?.font = .aicTooltipDismissFont
		previousButton.titleLabel?.textAlignment = .left
		previousButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)

		popupView.addSubview(pageVC.view)
		popupView.addSubview(nextButton)
		popupView.addSubview(previousButton)

		createConstraints()

		let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
		self.view.addGestureRecognizer(tapGesture)
	}

	private func createConstraints() {
		nextButton.autoPinEdge(.trailing, to: .trailing, of: popupView, withOffset: -16)
		nextButton.autoPinEdge(.bottom, to: .bottom, of: popupView, withOffset: -10)

		previousButton.autoPinEdge(.leading, to: .leading, of: popupView, withOffset: 16)
		previousButton.autoPinEdge(.bottom, to: .bottom, of: popupView, withOffset: -10)
	}

	func showPageTooltips(tooltips: [AICTooltipModel], tooltipIndex: Int) {
		self.tooltipIndex = tooltipIndex
		self.tooltips = tooltips
		for view in self.view.subviews {
			view.removeFromSuperview()
		}

		self.view.addSubview(popupView)

		// Set page control styles
		let pageControl = UIPageControl.appearance()
		pageControl.backgroundColor = .clear
		pageControl.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.3)
		pageControl.currentPageIndicatorTintColor = .white
		pageControl.layer.borderColor = UIColor.white.cgColor
		pageControl.layer.borderWidth = 1
		pageControl.isUserInteractionEnabled = false // disable tap

		self.currentPage = -1
		setCurrentPage(pageIndex: 0, animated: false)
	}

	func showArrowTooltips(tooltips: [AICTooltipModel], tooltipIndex: Int) {
		self.tooltipIndex = tooltipIndex
		self.tooltips = tooltips
		for view in self.view.subviews {
			view.removeFromSuperview()
		}

		for tooltip in tooltips {
			let arrowView = TooltipArrowView(tooltip: tooltip)
			self.view.addSubview(arrowView)
		}
	}

	func createPageController(_ pageIndex: Int) -> UIViewController? {
		if pageIndex < tooltips.count {
			let tooltip = tooltips[pageIndex]

			let viewController = UIViewController()
			viewController.view.tag = pageIndex
			viewController.view.frame = CGRect(origin: .zero, size: self.pageVC.view.frame.size)
			let pageView = TooltipPopupPageView(frame: viewController.view.frame, tooltip: tooltip)
			viewController.view.addSubview(pageView)

			return viewController
		}
		return nil
	}

	func setCurrentPage(pageIndex: Int, animated: Bool) {
		if currentPage == pageIndex || pageIndex >= tooltips.count {
			return
		}
		let previousPage = currentPage
		currentPage = pageIndex

		// Set Tour Stop Page
		if let viewController = createPageController(pageIndex) {
			let viewControllers = [viewController]

			self.pageVC.setViewControllers(
				viewControllers,
				direction: currentPage > previousPage ? .forward : .reverse,
				animated: animated,
				completion: nil
			)
		}
	}

	@objc private func buttonPressed(button: UIButton) {
		if button == previousButton {
			setCurrentPage(pageIndex: currentPage-1, animated: true)
		} else if button == nextButton {
			if currentPage < tooltips.count-1 {
				setCurrentPage(pageIndex: currentPage+1, animated: true)
			} else {
				self.delegate?.tooltipsDismissedTooltip(index: tooltipIndex)
			}
		}
	}

	@objc private func handleGesture(gesture: UIGestureRecognizer) {
		if popupView.superview == nil {
			self.delegate?.tooltipsDismissedTooltip(index: tooltipIndex)
		}
	}
}

// MARK: UIPageViewControllerDataSource
extension TooltipViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerBefore viewController: UIViewController) -> UIViewController? {
		var pageIndex = viewController.view.tag
		guard pageIndex != NSNotFound && pageIndex != 0 else { return nil }
		pageIndex = pageIndex - 1
		return createPageController(pageIndex)
	}

	func pageViewController(_ pageViewController: UIPageViewController,
							viewControllerAfter viewController: UIViewController) -> UIViewController? {
		var pageIndex = viewController.view.tag
		guard pageIndex != NSNotFound else { return nil }
		pageIndex = pageIndex + 1
		guard pageIndex != tooltips.count else {return nil}
		return createPageController(pageIndex)
	}

	// MARK: UIPageControl
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return tooltips.count
	}

	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return currentPage
	}
}

// MARK: UIPageViewControllerDelegate
extension TooltipViewController: UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

	}

	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed == true {
			if let viewController = self.pageVC.viewControllers!.first {
				currentPage = viewController.view.tag
			}
		}
	}
}
