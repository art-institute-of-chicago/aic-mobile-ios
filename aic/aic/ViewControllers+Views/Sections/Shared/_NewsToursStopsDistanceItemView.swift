/*
 Abstract:
 Represents one item in the inset view on an NewsToursItemViewCell header image.
 Currently represented by Number of Stops and Distance but could be anythin.
*/

import UIKit

class NewsToursStopsDistanceItemView: BaseView {
    let textLabelPaddingLeft = 5
    
    let contentView = UIView()
    let iconImageView = UIImageView()
    let textLabel = UILabel()
    
    var value:String = "" {
        didSet {
            textLabel.text = value
        }
    }
    
    init(icon: UIImage) {
        super.init(frame:CGRect.zero)
        
        // Configure
        iconImageView.image = icon
        iconImageView.sizeToFit()
        
        textLabel.numberOfLines = 1
        textLabel.font = .aicSystemTextFont
        textLabel.textColor = .white
        textLabel.sizeToFit()
        
        // Add Subviews
        contentView.addSubview(iconImageView)
        contentView.addSubview(textLabel)
        
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        self.contentView.snp.remakeConstraints({ (make) -> Void in
            make.top.left.right.equalTo(contentView.superview!)
            make.bottom.equalTo(contentView.superview!)
        })
        
        self.iconImageView.snp.remakeConstraints({ (make) -> Void in
            make.top.left.equalTo(iconImageView.superview!)
            make.bottom.equalTo(iconImageView.superview!)
        })
        
        self.textLabel.snp.remakeConstraints({ (make) -> Void in
            make.centerY.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(textLabelPaddingLeft)
            make.right.equalTo(textLabel.superview!).priority(Common.Layout.Priority.low.rawValue)
            make.height.equalTo(1).priority(Common.Layout.Priority.low.rawValue)
        })
        
        super.updateConstraints()
    }
}
