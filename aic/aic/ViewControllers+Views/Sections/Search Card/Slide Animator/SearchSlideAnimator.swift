//
//  SearchSlideAnimator.swift
//  aic
//
//  Created by Filippo Vanucci on 2/2/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SearchSlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	var isAnimatingIn: Bool = true

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.3
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
		let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)

		let toOrigin: CGFloat = (isAnimatingIn) ? UIScreen.main.bounds.width : -UIScreen.main.bounds.width
		//        let fromDestination: CGFloat = (isAnimatingIn) ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width

		if isAnimatingIn {
			containerView.addSubview(fromVC!.view)
			containerView.addSubview(toVC!.view)
		} else {
			containerView.addSubview(toVC!.view)
			containerView.addSubview(fromVC!.view)
		}
		toVC!.view.frame.origin = CGPoint(x: toOrigin, y: toVC!.view.frame.origin.y)
		//fromVC!.view.frame.origin = CGPoint(x: 0.0, y: fromVC!.view.frame.origin.y)

		let duration = transitionDuration(using: transitionContext)
		UIView.animate(withDuration: duration, animations: {
			toVC!.view.frame.origin = CGPoint(x: 0, y: toVC!.view.frame.origin.y)
			toVC!.view.alpha = 1.0
			if self.isAnimatingIn == true {
				fromVC!.view.alpha = 0.3
				fromVC!.view.frame.origin = CGPoint(x: -150.0, y: fromVC!.view.frame.origin.y)
			} else {
				fromVC!.view.frame.origin = CGPoint(x: UIScreen.main.bounds.width, y: fromVC!.view.frame.origin.y)
			}
		}) { _ in
			let cancelled = transitionContext.transitionWasCancelled
			transitionContext.completeTransition(!cancelled)
			if self.isAnimatingIn == true {
				fromVC!.view.frame.origin = CGPoint(x: -UIScreen.main.bounds.width * 0.5, y: fromVC!.view.frame.origin.y)
			}
		}
	}
}
