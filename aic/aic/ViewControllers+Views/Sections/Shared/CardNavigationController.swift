//
//  CardNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/1/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

@objc protocol CardNavigationControllerDelegate : class {
    @objc optional func cardDidUpdatePosition(cardVC: CardNavigationController, position: CGPoint)
    @objc optional func cardDidHide(cardVC: CardNavigationController)
}

class CardNavigationController : UINavigationController {
    enum State {
        case hidden
        case minimized
        case mini_player
        case fullscreen
    }
    var currentState: State = .hidden
    var openState: State = .fullscreen
    var closedState: State = .hidden
    
    weak var cardDelegate: CardNavigationControllerDelegate? = nil
    
    // Root view controller
    // Add your main ViewController as a subview of rootVC
    let rootVC: UIViewController = UIViewController()
    
    // Card Pan Gesture Recognizer to show/hide/minimize
    let cardPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    let downArrowImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "cardDownArrow"))
    
    private (set) var downArrowTopMargin: CGFloat = 11.0
    private (set) var contentTopMargin: CGFloat = 30
    
    private let positionForState: [State : CGFloat] = [
        .hidden : UIScreen.main.bounds.height - Common.Layout.tabBarHeight,
        .minimized : UIScreen.main.bounds.height - Common.Layout.tabBarHeight - Common.Layout.cardMinimizedContentHeight,
        .mini_player : UIScreen.main.bounds.height - Common.Layout.tabBarHeight - Common.Layout.miniAudioPlayerHeight,
        .fullscreen : Common.Layout.cardFullscreenPositionY
    ]
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame.origin = CGPoint(x: 0.0, y: positionForState[.hidden]!)
        self.view.backgroundColor = .aicDarkGrayColor
        
        // Hide Navigation Bar
        self.navigationBar.isTranslucent = false
        self.setNavigationBarHidden(true, animated: false)
        
        // Add subviews
        self.view.addSubview(downArrowImageView)
        
        // Arrow constraints
        downArrowImageView.autoSetDimensions(to: downArrowImageView.image!.size)
        downArrowImageView.autoPinEdge(.top, to: .top, of: self.view, withOffset: downArrowTopMargin)
        downArrowImageView.autoAlignAxis(.vertical, toSameAxisOf: self.view)
        
        // Root view controller
        rootVC.view.backgroundColor = .clear
        self.pushViewController(rootVC, animated: false)
        
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
    
    fileprivate func setCardPosition(_ positionY: CGFloat) {
        let yPosition = clamp(val: positionY, minVal: positionForState[openState]!, maxVal: positionForState[.hidden]!)
        self.view.frame.origin = CGPoint(x: 0, y: yPosition)
        
        self.cardDelegate?.cardDidUpdatePosition?(cardVC: self, position: self.view.frame.origin)
    }
    
    // MARK: Show/Hide
    
    func showFullscreen() {
        cardWillShowFullscreen()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.setCardPosition(self.positionForState[.fullscreen]!)
            self.view.layer.cornerRadius = 10
        }, completion: { (completed) in
            self.currentState = .fullscreen
            self.cardDidShowFullscreen()
        })
    }
    
    func showMinimized() {
        cardWillShowMinimized()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.setCardPosition(self.positionForState[.minimized]!)
            self.view.layer.cornerRadius = 10
        }, completion: { (completed) in
            self.currentState = .minimized
            self.cardDidShowMinimized()
        })
    }
    
    func showMiniPlayer() {
        cardWillShowMiniPlayer()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.setCardPosition(self.positionForState[.mini_player]!)
            self.view.layer.cornerRadius = 0
        }, completion: { (completed) in
            self.currentState = .mini_player
            self.cardDidShowMiniPlayer()
        })
    }
    
    func hide() {
        cardWillHide()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
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
}

// MARK: Gesture Handlers

extension CardNavigationController : UIGestureRecognizerDelegate {
    @objc internal func handlePanGesture(recognizer: UIPanGestureRecognizer) {
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
        if recognizer.state == UIGestureRecognizerState.ended {
            // Calculate whee we are between top and bottom
            let pctInScreenArea: CGFloat = CGFloat(map(val: Double(newY), oldRange1: Double(positionForState[openState]!), oldRange2: Double(positionForState[closedState]!), newRange1: 0.0, newRange2: 1.0))
            
            var snapToState: State = .fullscreen
            
            // If we're close to top or bottom just snap
            if pctInScreenArea > 1.0 - viewSnapRegion {
                snapToState = closedState
            }
            else if pctInScreenArea < viewSnapRegion {
                snapToState = openState
            }
            // Otherwise, snap based on velocity (direction)
            else {
                if(recognizer.velocity(in: view).y > 0) {
                    snapToState = closedState
                } else {
                    snapToState = openState
                }
            }
            
            // Snap
            if snapToState == .hidden {
                hide()
            }
            else if snapToState == .mini_player {
                showMiniPlayer()
            }
            else if snapToState == .minimized {
                showMinimized()
            }
            else if snapToState == .fullscreen {
                showFullscreen()
            }
        }
        else {
            setCardPosition(newY)
        }
        
        // Clean up gesture
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UISlider {
            return false
        }
        return true
    }
    
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

