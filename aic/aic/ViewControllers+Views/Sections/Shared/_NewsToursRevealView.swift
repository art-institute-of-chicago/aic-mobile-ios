/*
 Abstract:
 View that appears on top of map, this base view only shows the title of the Model it is presenting on the map.
 Override for more functionality, see ToursSectionStopScrollverView for an example
*/

import UIKit

class NewsToursRevealView: BaseView {
    let titleContentInsets = UIEdgeInsetsMake(10, 30, 10, 20)
    
    let titleContentView = UIView()
    let titleLabel = UILabel()
    
    let closeButton = UIButton(type: UIButtonType.custom)
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = .white
        
        // Configure
		
        closeButton.setImage(#imageLiteral(resourceName: "iconClose").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        closeButton.tintColor = .black
        closeButton.frame.size = closeButton.currentImage!.size
        
        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - titleContentInsets.left - titleContentInsets.right - closeButton.bounds.width
        titleLabel.font = UIFont.aicTitleFont
        titleLabel.textColor = .black
        
        // Add Subviews
        titleContentView.addSubview(titleLabel)
        titleContentView.addSubview(closeButton)
        
        addSubview(titleContentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(forModel model:AICTourModel) {
        titleLabel.text = model.title.stringByDecodingHTMLEntities
    }
    
    override func updateConstraints() {
        titleContentView.snp.remakeConstraints { (make) -> Void in
            make.top.bottom.equalTo(titleContentView.superview!).inset(titleContentInsets).priority(Common.Layout.Priority.low.rawValue)
            make.left.right.equalTo(titleContentView.superview!)
        }
        
        titleLabel.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.superview!)
            make.left.equalTo(titleLabel.superview!).offset(titleContentInsets.left)
            make.right.equalTo(closeButton.snp.left).priority(Common.Layout.Priority.low.rawValue)
            make.bottom.equalTo(titleLabel.superview!).priority(Common.Layout.Priority.low.rawValue)
            make.height.greaterThanOrEqualTo(1)
        }
        
        closeButton.snp.remakeConstraints({ (make) -> Void in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(closeButton.superview!).inset(titleContentInsets.right)
        })
        
        super.updateConstraints()
    }

}
