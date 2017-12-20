/*
 Abstract:
 Prompt to become a member or log in
 */

import UIKit

class InfoSectionBecomeMemberView: BaseView {
    
    let contentMargins = UIEdgeInsetsMake(30, 25, 25, 25)
    
    let supportMarginTop:CGFloat = 15
    let joinMessageMarginTop = 5
    let accessPromptMarginTop:CGFloat = 20
    let accessButtonMarginTop:CGFloat = 20
    
    let contentView = UIView()
    
    let titleLabel = UILabel()
    let supportMessageLabel = UILabel()
    let joinTextView = LinkedTextView()
    let accessPromptLabel = UILabel()
    let accessButton = AICButton()
    
    var savedMember: AICMemberInfoModel? {
        didSet{
            //Configure view appropriately if a member signs in
            if savedMember != nil{
                titleLabel.text = Common.Info.becomeMemberExistingMemberTitle
                
                if supportMessageLabel.superview != nil {
                    supportMessageLabel.removeFromSuperview()
                }
                if joinTextView.superview != nil {
                    joinTextView.removeFromSuperview()
                }
                if accessPromptLabel.superview != nil {
                    accessPromptLabel.removeFromSuperview()
                }
            }else if supportMessageLabel.superview == nil && joinTextView.superview == nil && accessPromptLabel.superview == nil{
                titleLabel.text = Common.Info.becomeMemberTitle
                contentView.addSubview(supportMessageLabel)
                contentView.addSubview(joinTextView)
                contentView.addSubview(accessPromptLabel)
            }
        }
    }
    
    init() {
        super.init(frame:CGRect.zero)
        
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        if savedMember == nil {
            //Prompt user to become a member
            titleLabel.text = Common.Info.becomeMemberTitle
        }else{
            //Welcome back existing members
            titleLabel.text = Common.Info.becomeMemberExistingMemberTitle
        }
        titleLabel.font = UIFont.aicTitleFont()
        titleLabel.textAlignment = NSTextAlignment.center
        
        supportMessageLabel.numberOfLines = 0
        supportMessageLabel.text = Common.Info.becomeMemberSupportMessage
        supportMessageLabel.font = UIFont.aicShortTextFont()
        supportMessageLabel.textAlignment = NSTextAlignment.center
        
        let joinAttrText = NSMutableAttributedString(string: Common.Info.becomeMemberJoinMessage)
        let joinURL = URL(string: Common.Info.becomeMemberJoinURL)!
        joinAttrText.addAttributes([NSLinkAttributeName : joinURL], range: NSMakeRange(0, joinAttrText.string.characters.count))
        
        joinTextView.setDefaultsForAICAttributedTextView()
        joinTextView.attributedText = joinAttrText
        joinTextView.textAlignment = NSTextAlignment.center
        joinTextView.font = UIFont.aicTextFont()
        
        accessPromptLabel.text = Common.Info.becomeMemberAccessPrompt
        accessPromptLabel.font = UIFont.aicShortTextFont()
        accessPromptLabel.textAlignment = NSTextAlignment.center
        
        accessButton.setTitle(Common.Info.becomeMemberAccessButtonTitle, for: UIControlState())
        
        // Add Subviews
        contentView.addSubview(titleLabel)
        
        //Only show join prompts if no member has been saved
        if savedMember == nil{
            contentView.addSubview(supportMessageLabel)
            contentView.addSubview(joinTextView)
            contentView.addSubview(accessPromptLabel)
        }
        
        contentView.addSubview(accessButton)
        
        addSubview(contentView)
        
        // Set Delegates
        joinTextView.delegate = self
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
            contentView.snp.remakeConstraints({ (make) in
                make.edges.equalTo(contentView.superview!).inset(contentMargins).priority(Common.Layout.Priority.high.rawValue)
            })
            
            titleLabel.snp.remakeConstraints({ (make) in
                make.top.left.right.equalTo(titleLabel.superview!)
            })
            
            //Only setup constraints if a member has not been saved
            if savedMember == nil {
                
                supportMessageLabel.snp.remakeConstraints({ (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(supportMarginTop)
                    make.left.right.equalTo(supportMessageLabel.superview!)
                })
                
                joinTextView.snp.remakeConstraints({ (make) in
                    make.top.equalTo(supportMessageLabel.snp.bottom).offset(joinMessageMarginTop)
                    make.left.right.equalTo(joinTextView.superview!)
                })
                
                accessPromptLabel.snp.remakeConstraints({ (make) in
                    make.top.equalTo(joinTextView.snp.bottom).offset(accessPromptMarginTop)
                    make.left.right.equalTo(accessPromptLabel.superview!)
                })
                
                accessButton.snp.remakeConstraints({ (make) in
                    make.top.equalTo(accessPromptLabel.snp.bottom).offset(accessButtonMarginTop)
                    make.left.right.bottom.equalTo(accessButton.superview!)
                })
                
            } else {
                accessButton.snp.remakeConstraints({ (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(accessButtonMarginTop)
                    make.left.right.bottom.equalTo(accessButton.superview!)
                })
            }
        
        super.updateConstraints()
    }
    
}


// Observe links for passing analytics
extension InfoSectionBecomeMemberView  : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        // Log Analytics
        AICAnalytics.infoJoinPressedEvent()
        
        return true
    }
}
