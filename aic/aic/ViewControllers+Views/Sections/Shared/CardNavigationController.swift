//
//  CardViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/4/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

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
	private static var topPosition: CGFloat {
		if UIDevice().type == .iPhoneX {
			return 30
		}
		return 20
	}
	private static let bottomPosition: CGFloat = UIScreen.main.bounds.height - Common.Layout.tabBarHeight
	
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
		self.becomeFirstResponder()
		super.viewDidLoad()
		
		self.view.isHidden = true
		self.view.frame.origin = CGPoint(x: 0.0, y: CardNavigationController.bottomPosition)
		
		self.view.backgroundColor = .aicDarkGrayColor
		
		// Add subviews
		self.view.addSubview(downArrowImageView)
		
		// Root view controller
		rootVC.view.backgroundColor = .clear
		self.pushViewController(rootVC, animated: false)
		
		// Pan Gesture
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
		self.view.addGestureRecognizer(panGesture)
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
	
	override func updateViewConstraints() {
		downArrowImageView.autoSetDimensions(to: downArrowImageView.image!.size)
		downArrowImageView.autoPinEdge(.top, to: .top, of: self.view, withOffset: downArrowTopMargin)
		downArrowImageView.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		// TODO: makit it take into account tabBarHeight as well, then fix it also in resultsVC
		rootVC.view.autoSetDimension(.width, toSize: UIScreen.main.bounds.width)
		rootViewHeightConstraint = rootVC.view.autoSetDimension(.height, toSize: UIScreen.main.bounds.height - CardNavigationController.topPosition - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight)
		
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
				self.view.frame.origin = CGPoint(x: 0, y: CardNavigationController.topPosition)
				self.view.layer.cornerRadius = 10
			case .hidden:
				self.view.frame.origin = CGPoint(x: 0, y: CardNavigationController.bottomPosition)
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
			var fraction = translation.y / (CardNavigationController.bottomPosition - CardNavigationController.topPosition)
			
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
			animateTransitionIfNeeded(to: .fullscreen, duration: 1.0)
		}
	}
	
	func hide() {
		if self.currentState != .hidden {
			animateTransitionIfNeeded(to: .hidden, duration: 1.0)
		}
	}
	
	// MARK: Animation Callbacks
	
	func cardWillShowFullscreen() {
		
	}
	
	func cardDidShowFullscreen() {
		
	}
}

