/*
 Abstract:
 Holds all of the section views
 Overrides UIView hitTesting to pass touches through the background of a view
*/

import UIKit

class SectionsContentView: UIView {

    // Override to only test children
    // Content view can then have userInteractionEnabled turned off/on
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        }
        
        return hitView
    }

}
