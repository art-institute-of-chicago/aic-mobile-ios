//
//  UIViewController+ChildTransition.swift
//  aic
//
//  Created by Pawel Milek on 16/03/2023.
//  Copyright © 2023 Art Institute of Chicago. All rights reserved.
//

import UIKit

extension UIViewController {

    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

}
