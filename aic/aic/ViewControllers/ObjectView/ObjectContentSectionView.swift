/*
 Abstract:
 Base Class for information views under the Object View audio player + image
*/

import UIKit
import SnapKit

class ObjectContentSectionView: BaseView {
    private let margins = UIEdgeInsetsMake(15, 20, 15, 20)
    private let bodyTextMarginTop = 10.0
    fileprivate let collapseAnimationDuration = 0.5
    private let collapseButtonSize:CGFloat = 50
    private let topLineHeight = 1.0
    
    internal let contentView = UIView()
    internal let topLine = UIView()
    internal let titleLabel = UILabel()
    internal let bodyTextView = UITextView()
    
    internal var collapseExpandButton:UIButton? = nil
    
    fileprivate var isOpen:Bool = false
    
    init() {
        super.init(frame:CGRect(x: 0, y: 0, width: 0,height: 0))
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure
        topLine.backgroundColor = UIColor.aicGrayColor()
        
        titleLabel.numberOfLines = 1
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.aicTitleFont()
        
        bodyTextView.textColor = UIColor.black
        bodyTextView.font = UIFont.aicTextFont()
        bodyTextView.setDefaultsForAICAttributedTextView()
        
        // Add Subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyTextView)
        
        addSubview(topLine)
        addSubview(contentView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enableCollapsing() {
        
        // Remove body text (start collapsed)
        bodyTextView.removeFromSuperview()
        
        // Create button
        let expandImage = UIImage(named: "expandSm")
        
        collapseExpandButton = UIButton()
        collapseExpandButton?.setImage(expandImage, for: UIControlState())
        
        // Add Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ObjectContentSectionView.collapseButtonTapped(_:)))
        collapseExpandButton?.addGestureRecognizer(tapGesture)
        //titleLabel.addGestureRecognizer(tapGesture)
        
        // Add subview
        contentView.addSubview(collapseExpandButton!)
        
        updateConstraints()
    }
    
    override func updateConstraints() {
        topLine.snp.remakeConstraints({ (make) -> Void in
            make.top.equalTo(self)
            make.left.right.equalTo(contentView)
            make.height.equalTo(topLineHeight)
        })
        
        contentView.snp.remakeConstraints { (make) -> Void in
            make.top.left.right.equalTo(contentView.superview!).inset(margins)
            make.bottom.equalTo(contentView.superview!).inset(margins.bottom)
        }
        
        titleLabel.snp.remakeConstraints { (make) -> Void in
            make.top.left.equalTo(titleLabel.superview!)
            if collapseExpandButton != nil {
                make.right.equalTo(collapseExpandButton!.snp.left)
            } else {
                make.right.equalTo(titleLabel.superview!)
            }
        }
        
        if collapseExpandButton != nil {
            collapseExpandButton!.snp.makeConstraints({ (make) in
                make.centerY.equalTo(titleLabel)
                make.right.equalTo((collapseExpandButton?.superview!)!)
                make.width.height.equalTo(collapseButtonSize)
            })
        }

        if bodyTextView.superview != nil {
            bodyTextView.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(titleLabel.snp.bottom).offset(bodyTextMarginTop)
                make.left.right.equalTo(bodyTextView.superview!)
                make.bottom.equalTo(bodyTextView.superview!)
            }
        } else {
            titleLabel.snp.makeConstraints({ (make) in
                make.bottom.equalTo(titleLabel.superview!)
            })
        }
        
        super.updateConstraints()
    }
}

// Gesture Handlers
extension ObjectContentSectionView {
    internal func collapseButtonTapped(_ gesture:UIGestureRecognizer) {
        var rotation:CGFloat = CGFloat(-M_PI * 2.0)
        
        if isOpen {
            bodyTextView.removeFromSuperview()
        } else {
            contentView.addSubview(bodyTextView)
            rotation = CGFloat(M_PI)
        }
        
        // Set Button Rotation
        UIView.animate(withDuration: collapseAnimationDuration, animations: {
            self.collapseExpandButton?.transform = CGAffineTransform(rotationAngle: rotation);
        }) 
        
        isOpen = !isOpen
        
        self.updateConstraints()
        self.bodyTextView.layoutIfNeeded()
    }
}
