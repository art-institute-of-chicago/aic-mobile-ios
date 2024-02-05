//
//  CardNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/1/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import PureLayout

@objc protocol CardNavigationControllerDelegate: AnyObject {
	@objc optional func cardDidUpdatePosition(cardVC: CardNavigationController, position: CGPoint)
	@objc optional func cardWillShowFullscreen(cardVC: CardNavigationController)
	@objc optional func cardDidShowMinimized(cardVC: CardNavigationController)
	@objc optional func cardWillShowMiniplayer(cardVC: CardNavigationController)
	@objc optional func cardDidShowMiniplayer(cardVC: CardNavigationController)
	@objc optional func cardWillHide(cardVC: CardNavigationController)
	@objc optional func cardShouldHide(cardVC: CardNavigationController) -> Bool
	@objc optional func cardDidHide(cardVC: CardNavigationController)
}

class CardNavigationController: UINavigationController {
	enum State {
		case hidden
		case minimized
		case mini_player
		case fullscreen
	}
	var currentState: State = .hidden
	var openState: State = .fullscreen
	var closedState: State = .hidden

	weak var cardDelegate: CardNavigationControllerDelegate?

	// Root view controller
	// Add your main ViewController as a subview of rootVC
	let rootVC: UIViewController = UIViewController()

	// Card Pan Gesture Recognizer to show/hide/minimize
	let tapToCloseGesture: UITapGestureRecognizer = UITapGestureRecognizer()
	let cardPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()

	let downArrowButton: UIButton = UIButton()
	let closeButton: UIButton = UIButton()

	private (set) var contentTopMargin: CGFloat = 30

	private let positionForState: [State: CGFloat] = [
		.hidden: UIScreen.main.bounds.height - Common.Layout.tabBarHeight,
		.minimized: Common.Layout.cardMinimizedPositionY,
		.mini_player: UIScreen.main.bounds.height - Common.Layout.tabBarHeight - Common.Layout.miniAudioPlayerHeight,
		.fullscreen: Common.Layout.cardFullscreenPositionY
	]

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.frame.origin = CGPoint(x: 0.0, y: positionForState[.hidden]!)
		self.view.backgroundColor = .aicDarkGrayColor

		// Hide Navigation Bar
		self.navigationBar.isTranslucent = false
		self.setNavigationBarHidden(true, animated: false)

		// Down Arrow Button
		downArrowButton.setImage(#imageLiteral(resourceName: "cardDownArrow"), for: .normal)
		downArrowButton.setImage(#imageLiteral(resourceName: "cardDownArrow"), for: .highlighted)
		downArrowButton.addTarget(self, action: #selector(downArrowButtonPressed(button:)), for: .touchUpInside)
		downArrowButton.isEnabled = true

		// Close Button
		closeButton.setImage(#imageLiteral(resourceName: "closeCard"), for: .normal)
		closeButton.imageEdgeInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
		closeButton.addTarget(self, action: #selector(closeButtonPressed(button:)), for: .touchUpInside)
		closeButton.isEnabled = false
		closeButton.isHidden = true

		// Add subviews
		self.view.addSubview(downArrowButton)
		self.view.addSubview(closeButton)

		// Root view controller
		rootVC.view.backgroundColor = .clear
		self.pushViewController(rootVC, animated: false)

		// Constraints
		downArrowButton.imageView!.contentMode = .center
		downArrowButton.autoSetDimensions(to: CGSize(width: UIScreen.main.bounds.width-200, height: 40))
		downArrowButton.autoPinEdge(.top, to: .top, of: self.view)
		downArrowButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)

		closeButton.autoSetDimensions(to: CGSize(width: 37, height: 37))
		closeButton.autoPinEdge(.top, to: .top, of: self.view)
		closeButton.autoPinEdge(.trailing, to: .trailing, of: self.view)

		updateViewConstraints()
		self.view.layoutIfNeeded()

		// Pan Gesture
		cardPanGesture.addTarget(self, action: #selector(handlePanGesture(recognizer:)))
		cardPanGesture.delegate = self
		self.view.addGestureRecognizer(cardPanGesture)
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

	// MARK: Position

	func setCardPosition(_ positionY: CGFloat) {
		let yPosition = clamp(val: positionY, minVal: positionForState[openState]!, maxVal: positionForState[.hidden]!)
		self.view.frame.origin = CGPoint(x: 0, y: yPosition)

		self.cardDelegate?.cardDidUpdatePosition?(cardVC: self, position: self.view.frame.origin)
	}

	// MARK: Show/Hide

	func showFullscreen() {
		cardWillShowFullscreen()
		self.cardDelegate?.cardWillShowFullscreen?(cardVC: self)
		setCloseButtonEnabled(enabled: false)
		UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut], animations: {
			self.setCardPosition(self.positionForState[.fullscreen]!)
			self.view.layer.cornerRadius = 10
		}, completion: { (_) in
			self.currentState = .fullscreen
			self.cardDidShowFullscreen()
		})
	}

	func showMinimized() {
		cardWillShowMinimized()
		setCloseButtonEnabled(enabled: true)
		UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut], animations: {
			self.setCardPosition(self.positionForState[.minimized]!)
			self.view.layer.cornerRadius = 10
		}, completion: { (_) in
			self.currentState = .minimized
			self.cardDidShowMinimized()
			self.cardDelegate?.cardDidShowMinimized?(cardVC: self)
		})
	}

	func showMiniPlayer() {
		cardWillShowMiniPlayer()
		self.cardDelegate?.cardWillShowMiniplayer?(cardVC: self)
		setCloseButtonEnabled(enabled: false)
		UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut], animations: {
			self.setCardPosition(self.positionForState[.mini_player]!)
			self.view.layer.cornerRadius = 0
		}, completion: { (_) in
			self.currentState = .mini_player
			self.cardDidShowMiniPlayer()
			self.cardDelegate?.cardDidShowMiniplayer?(cardVC: self)
		})
	}

	func hide() {
		cardWillHide()
		self.cardDelegate?.cardWillHide?(cardVC: self)
		UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut], animations: {
			self.setCardPosition(self.positionForState[.hidden]!)
			self.view.layer.cornerRadius = 0
		}, completion: { (completed) in
			if completed == true {
				self.currentState = .hidden
				self.cardDidHide()
				self.cardDelegate?.cardDidHide?(cardVC: self)
			}
		})
	}

	// MARK: Show/Hide Animation Callbacks

	func cardWillShowFullscreen() {}

	func cardDidShowFullscreen() {}

	func cardWillShowMinimized() {}

	func cardDidShowMinimized() {}

	func cardWillShowMiniPlayer() {}

	func cardDidShowMiniPlayer() {}

	func cardWillHide() {}

	func cardDidHide() {}

	private func setCloseButtonEnabled(enabled: Bool) {
		cardPanGesture.isEnabled = !enabled
		downArrowButton.isHidden = enabled
		downArrowButton.isEnabled = !enabled
		closeButton.isEnabled = enabled
		closeButton.isHidden = !enabled
	}

	@objc private func closeButtonPressed(button: UIButton) {
		if let delegate = self.cardDelegate {
			if let cardShouldHide = delegate.cardShouldHide?(cardVC: self) {
				if cardShouldHide {
					hide()
				}
			} else {
				hide()
			}
		} else {
			hide()
		}
	}
}

// MARK: Gesture Handlers

extension CardNavigationController: UIGestureRecognizerDelegate {
	@objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
		guard let view = recognizer.view else {
			return
		}

		// Pan Gesture disabled in MiniPlayer State
		if currentState == .mini_player {
			return
		}

		let viewSnapRegion: CGFloat = 0.25

		// Calculate the new position
		let translation = recognizer.translation(in: view)
		let newY: CGFloat = view.frame.origin.y + translation.y

		// If we've ended, snap to top or bottom
		if recognizer.state == .ended {
			// Calculate whee we are between top and bottom
			let pctInScreenArea: CGFloat = CGFloat(map(val: Double(newY), oldRange1: Double(positionForState[openState]!), oldRange2: Double(positionForState[closedState]!), newRange1: 0.0, newRange2: 1.0))

			var snapToState: State = .fullscreen

			// If we're close to top or bottom just snap
			if pctInScreenArea > 1.0 - viewSnapRegion {
				snapToState = closedState
			} else if pctInScreenArea < viewSnapRegion {
				snapToState = openState
			}
				// Otherwise, snap based on velocity (direction)
			else {
				if recognizer.velocity(in: view).y > 0 {
					snapToState = closedState
				} else {
					snapToState = openState
				}
			}

			// Snap
			if snapToState == .hidden {
				hide()
			} else if snapToState == .mini_player {
				showMiniPlayer()
			} else if snapToState == .minimized {
				showMinimized()
			} else if snapToState == .fullscreen {
				showFullscreen()
			}
		} else {
			setCardPosition(newY)
		}

		// Clean up gesture
		recognizer.setTranslation(CGPoint.zero, in: view)
	}

	@objc func downArrowButtonPressed(button: UIButton) {
		if currentState == openState {
			if closedState == .minimized {
				showMinimized()
			} else if closedState == .mini_player {
				showMiniPlayer()
			} else if closedState == .hidden {
				hide()
			}
		}
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		if touch.view is UISlider {
			return false
		}
		return true
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
