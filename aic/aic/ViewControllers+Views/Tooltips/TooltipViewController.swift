//
//  TooltipViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/22/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol TooltipViewControllerDelegate: class {
	func tooltipsMoveToNextTooltip(index: Int) -> AICTooltipModel?
	func tooltipsCompleted(tooltipVC: TooltipViewController)
}

class TooltipViewController : UIViewController {
	private let backgroundOverlayView: UIView = UIView()
	private var currentTooltipView: UIView = UIView()
	private var currentIndex: Int = 0
	
	weak var delegate: TooltipViewControllerDelegate? = nil
	
	init(firstTooltip: AICTooltipModel) {
		super.init(nibName: nil, bundle: nil)
		self.currentTooltipView = createTooltipView(tooltip: firstTooltip)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
		self.view.addGestureRecognizer(tapGesture)
		
		showTooltip()
	}
	
	private func createTooltipView(tooltip: AICTooltipModel) -> UIView {
		if tooltip.type == .popup {
			return TooltipPopupView(tooltip: tooltip)
		}
		return TooltipArrowView(tooltip: tooltip)
	}
	
	private func showTooltip() {
		for view in self.view.subviews {
			view.removeFromSuperview()
		}
		self.view.addSubview(self.currentTooltipView)
	}
	
	@objc private func handleGesture(gesture: UIGestureRecognizer) {
		currentIndex += 1
		if let nextTooltip = self.delegate?.tooltipsMoveToNextTooltip(index: currentIndex) {
			currentTooltipView = createTooltipView(tooltip: nextTooltip)
			showTooltip()
		}
		else {
			self.delegate?.tooltipsCompleted(tooltipVC: self)
		}
	}
}

