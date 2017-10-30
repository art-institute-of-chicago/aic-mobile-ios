/*
 Abstract:
 Section View for Tours Section, inherits from NewsTourSectionView
 */

import UIKit

class ToursSectionView: NewsToursSectionView {

    override init(section:AICSectionModel, revealView:NewsToursRevealView) {
        super.init(section:section, revealView: revealView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Override hit testing so the view itself passes through touches to underneath
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self || hitView == self.scrollView {
            return nil
        }
        
        return hitView
    }
}
