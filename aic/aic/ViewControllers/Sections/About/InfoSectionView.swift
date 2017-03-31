/*
 Abstract:
 Section view for Info section
*/

import UIKit
import Foundation

class InfoSectionView: SectionView {
    
    let becomeMemberView = InfoSectionBecomeMemberView()
    let informationView = InfoSectionInformationView()
    
    let memberCardView:InfoSectionMemberCardView
    
    var showMemberCardView = false
    
    init(section:AICSectionModel, memberCardView:InfoSectionMemberCardView) {
        self.memberCardView = memberCardView
        
        super.init(section:section)
        
        scrollView.backgroundColor = UIColor.aicInfoColor().withAlphaComponent(0.9)
        
        // Add subviews
        
            // Member card view disabled by default
            showMemberCardView = false
        
        if (Common.Testing.printDataErrors) {
            print("Member card view disabled by default")
        }
        
        if showMemberCardView {
            scrollViewContentView.insertSubview(becomeMemberView, belowSubview: titleView)
        }
        
        scrollViewContentView.insertSubview(informationView, belowSubview: titleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            scrollViewContentView.snp.makeConstraints({ (make) in
                make.bottom.equalTo(informationView)
            })
            
            if showMemberCardView {
                becomeMemberView.snp.makeConstraints({ (make) in
                    make.top.lessThanOrEqualTo(titleView.snp.bottom).priority(Common.Layout.Priority.high.rawValue)
                    make.top.equalTo(scrollViewContentView).offset(titleViewHeight)
                    make.left.right.equalTo(becomeMemberView.superview!)
                })
            }
            
            informationView.snp.makeConstraints({ (make) in
                if showMemberCardView {
                    make.top.equalTo(becomeMemberView.snp.bottom)
                } else {
                    make.top.lessThanOrEqualTo(titleView.snp.bottom).priority(Common.Layout.Priority.high.rawValue)
                    make.top.equalTo(scrollViewContentView).offset(titleViewHeight)
                }
                make.left.right.equalTo(informationView.superview!)
            })
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
