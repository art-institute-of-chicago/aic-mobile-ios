//
//  TooltipViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/22/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol TooltipViewControllerDelegate: class {
	func tooltipsCompleted(tooltipVC: TooltipViewController)
}

class TooltipViewController : UIViewController {
	private let backgroundOverlayView: UIView = UIView()
	private let tooltips: [AICTooltipModel]
	private var tooltipViews: [UIView] = []
	private var currentIndex: Int = -1
	
	weak var delegate: TooltipViewControllerDelegate? = nil
	
	init(tooltips: [AICTooltipModel]) {
		self.tooltips = tooltips
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		for tooltip in tooltips {
			if tooltip.type == .popup {
				let tooltipView = TooltipPopupView(tooltip: tooltip)
				tooltipViews.append(tooltipView)
			}
			else if tooltip.type == .arrow {
				let tooltipView = TooltipArrowView(tooltip: tooltip)
				tooltipViews.append(tooltipView)
			}
		}
		
		let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
		self.view.addGestureRecognizer(tapGesture)
		
		showTooltip(index: 0)
	}
	
	private func showTooltip(index: Int) {
		if index < tooltipViews.count {
			for view in self.view.subviews {
				view.removeFromSuperview()
			}
			
			currentIndex = index
			self.view.addSubview(tooltipViews[index])
		}
		else {
			self.delegate?.tooltipsCompleted(tooltipVC: self)
		}
	}
	
	@objc private func handleGesture(gesture: UIGestureRecognizer) {
		showTooltip(index: currentIndex+1)
	}
}

