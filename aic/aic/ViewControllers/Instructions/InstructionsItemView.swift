/*
 Abstract:
 View for individual Instructions screen
*/
import UIKit

class InstructionsItemView: UIView {
    
    let iconMarginTop = 145
    
    let titleMargins = UIEdgeInsetsMake(32, 45, 0, 45)
    let subtitleMargins = UIEdgeInsetsMake(15, 45, 0, 45)

    let iconImage = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    let contentView = UIView()
    
    init() {
        super.init(frame:UIScreen.main.bounds)
        
        // Configure
        backgroundColor = UIColor.clear
        
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.aicInstructionsTitleFont()
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.preferredMaxLayoutWidth = 300
        
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = UIFont.aicInstructionsSubtitleFont()
        subtitleLabel.textAlignment = NSTextAlignment.center
        subtitleLabel.textColor = UIColor.white
        
        // Add Subviews
        contentView.addSubview(iconImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView.superview!)
        }
        
        iconImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(iconImage.superview!)
            make.top.equalTo(iconImage.superview!).offset(iconMarginTop)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImage.snp.bottom).offset(titleMargins.top)
            make.left.right.equalTo(titleLabel.superview!).inset(titleMargins)
            make.height.greaterThanOrEqualTo(1)
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(subtitleMargins.top)
            make.left.right.equalTo(titleLabel.superview!).inset(subtitleMargins)
        }
        
        super.updateConstraints()
    }
}
