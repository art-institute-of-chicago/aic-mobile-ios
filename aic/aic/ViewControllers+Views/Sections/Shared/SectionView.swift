/*
 Abstract:
 Base view for all Section Views (NumberPad, What's On, Tours, Nearby and Info)
*/

import UIKit

class SectionView: BaseView {
    var didSetupBaseConstraints = false
    
    let titleScrolledTopMargin = 25
    
    var titleView:SectionTitleView
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
            self.titleView.setNeedsLayout()
            self.titleView.layoutIfNeeded()
            
            let height = self.titleView.frame.height
            self.scrollView.contentOffset.y = scrollOffsetY
            
            return height
        }
    }
    
    init(section:AICSectionModel) {
        // Create title and tab bar item
        titleView = SectionTitleView(icon: section.icon,
                                         title: section.title,
                                         description: section.description,
                                         backgroundColor:section.color
        )
        
        super.init(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeight))
        
        
        // Clear background so the map shows through
        backgroundColor = .clear
        
        // All section views have a scroll view with a title view
        scrollViewContentView.addSubview(titleView)
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
            
            titleView.snp.makeConstraints({ (make) -> Void in
                make.top.lessThanOrEqualTo(self).priority(Common.Layout.Priority.high.rawValue)
                make.top.equalTo(titleView.superview!).priority(Common.Layout.Priority.medium.rawValue)
                make.left.right.equalTo(titleView.superview!)
            })
            
            titleView.titleLabel.snp.makeConstraints({ (make) -> Void in
                make.top.greaterThanOrEqualTo(self).offset(titleScrolledTopMargin).priority(Common.Layout.Priority.high.rawValue)
            })
            
            didSetupBaseConstraints = true
        }
        
        super.updateConstraints()
    }
}
