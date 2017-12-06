//
//  CardAnimator.swift
//  aic
//
//  Created by Filippo Vanucci on 12/4/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class CardInteractor: UIPercentDrivenInteractiveTransition {
	var hasStarted = false
	var shouldFinish = false
}

class CardAnimator : NSObject {
}

extension CardAnimator : UIViewControllerAnimatedTransitioning {
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 2.0
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard
			let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
			let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
			else {
				return
		}
		
		let containerView = transitionContext.containerView
		containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
		
		let bottomLeftCorner = CGPoint(x: 0, y: UIScreen.main.bounds.height)
		let outFrame = CGRect(origin: bottomLeftCorner, size: UIScreen.main.bounds.size)
		
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			fromVC.view.frame = outFrame
		}) { (completed) in
			if completed == true {
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			}
		}
	}
}
