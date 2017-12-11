/*
 Abstract:
 Base view for all Section Views (NumberPad, What's On, Tours, Nearby and Info)
*/

import UIKit

class SectionView: BaseView {
    var didSetupBaseConstraints = false
    
    let titleScrolledTopMargin = 25
	
    var scrollView = UIScrollView()
    var scrollViewContentView = UIView()
    
    
    internal var titleViewHeight:CGFloat {
        get {
            // Force the title view to layout
            // so we can use it's height for offset
            // Use the first height since it
            // stretches with the top of the scroll view
            let scrollOffsetY = self.scrollView.contentOffset.y
            self.scrollView.contentOffset.y = 0
            
			let height: CGFloat = 240.0
            self.scrollView.contentOffset.y = scrollOffsetY
            
            return height
        }
    }
    
    init(section:AICSectionModel) {
        super.init(frame:UIScreen.main.bounds)//CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeight))
        
        
        // Clear background so the map shows through
        backgroundColor = .clear
        
        // All section views have a scroll view with a title view
        scrollView.addSubview(scrollViewContentView)
        addSubview(scrollView)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if !didSetupBaseConstraints {
            scrollView.snp.makeConstraints({ (make) -> Void in
                make.edges.equalTo(scrollView.superview!).priority(Common.Layout.Priority.required.rawValue)
            })
            
            scrollViewContentView.snp.makeConstraints({ (make) -> Void in
                make.edges.equalTo(scrollView)
                make.width.equalTo(scrollView)
            })
            
            didSetupBaseConstraints = true
        }
        
        super.updateConstraints()
    }
}
