//
//  CardNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/1/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol CardNavigationControllerDelegate : class {
    func cardDidHide(cardVC: CardNavigationController)
}

class NewCardNavigationController : UINavigationController {
    enum State {
        case hidden
        case minimized
        case mini_player
        case fullscreen
    }
    var currentState: State = .hidden
    
    weak var cardDelegate: CardNavigationControllerDelegate? = nil
    
    // Root view controller
    // Add your main ViewController as a subview of rootVC
    let rootVC: UIViewController = UIViewController()
    
    let downArrowImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "cardDownArrow"))
    
    private (set) var downArrowTopMargin: CGFloat = 11.0
    private (set) var contentTopMargin: CGFloat = 30
    
    private let positionForState: [State : CGFloat] = [
        .hidden : UIScreen.main.bounds.height - Common.Layout.tabBarHeight,
        .minimized : UIScreen.main.bounds.height - Common.Layout.tabBarHeight - Common.Layout.miniAudioPlayerHeight - Common.Layout.cardMinimizedContentHeight,
        .mini_player : UIScreen.main.bounds.height - Common.Layout.tabBarHeight - Common.Layout.miniAudioPlayerHeight,
        .fullscreen : Common.Layout.cardFullscreenPositionY
    ]
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true
        self.view.frame.origin = CGPoint(x: 0.0, y: positionForState[.hidden]!)
        
        self.view.backgroundColor = .aicDarkGrayColor
        
        // Add subviews
        self.view.addSubview(downArrowImageView)
        
        // Root view controller
        rootVC.view.backgroundColor = .clear
        self.pushViewController(rootVC, animated: false)
        
        updateViewConstraints()
        self.view.layoutIfNeeded()
        
        // Pan Gesture
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
//        self.view.addGestureRecognizer(panGesture)
        
        // NavigationController Delegate
        //self.delegate = self
    }
}

// MARK: UINavigationControllerDelegate

//extension NewCardNavigationController : UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        slideAnimator.isAnimatingIn = (operation == .push)
//        return slideAnimator
//    }
//}

