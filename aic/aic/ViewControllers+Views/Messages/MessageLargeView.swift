/*
 Abstract:
 Fullscreen message for things like location and headphones
 */

import UIKit

class MessageLargeView: BaseView {
    weak var delegate:MessageViewDelegate? = nil
    
    let contentViewMarginTopRatio:CGFloat = 0.187
    let contentViewMargins = UIEdgeInsetsMake(125, 60, 0, 60)
    let buttonsViewMargins = UIEdgeInsetsMake(25, 25, 0, 25)
    
    let titleLabelMarginTop = 15
    let messageLabelMarginTop = 15
    let cancelButtonMarginTop = 15
    
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    
    let actionButton = MessageLargeButton()
    var cancelButton:MessageLargeButton? = nil
    
    let contentView = UIView()
    let buttonsView = UIView()
    
    init(model:AICMessageLargeModel) {
        super.init(frame: UIScreen.main.bounds)
        
        // Configure
        backgroundColor = model.backgroundColor
        
        iconImageView.image = model.iconImage
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.aicInstructionsTitleFont()
        titleLabel.text = model.title
        
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.textColor = .white
        messageLabel.font = UIFont.aicInstructionsSubtitleFont()
        messageLabel.text = model.message
        
        actionButton.layer.borderWidth = 1
        actionButton.setTitle(model.actionButtonTitle, for: UIControlState())
        actionButton.titleLabel?.font = UIFont.aicTitleFont
        
        if let cancelButtonTitle = model.cancelButtonTitle {
            let cancelButton = MessageLargeButton()
            
            cancelButton.titleLabel?.font = UIFont.aicTitleFont
            cancelButton.setTitle(cancelButtonTitle, for: UIControlState())
            
            self.cancelButton = cancelButton
        }
        
        // Add Subviews
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        
        buttonsView.addSubview(actionButton)
        if let cancelButton = cancelButton {
            buttonsView.addSubview(cancelButton)
        }
        
        addSubview(contentView)
        addSubview(buttonsView)
        
        // Add Gestures
        let actionTapGesture = UITapGestureRecognizer(target: self, action: #selector(MessageSmallView.actionButtonTapped))
        actionButton.addGestureRecognizer(actionTapGesture)
        
        if let cancelButton = cancelButton {
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
            contentView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(contentView.superview!).offset(UIScreen.main.bounds.height * contentViewMarginTopRatio)
                make.left.right.equalTo(contentView.superview!).inset(contentViewMargins)
            })
            
            iconImageView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(iconImageView.superview!)
                make.centerX.equalTo(iconImageView.superview!)
            })
            
            titleLabel.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(iconImageView.snp.bottom).offset(titleLabelMarginTop)
                make.left.right.equalTo(titleLabel.superview!)
            })
            
            messageLabel.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(titleLabel.snp.bottom).offset(messageLabelMarginTop)
                make.left.right.bottom.equalTo(messageLabel.superview!)
            })
            
            buttonsView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(contentView.snp.bottom).inset(buttonsViewMargins).offset(buttonsViewMargins.top)
                make.left.right.equalTo(buttonsView.superview!).inset(buttonsViewMargins)
            })
            
            actionButton.snp.makeConstraints({ (make) -> Void in
                make.top.left.right.equalTo(actionButton.superview!)
                make.bottom.equalTo(actionButton.superview!).priority(Common.Layout.Priority.low.rawValue)
            })

            if let cancelButton = cancelButton {
                cancelButton.snp.makeConstraints({ (make) -> Void in
                    make.top.equalTo(actionButton.snp.bottom).offset(cancelButtonMarginTop)
                    make.left.right.equalTo(cancelButton.superview!)
                    make.bottom.equalTo(cancelButton.superview!)
                })
            }
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}


// MARK: Gesture Recognizers
extension MessageLargeView {
    func actionButtonTapped() {
        delegate?.messageViewActionSelected(self)
    }
    
    func cancelButtonTapped() {
        delegate?.messageViewCancelSelected?(self)
    }
}
