/*
 Abstract:
 Small message with blurred background
 for things like not on site messages
 */

import UIKit


class MessageSmallView: BaseView {
    weak var delegate:MessageViewDelegate?
    
    let contentMargins = UIEdgeInsetsMake(50, 30, 30, 30)
    let messageLabelMarginTop = 30
    let actionButtonMarginTop = 30
    let cancelButtonMarginTop = 20
    
    let blurBGView:UIView = getBlurEffectView(frame: UIScreen.main.bounds)
    let blurBGHolderView = UIView()
    
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    let actionButton = AICButton()
    var cancelButton:UIButton? = nil
    let contentBackgroundView = UIView()
    let contentView  = UIView()
    
    init(model:AICMessageSmallModel) {
        super.init(frame: UIScreen.main.bounds)
        
        // Configure
        blurBGHolderView.alpha = 0.95
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.aicTitleFont
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = model.title
        
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.aicShortTextFont()
        messageLabel.textColor = UIColor.black
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.text = model.message
        
        actionButton.setTitle(model.actionButtonTitle, for: UIControlState())
        
        if model.cancelButtonTitle != nil {
            cancelButton = UIButton()
            cancelButton!.setTitleColor(UIColor.aicButtonsColor(), for: UIControlState())
            cancelButton!.setTitleColor(UIColor.aicButtonsColor().darker(), for: UIControlState.highlighted)
            cancelButton!.titleLabel?.font = UIFont.aicTitleFont
            cancelButton!.setTitle(model.cancelButtonTitle, for: UIControlState())
        }
        
        contentBackgroundView.backgroundColor = UIColor.white
        
        // Add Subviews
        blurBGHolderView.addSubview(blurBGView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(actionButton)
        
        if let cancelButton = self.cancelButton {
            contentView.addSubview(cancelButton)
        }
        
        contentBackgroundView.addSubview(contentView)
        
        addSubview(blurBGHolderView)
        addSubview(contentBackgroundView)
        
        // Add Gestures
        let actionTapGesture = UITapGestureRecognizer(target: self, action: #selector(MessageSmallView.actionButtonTapped))
        actionButton.addGestureRecognizer(actionTapGesture)
        
        if let cancelButton = self.cancelButton {
            let cancelTapGesture = UITapGestureRecognizer(target: self, action: #selector(MessageSmallView.cancelButtonTapped))
            cancelButton.addGestureRecognizer(cancelTapGesture)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        updateConstraints()
        
        alpha = 0.0
        
        UIView.animate(withDuration: Common.Messages.fadeInAnimationDuration, animations: {
            self.alpha = 1.0
        }) 
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            contentBackgroundView.snp.makeConstraints { (make) in
                make.left.right.equalTo(contentBackgroundView.superview!)
                make.centerY.equalTo(contentBackgroundView.superview!)
            }
            
            contentView.snp.makeConstraints { (make) in
                make.edges.equalTo(contentView.superview!).inset(contentMargins)
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.left.right.equalTo(titleLabel.superview!)
            }
            
            messageLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(messageLabelMarginTop)
                make.left.right.equalTo(messageLabel.superview!)
            }
            
            actionButton.snp.makeConstraints { (make) in
                make.top.equalTo(messageLabel.snp.bottom).offset(actionButtonMarginTop)
                make.left.right.equalTo(actionButton.superview!)
                
                if cancelButton == nil {
                    make.bottom.equalTo(actionButton.superview!)
                }
            }
            
            if let cancelButton = self.cancelButton {
                cancelButton.snp.makeConstraints { (make) in
                    make.top.equalTo(actionButton.snp.bottom).offset(cancelButtonMarginTop)
                    make.left.right.equalTo(cancelButton.superview!)
                    make.bottom.equalTo(cancelButton.superview!)
                }
            }
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }

}

// MARK: Gesture Recognizers
extension MessageSmallView {
    func actionButtonTapped() {
        delegate?.messageViewActionSelected(self)
    }
    
    func cancelButtonTapped() {
        delegate?.messageViewCancelSelected?(self)
    }
}
