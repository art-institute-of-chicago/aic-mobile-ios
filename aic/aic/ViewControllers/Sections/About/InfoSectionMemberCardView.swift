/*
 Abstract:
 View for Member card login + display
 */


import UIKit

class InfoSectionMemberCardView: BaseView {
    // Layout
    let sideMargin:CGFloat = 25
    
    let titleLabelMarginTop = 25
    let contentMarginTop = 5
    
    let inputInfoDetailTopMargin = 25
    let inputInfoDetailInsets:UIEdgeInsets
    
    let inputTextFieldTopMargin = 10
    let memberZipCodeTitleMarginTop = 30
    
    let signInUpdateButtonTopMargin = 10
    
    let switchMemberCardHolderButtonTopMargin = 10
    
    let barcodeReciprocalLabelFieldsInset = 40
    let barcodeReciprocalBadgeInset = 10
    
    var currentBackgroundImageIndex = 0
    
    // Views
    let contentView = UIView()
    let backgroundImageViewFront = UIImageView()
    let backgroundImageViewBack = UIImageView()
    
    let titleLabel = UILabel()
    let closeButton = UIButton()
    
    let loadingIndicator = UIActivityIndicatorView()
    
    // Input View
    let memberInputBarcodeView = UIView()
    
    let memberInputContentView = UIView()
    let memberIDTitleLabel = UILabel()
    let memberIDTextField = InfoSectionTextField()
    let memberZipCodeTitleLabel = UILabel()
    let memberZipCodeTextField = InfoSectionTextField()
    
    // Barcode View
    let barcodeContentView = UIView()
    let barcodeMemberName = UILabel()
    let barcodeMemberLevel = UILabel()
    let barcodeExpirationDate = UILabel()
    let barcodeImageView = UIImageView()
    let barcodeReciprocalBadgeImageView = UIImageView()
    
    var isReciprocalMember = false {
        didSet{
            barcodeReciprocalBadgeImageView.isHidden = !isReciprocalMember
        }
    }
    
    let signInUpdateButton = AICButton()
    
    let switchMemberCardHolderButton = AICButton()
    
    init() {
        inputInfoDetailInsets = UIEdgeInsetsMake(25, sideMargin, 40, sideMargin)
        
        super.init(frame:CGRect.zero)
        //translatesAutoresizingMaskIntoConstraints = false
        
        
        // Configure
        backgroundColor = UIColor.aicInfoColor()
        
        contentView.backgroundColor = UIColor.darkGray
        
        backgroundImageViewBack.image = Common.Info.memberCardImages[currentBackgroundImageIndex]
        
        titleLabel.text = Common.Info.memberCardTitle
        titleLabel.font = UIFont.aicHeaderSmallFont()
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = NSTextAlignment.center
        
        closeButton.setImage(UIImage(named:"iconClose"), for: UIControlState())
        
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        loadingIndicator.color = UIColor.darkGray
        
        barcodeContentView.isHidden = true
        
        memberInputBarcodeView.backgroundColor = UIColor.white
        
        memberIDTitleLabel.text = Common.Info.memberIDTitle
        memberIDTitleLabel.font = UIFont.aicTitleFont
        
        memberIDTextField.placeholder = Common.Info.memberIDPlaceholder
        memberIDTextField.backgroundColor = UIColor.aicGrayColor()
        memberIDTextField.font = UIFont.aicTextFont()
        memberIDTextField.keyboardType = UIKeyboardType.numberPad
        
        memberZipCodeTitleLabel.text = Common.Info.memberZipTitle
        memberZipCodeTitleLabel.font = UIFont.aicTitleFont
        
        memberZipCodeTextField.placeholder = Common.Info.memberZipPlaceholder
        memberZipCodeTextField.backgroundColor = UIColor.aicGrayColor()
        memberZipCodeTextField.font = UIFont.aicTextFont()
        memberZipCodeTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        
        barcodeMemberName.font = UIFont.aicTitleFont
        barcodeMemberLevel.font = UIFont.aicTextFont()
        barcodeExpirationDate.font = UIFont.aicTextFont()
        
        barcodeReciprocalBadgeImageView.contentMode = .scaleAspectFill
        barcodeReciprocalBadgeImageView.image = #imageLiteral(resourceName: "reciprocal_logo")
        
        signInUpdateButton.setTitle(Common.Info.memberSignInTitle, for: UIControlState())
        
        switchMemberCardHolderButton.setTitle(Common.Info.memberSwitchCardHolder, for: UIControlState())
        
        // Add Subviews
        memberInputContentView.addSubview(memberIDTitleLabel)
        memberInputContentView.addSubview(memberIDTextField)
        memberInputContentView.addSubview(memberZipCodeTitleLabel)
        memberInputContentView.addSubview(memberZipCodeTextField)
        
        memberInputBarcodeView.addSubview(memberInputContentView)
        
        barcodeContentView.addSubview(barcodeMemberName)
        barcodeContentView.addSubview(barcodeMemberLevel)
        barcodeContentView.addSubview(barcodeExpirationDate)
        barcodeContentView.addSubview(barcodeImageView)
        barcodeContentView.addSubview(barcodeReciprocalBadgeImageView)
        
        memberInputBarcodeView.addSubview(barcodeContentView)
        memberInputBarcodeView.addSubview(loadingIndicator)
        
        contentView.addSubview(backgroundImageViewBack)
        contentView.addSubview(backgroundImageViewFront)
        contentView.addSubview(memberInputBarcodeView)
        contentView.addSubview(signInUpdateButton)
        contentView.addSubview(switchMemberCardHolderButton)
        
        addSubview(titleLabel)
        addSubview(closeButton)
        
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        setNeedsUpdateConstraints()
    }
    
    override func didMoveToSuperview() {
        animateBackground()
    }
    
    override func updateConstraints() {
        snp.remakeConstraints({ (make) in
            make.top.equalTo(superview!)
            make.left.right.bottom.equalTo(superview!).priority(Common.Layout.Priority.required.rawValue)
        })
        
        titleLabel.snp.remakeConstraints({ (make) in
            make.top.equalTo(titleLabel.superview!).offset(titleLabelMarginTop)
            make.centerX.equalTo(titleLabel.superview!).priority(Common.Layout.Priority.high.rawValue)
        })
        
        closeButton.snp.remakeConstraints({ (make) in
            make.right.equalTo(closeButton.superview!)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(CGSize(width: 44,height: 44))
        })
        
        contentView.snp.remakeConstraints({ (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(contentMarginTop)
            make.left.right.bottom.equalTo(contentView.superview!)
        })
        
        backgroundImageViewFront.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(backgroundImageViewFront.superview!)
        }
        
        backgroundImageViewBack.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(backgroundImageViewBack.superview!)
        }
        
        memberInputBarcodeView.snp.remakeConstraints({ (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(inputInfoDetailTopMargin)
            make.left.right.equalTo(memberInputBarcodeView.superview!)
        })
        
        loadingIndicator.snp.remakeConstraints({ (make) in
            make.center.equalTo(loadingIndicator.superview!)
        })
        
        memberInputContentView.snp.remakeConstraints({ (make) in
            make.edges.equalTo(memberInputContentView.superview!).inset(inputInfoDetailInsets).priority(Common.Layout.Priority.high.rawValue)
        })
        
        memberIDTitleLabel.snp.remakeConstraints({ (make) in
            make.top.left.right.equalTo(memberIDTitleLabel.superview!)
        })
        
        memberIDTextField.snp.remakeConstraints({ (make) in
            make.top.equalTo(memberIDTitleLabel.snp.bottom).offset(inputTextFieldTopMargin)
            make.left.right.equalTo(memberIDTextField.superview!)
        })
        
        memberZipCodeTitleLabel.snp.remakeConstraints({ (make) in
            make.top.equalTo(memberIDTextField.snp.bottom).offset(memberZipCodeTitleMarginTop)
            make.left.right.equalTo(memberZipCodeTitleLabel.superview!)
        })
        
        memberZipCodeTextField.snp.remakeConstraints({ (make) in
            make.top.equalTo(memberZipCodeTitleLabel.snp.bottom).offset(inputTextFieldTopMargin)
            make.left.right.bottom.equalTo(memberZipCodeTextField.superview!)
        })
        
        barcodeContentView.snp.remakeConstraints({ (make) in
            make.top.left.right.equalTo(barcodeContentView.superview!).inset(inputInfoDetailInsets)
            make.bottom.equalTo(barcodeContentView.superview!)
        })
        
        barcodeReciprocalBadgeImageView.snp.remakeConstraints { (make) in
            make.top.equalTo(barcodeContentView.snp.top)
            make.right.equalTo(barcodeContentView.snp.right)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        barcodeMemberName.snp.remakeConstraints({ (make) in
            make.top.left.equalTo(barcodeMemberName.superview!)
            make.right.equalTo(barcodeReciprocalBadgeImageView.snp.left)
        })
        
        barcodeMemberLevel.snp.remakeConstraints({ (make) in
            make.top.equalTo(barcodeMemberName.snp.bottom)
            make.left.equalTo(barcodeMemberLevel.superview!)
            make.right.equalTo(barcodeReciprocalBadgeImageView.snp.left)
        })
        
        barcodeExpirationDate.snp.remakeConstraints({ (make) in
            make.top.equalTo(barcodeMemberLevel.snp.bottom)
            make.left.equalTo(barcodeExpirationDate.superview!)
            make.right.equalTo(barcodeReciprocalBadgeImageView.snp.left)
        })
        
        barcodeImageView.snp.remakeConstraints({ (make) in
            make.top.equalTo(barcodeExpirationDate.snp.bottom)
            make.left.right.equalTo(barcodeImageView.superview!)
        })
        
        signInUpdateButton.snp.remakeConstraints({ (make) in
            make.top.equalTo(memberInputBarcodeView.snp.bottom).offset(signInUpdateButtonTopMargin).priority(Common.Layout.Priority.high.rawValue)
            make.left.right.equalTo(signInUpdateButton.superview!).inset(UIEdgeInsetsMake(0, sideMargin, 0, sideMargin))
        })
        
        switchMemberCardHolderButton.snp.remakeConstraints({ (make) in
            make.top.equalTo(signInUpdateButton.snp.bottom).offset(switchMemberCardHolderButtonTopMargin).priority(Common.Layout.Priority.high.rawValue)
            make.left.right.equalTo(switchMemberCardHolderButton.superview!).inset(UIEdgeInsetsMake(0, sideMargin, 0, sideMargin))
        })
        
        
        super.updateConstraints()
    }
    
    func animateBackground() {
        // Move back image to front
        backgroundImageViewFront.image = backgroundImageViewBack.image
        backgroundImageViewFront.alpha = 1.0
        
        // Increment Current background image
        currentBackgroundImageIndex = currentBackgroundImageIndex + 1
        if currentBackgroundImageIndex >= Common.Info.memberCardImagesTotal {
            currentBackgroundImageIndex = 0
        }
        
        // Set the back image
        backgroundImageViewBack.image = Common.Info.memberCardImages[currentBackgroundImageIndex]
        
        // Animate
        UIView.animate(withDuration: Common.Info.backgroundAnimationTime, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.backgroundImageViewFront.alpha = 0.0
            }, completion:  { (value:Bool) in
                if self.window != nil {
                    self.animateBackground()
                }
            }
        )
        
    }
}
