/*
 Abstract:
 Shared view controller for What's On (News) + Tours Sections
 These sections are very similar so should be able to implement this with little
 change
*/

import UIKit

class NewsToursSectionView: SectionView {
    enum Mode {
        case list
        case reveal
    }
    
    var mode:Mode = .list  {
        didSet {
            updateLayoutForCurrentMode()
        }
    }
    
    // Track whether we need to animate in the reveal or not
    var revealShown = false
    
    // Init list view with width or it complains, probably could be figured out in constraints
    // but easier this way
    let listView = UITableView(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: 300))
    let revealView:NewsToursRevealView
    
    var titleViewStartHeight:CGFloat? = nil
    
    init(section:AICSectionModel, revealView:NewsToursRevealView) {
        self.mode = .list
        self.revealView = revealView
        super.init(section:section)
        
        // Configure table view
        listView.rowHeight = UITableViewAutomaticDimension // Necessary for AutoLayout of cells
        listView.estimatedRowHeight = 100// set to whatever your "average" cell height is
        listView.isScrollEnabled = false
        listView.separatorInset = UIEdgeInsets.zero
        
        // Add Subviews
        scrollViewContentView.insertSubview(listView, belowSubview: titleView)
        
        //addSubview(revealView)
        
        updateLayoutForCurrentMode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayoutForCurrentMode() {
        switch mode {
        case .list:
            revealView.removeFromSuperview()
            scrollView.isHidden = false
            break
            
        case .reveal:
            scrollView.isHidden = true
            addSubview(revealView)
            break
        }
        
        self.updateConstraints()
    }
    
    func setReveal(forModel model:AICNewsTourItemProtocol) {
        revealView.setContent(forModel: model)
    }
    
    override func updateConstraints() {
        
        // Recalculate the height
        var totalHeight:CGFloat = 0
        for i in 0..<listView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: i, section: 0)
            totalHeight += listView.rectForRow(at: indexPath).size.height
        }
        
        listView.snp.remakeConstraints({ (make) -> Void in
            make.left.right.equalTo(listView.superview!)
            make.top.lessThanOrEqualTo(titleView.snp.bottom).priority(Common.Layout.Priority.high.rawValue)
            make.top.equalTo(scrollViewContentView).offset(titleViewHeight).priority(Common.Layout.Priority.low.rawValue)
            
            make.height.equalTo(totalHeight).priority(Common.Layout.Priority.high.rawValue)
            make.bottom.equalTo(listView.superview!)
                //.priority(Common.Layout.Priority.low.rawValue)
        })
        
        if mode == .reveal {
            revealView.snp.remakeConstraints { (make) -> Void in
                make.left.right.equalTo(revealView.superview!)
            }
            
            if revealShown == false {
                revealView.snp.makeConstraints({ (make) -> Void in
                    make.top.equalTo(self.snp.bottom)
                })
                
                layoutIfNeeded()
                revealShown = true
            }
            
            revealView.setNeedsLayout()
            revealView.layoutIfNeeded()
            revealView.snp.remakeConstraints { (make) -> Void in
                make.left.right.equalTo(revealView.superview!)
                make.top.equalTo(self.snp.bottom).offset(-revealView.frame.height)
            }
            
            UIView.animate(withDuration: 0.35, animations: {
                self.layoutIfNeeded()
            })
        }
        
        else {
            revealShown = false
            revealView.snp.removeConstraints()
        }
        
        super.updateConstraints()
    }
}
