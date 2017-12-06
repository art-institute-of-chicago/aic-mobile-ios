//
//  CardViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/4/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class CardViewController : UIViewController {
	
	var interactor: CardInteractor? = nil
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .aicDarkGrayColor
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender:)))
		self.view.addGestureRecognizer(panGesture)
	}
	
	@objc func handlePanGesture(sender: UIPanGestureRecognizer) {
		let percentThreshold:CGFloat = 0.3
		
		// convert y-position to downward pull progress (percentage)
		let translation = sender.translation(in: view)
		let verticalMovement = translation.y / view.bounds.height
		let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
		let downwardMovementPercent = fminf(downwardMovement, 1.0)
		let progress = CGFloat(downwardMovementPercent)
		
		guard let interactor = interactor else { return }

		switch sender.state {
		case .began:
			interactor.hasStarted = true
			dismiss(animated: true, completion: nil)
		case .changed:
			interactor.shouldFinish = progress > percentThreshold
			interactor.update(progress)
		case .cancelled:
			interactor.hasStarted = false
			interactor.cancel()
		case .ended:
			interactor.hasStarted = false
			interactor.shouldFinish
				? interactor.finish()
				: interactor.cancel()
		default:
			break
		}
	}
}

extension CardViewController : UIViewControllerTransitioningDelegate {
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animator = CardAnimator()
		return animator
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return (self.interactor?.hasStarted)! ? interactor : nil
	}
}

