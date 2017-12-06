/*
 Abstract:
 Title view with icon + description for each section
*/

import UIKit

class SectionTitleView: BaseView {
    // This is a bit of a magic number, need to find way to calculate it
    let minimizedHeight:CGFloat = 73
    
    private let margins = UIEdgeInsetsMake(40, 30, 30, 30)
    
    private let titleHeight = 40
    private let titleTopMargin = 55
    private let titleBottomMargin = 10
    private let descriptionTopMargin = 65
    
    private let backgroundColorAlpha = 0.8
    
    let contentView:UIView = UIView()
    let iconImage:UIImageView = UIImageView()
    let titleLabel:UILabel = UILabel()
    let descriptionLabel:UILabel = UILabel()
    
    internal let titleString:String
    
    init(icon:UIImage, title:String, description:String, backgroundColor:UIColor) {
        
        self.titleString = title
        
        super.init(frame: CGRect.zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = backgroundColor.withAlphaComponent(0.8)
        
        self.iconImage.image = icon
        
        let preferredLabelWidth = UIScreen.main.bounds.width - margins.right - margins.left
        
        titleLabel.numberOfLines = 0
        titleLabel.font = .aicSectionTitleFont
        titleLabel.textColor = .white
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = title
        titleLabel.preferredMaxLayoutWidth = preferredLabelWidth
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .aicSystemTextFont
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = NSTextAlignment.center
        descriptionLabel.text = description
        descriptionLabel.preferredMaxLayoutWidth = preferredLabelWidth
        descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        // Add Subviews
        contentView.addSubview(iconImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        addSubview(contentView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if(!didSetupConstraints) {
            contentView.snp.makeConstraints({ (make) -> Void in
                make.top.right.left.equalTo(contentView.superview!).inset(margins)
                make.bottom.greaterThanOrEqualTo(titleLabel).offset(titleBottomMargin).priority(Common.Layout.Priority.high.rawValue)
                make.bottom.equalTo(contentView.superview!)
            })
            
            iconImage.snp.makeConstraints({ (make) -> Void in
                make.centerX.equalTo(iconImage.superview!)
                make.top.equalTo(iconImage.superview!).priority(Common.Layout.Priority.high.rawValue)
                make.height.equalTo(iconImage.image!.size.height)
            })
            
            titleLabel.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(titleLabel.superview!).offset(titleTopMargin).priority(Common.Layout.Priority.low.rawValue)
                make.left.right.equalTo(titleLabel.superview!)
            })
            
            descriptionLabel.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(iconImage.snp.bottom).offset(descriptionTopMargin)
                make.left.right.equalTo(descriptionLabel.superview!)
                
                make.height.equalTo(descriptionLabel.sizeThatFits(CGSize(width: descriptionLabel.preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude)))
                make.bottom.equalTo(descriptionLabel.superview!).offset(-margins.bottom).priority(Common.Layout.Priority.low.rawValue)
            })
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}
