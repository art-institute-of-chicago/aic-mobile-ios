/*
 Abstract:
 Section view for Info section
*/

import UIKit
import Foundation

class InfoSectionView: SectionView {
    
    let becomeMemberView = InfoBecomeMemberView()
    let informationView = InfoSectionInformationView()
    
    let memberCardView:InfoSectionMemberCardView
    
    var showMemberCardView = true
    
    init(section:AICSectionModel, memberCardView:InfoSectionMemberCardView) {
        self.memberCardView = memberCardView
        
        super.init(section:section)
        
        scrollView.backgroundColor = UIColor.aicInfoColor.withAlphaComponent(0.9)
        
        // Add subviews
        
            // Member card view disabled by default
            showMemberCardView = true
        
        if (Common.Testing.printDataErrors) {
            print("Member card view disabled by default")
        }
        
        if showMemberCardView {
            scrollViewContentView.addSubview(becomeMemberView)
        }
        
        scrollViewContentView.addSubview(informationView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            scrollViewContentView.snp.makeConstraints({ (make) -> Void in
                make.bottom.equalTo(informationView)
            })
            
            if showMemberCardView {
                becomeMemberView.snp.makeConstraints({ (make) -> Void in
                    make.top.equalTo(scrollViewContentView).offset(titleViewHeight)
                    make.left.right.equalTo(becomeMemberView.superview!)
                })
            }
            
            informationView.snp.makeConstraints({ (make) -> Void in
                if showMemberCardView {
                    make.top.equalTo(becomeMemberView.snp.bottom)
                } else {
                    
                    make.top.equalTo(scrollViewContentView).offset(titleViewHeight)
                }
                make.left.right.equalTo(informationView.superview!)
            })
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
