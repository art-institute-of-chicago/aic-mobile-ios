//
//  CardViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/4/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol CardNavigationControllerDelegate : class {
	func cardDidHide(cardVC: CardNavigationController)
}

class CardNavigationController : UINavigationController {
	
	enum State {
		case hidden
		case fullscreen
	}
	var currentState: State = .hidden
	
	let downArrowImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "cardDownArrow"))
	
	// Root view controller
	// If it's a single view card (i.e. Tour Card), simply add your views to rootVC
	let rootVC: UIViewController = UIViewController()
	
	var rootViewHeightConstraint: NSLayoutConstraint? = nil
	
	private var transitionAnimator: UIViewPropertyAnimator? = nil
	private var animationProgress: CGFloat = 0.0
	
	private var downArrowTopMargin: CGFloat = 11.0
	
	private let topPosition: CGFloat = Common.Layout.cardTopPosition
	private let bottomPosition: CGFloat = UIScreen.main.bounds.height - Common.Layout.tabBarHeight
	
	let slideAnimator: CardSlideAnimator = CardSlideAnimator()
	
	weak var cardDelegate: CardNavigationControllerDelegate? = nil
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var canBecomeFirstResponder : Bool {
		return true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.isHidden = true
		self.view.frame.origin = CGPoint(x: 0.0, y: bottomPosition)
		
		self.view.backgroundColor = .aicDarkGrayColor
		
		// Add subviews
		self.view.addSubview(downArrowImageView)
		
		// Root view controller
		rootVC.view.backgroundColor = .clear
		self.pushViewController(rootVC, animated: false)
		
		// Pan Gesture
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
		self.view.addGestureRecognizer(panGesture)
		
		// NavigationController Delegate
		self.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Hide Navigation Bar
		self.navigationBar.isTranslucent = false
		self.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Important: this is the magic that makes gestures work on this view
		self.becomeFirstResponder()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.resignFirstResponder()
	}
	
	override func updateViewConstraints() {
		downArrowImageView.autoSetDimensions(to: downArrowImageView.image!.size)
		downArrowImageView.autoPinEdge(.top, to: .top, of: self.view, withOffset: downArrowTopMargin)
		downArrowImageView.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		// TODO: make it take into account tabBarHeight as well, then fix it also in resultsVC
		rootVC.view.autoSetDimension(.width, toSize: UIScreen.main.bounds.width)
		rootViewHeightConstraint = rootVC.view.autoSetDimension(.height, toSize: Common.Layout.cardContentHeight)
		
		super.updateViewConstraints()
	}
	
	// MARK: Animation
	
	/// Animates the transition, if the animation is not already running.
	private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
		
		// ensure that the animator hasn't been created yet
		guard transitionAnimator == nil else {
			return
		}
		
		self.view.isHidden = false
		
		// an animator for the transition
		transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
			switch state {
			case .fullscreen:
				self.view.frame.origin = CGPoint(x: 0, y: self.topPosition)
				self.view.layer.cornerRadius = 10
			case .hidden:
				self.view.frame.origin = CGPoint(x: 0, y: self.bottomPosition)
				self.view.layer.cornerRadius = 15
				self.view.layer.cornerRadius = 0
			}
			self.view.layoutIfNeeded()
		})
		
		// the transition completion block
		transitionAnimator?.addCompletion { position in
			
			// update the state
			switch position {
			case .start:
				self.currentState = state == .fullscreen ? .hidden : .fullscreen
			case .end:
				if self.currentState != .fullscreen && state == .fullscreen {
					self.cardDidShowFullscreen()
				}
				else if self.currentState != .hidden && state == .hidden {
					self.cardDidHide()
				}
				self.currentState = state
				if self.currentState == .hidden {
					self.view.isHidden = true
				}
			case .current:
				()
			}
			
			// manually reset the constraint positions
//			switch self.currentState {
//			case .open:
//				self.topConstraint?.constant = UIScreen.main.bounds.height - Common.Layout.tabBarHeight
//			case .closed:
//				self.topConstraint?.constant = Common.Layout.safeAreaTopMargin
//			}
			
			// reset running animator
			self.transitionAnimator = nil
		}
		
		// start all animators
		transitionAnimator?.startAnimation()
	}
	
	@objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			
			// start the animations
			animateTransitionIfNeeded(to: (currentState == .fullscreen ? .hidden : .fullscreen), duration: 1)
			
			// pause all animations, since the next event may be a pan changed
			transitionAnimator?.pauseAnimation()
			
			// keep track of each animator's progress
			animationProgress = transitionAnimator!.fractionComplete
			
		case .changed:
			
			// variable setup
			let translation = recognizer.translation(in: self.view)
			var fraction = translation.y / (bottomPosition - topPosition)
			
			// adjust the fraction for the current state and reversed state
			if currentState == .hidden { fraction *= -1 }
			if transitionAnimator!.isReversed { fraction *= -1 }
			
			// apply the new fraction
			transitionAnimator?.fractionComplete = fraction + animationProgress
			
		case .ended:
			
			// variable setup
			let yVelocity = recognizer.velocity(in: self.view).y
			let shouldClose = yVelocity > 0
			
			// if there is no motion, continue all animations and exit early
			if yVelocity == 0 {
				transitionAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
				break
			}
			
			// reverse the animations based on their current state and pan motion
			switch currentState {
			case .fullscreen:
				if !shouldClose && !transitionAnimator!.isReversed { transitionAnimator!.isReversed = !transitionAnimator!.isReversed }
				if shouldClose && transitionAnimator!.isReversed { transitionAnimator!.isReversed = !transitionAnimator!.isReversed }
			case .hidden:
				if shouldClose && !transitionAnimator!.isReversed { transitionAnimator!.isReversed = !transitionAnimator!.isReversed }
				if !shouldClose && transitionAnimator!.isReversed { transitionAnimator!.isReversed = !transitionAnimator!.isReversed }
			}
			
			// continue all animations
			transitionAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
			
		default:
			()
		}
	}
	
	// MARK: Show/Hide
	
	func showFullscreen() {
		cardWillShowFullscreen()
		if self.currentState != .fullscreen {
			animateTransitionIfNeeded(to: .fullscreen, duration: 0.5)
		}
	}
	
	func hide() {
		cardWillHide()
		if self.currentState != .hidden {
			animateTransitionIfNeeded(to: .hidden, duration: 0.5)
		}
	}
	
	// MARK: Show/Hide Animation Callbacks
	
	func cardWillShowFullscreen() {}
	
	func cardDidShowFullscreen() {}
	
	func cardWillHide() {}
	
	func cardDidHide() {}
}

// MARK: UINavigationControllerDelegate

extension CardNavigationController : UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		slideAnimator.isAnimatingIn = (operation == .push)
		return slideAnimator
	}
}

// MARK: UIViewControllerAnimatedTransitioning

class CardSlideAnimator : NSObject, UIViewControllerAnimatedTransitioning {
	var isAnimatingIn: Bool = true

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.3
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
		let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)

		let toOrigin: CGFloat = (isAnimatingIn) ? UIScreen.main.bounds.width : -UIScreen.main.bounds.width
//		let fromDestination: CGFloat = (isAnimatingIn) ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width

		containerView.addSubview(toVC!.view)
		toVC!.view.frame.origin = CGPoint(x: toOrigin, y: toVC!.view.frame.origin.y)
		//fromVC!.view.frame.origin = CGPoint(x: 0.0, y: fromVC!.view.frame.origin.y)

		let duration = transitionDuration(using: transitionContext)
		UIView.animate(withDuration: duration, animations: {
			toVC!.view.frame.origin = CGPoint(x: 0, y: toVC!.view.frame.origin.y)
			toVC!.view.alpha = 1.0
			if (self.isAnimatingIn == true) {
				fromVC!.view.alpha = 0.3
				//fromVC!.view.frame.origin = CGPoint(x: -150.0, y: fromVC!.view.frame.origin.y)
			}
			else {
				fromVC!.view.frame.origin = CGPoint(x: UIScreen.main.bounds.width, y: fromVC!.view.frame.origin.y)
			}
		}) { finished in
			let cancelled = transitionContext.transitionWasCancelled
			transitionContext.completeTransition(!cancelled)
			if (self.isAnimatingIn == true) {
				fromVC!.view.frame.origin = CGPoint(x:  -UIScreen.main.bounds.width * 0.5, y: fromVC!.view.frame.origin.y)
			}
		}
	}
}

