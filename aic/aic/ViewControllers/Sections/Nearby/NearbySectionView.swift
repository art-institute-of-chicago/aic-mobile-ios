/*
 Abstract:
 Section View for Nearby Section
*/

import UIKit

protocol NearbySectionViewDelegate : class {
    func shouldMinimizeTopNavigation()
    func shouldMaximizeTopNavigation()
}

class NearbySectionView: SectionView {
    
    weak var delegate:NearbySectionViewDelegate? = nil
    
    let passThroughView = UIView() // View to catch touches and pass them throught to BG

    override init(section:AICSectionModel) {
        super.init(section:section)
        
        passThroughView.backgroundColor = UIColor.clear
    
        scrollView.isScrollEnabled = false
        
        // Add Subviews
        scrollViewContentView.insertSubview(passThroughView, belowSubview: titleView)
        
        // Add Gesture Recognizers
        let titleTap = UITapGestureRecognizer(target:self, action:#selector(NearbySectionView.titleViewTapped(_:)))
        titleView.addGestureRecognizer(titleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Override hit testing so the view itself passes through touches to underneath
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == passThroughView {
            delegate?.shouldMinimizeTopNavigation()
            return nil
        }
        
        return hitView
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
            passThroughView.snp.makeConstraints({ (make) in
                make.top.lessThanOrEqualTo(titleView.snp.bottom).priority(Common.Layout.Priority.high.rawValue)
                make.top.equalTo(scrollViewContentView).offset(titleViewHeight)
                make.left.right.equalTo(passThroughView.superview!)
                make.height.equalTo(1000)
            })
            
            scrollViewContentView.snp.makeConstraints({ (make) in
                make.bottom.equalTo(passThroughView)
            })
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}

// Gesture Recognizers
extension NearbySectionView {
    func titleViewTapped(_ recognizer: UITapGestureRecognizer) {
        delegate?.shouldMaximizeTopNavigation()
    }
}
