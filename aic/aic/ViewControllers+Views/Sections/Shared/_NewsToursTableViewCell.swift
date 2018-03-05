/*
 Abstract:
 Table View cell that holds an overview of either a Tour or a News Item
 */

import UIKit
import Alamofire

protocol NewsToursTableViewCellDelegate : class {
    func newsToursTableViewCellWasTapped(_ cell:NewsToursTableViewCell)
    func newsToursTableViewCellRevealContentTapped(_ cell:NewsToursTableViewCell)
}

class NewsToursTableViewCell: UITableViewCell {
    enum NewsToursTableViewCellMode {
        case closed
        case open
    }
    
    weak var delegate:NewsToursTableViewCellDelegate? = nil
    
    var mode:NewsToursTableViewCellMode? {
        didSet {
            updateLayoutForCurrentMode()
        }
    }
    
    var didSetupConstraints = false
    
    var shouldAnimateModeChange = true
    var animationDuration = 0.5
    
    // Params
    let headerImageMarginsClosed = UIEdgeInsetsMake(5, 5, 0, 5)
    let headerImageMarginsOpen = UIEdgeInsetsMake(0, 0, 0, 0)
    let headerImageViewListRatio = 0.583
    let headerImageViewDetailRatio = 0.8
    let titleMargins = UIEdgeInsetsMake(15, 25, 0, 25)
    let titleLineHeight:CGFloat = 23
    let descriptionMargins = UIEdgeInsetsMake(10, 25, 20, 25)
    let descriptionLineHeight:CGFloat = 25
    let revealContentButtonHeight = 50
    let revealContentButtonMargins = UIEdgeInsetsMake(25,25,25,25)
    let newBannerMargins = UIEdgeInsetsMake(20,0,0,0)
    let newBannerLabelMargins = UIEdgeInsetsMake(0,0,0,10)
    
    // Header
    let headerView = UIView()
	
    var imageIsLoaded = false
    let headerImageView = AICImageView()
    let stopsDistanceItemView = NewsToursStopsDistanceView()
    
    // Model for appropriate content
    var model:AICTourModel {
        didSet {
            updateLayoutForCurrentMode()
        }
    }
    
    // Subviews
    let titleLabel = UILabel()
    var revealContentButton:UIButton! = nil
    let descriptionLabel = UILabel()
    var additionalInformationLabel:UILabel? = nil
    
    init(model:AICTourModel) {
        self.model = model
        
        // TODO: TItle may not be the best reuse identifier
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: String(model.title))
        
        selectionStyle = UITableViewCellSelectionStyle.none
        
        // Sets the separator to the edges
        layoutMargins = UIEdgeInsets.zero;
        preservesSuperviewLayoutMargins = false;
        
        // Configure
        headerImageView.contentMode = UIViewContentMode.scaleAspectFill
        headerImageView.delegate = self
        headerImageView.clipsToBounds = true
        headerImageView.isUserInteractionEnabled = true
        
        // Title
        titleLabel.attributedText = getAttributedStringWithLineHeight(text: model.title, font: .aicTitleFont, lineHeight: titleLineHeight)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        
        // Description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .aicShortTextFont
        descriptionLabel.textColor = .black
        
        // Additional Info
        if let additionalInfo = model.additionalInformation {
            additionalInformationLabel = UILabel()
            additionalInformationLabel?.numberOfLines = 1
            additionalInformationLabel?.font = .aicItalicTextFont
            additionalInformationLabel?.textColor = .black
            additionalInformationLabel?.text = additionalInfo
        }
        
        // Reveal content Button
        revealContentButton = AICButton(isSmall: false)
		
        revealContentButton.setTitle("", for: UIControlState())
        revealContentButton.isHidden = true
        
        contentView.backgroundColor = .white
        
        // Add subviews
        headerView.addSubview(headerImageView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(revealContentButton)
        contentView.addSubview(descriptionLabel)
        
        if additionalInformationLabel != nil {
            contentView.addSubview(additionalInformationLabel!)
        }
        
        // Set Gestures
        let tap = UITapGestureRecognizer(target: self, action:#selector(NewsToursTableViewCell.wasTapped))
        addGestureRecognizer(tap)
        
        let revealButtonTap = UITapGestureRecognizer(target: self, action:#selector(NewsToursTableViewCell.revealContentTapped))
        revealContentButton.addGestureRecognizer(revealButtonTap)
        
        // Initialize our mode
        mode = .closed
        updateLayoutForCurrentMode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        headerImageView.loadImageAsynchronously(fromUrl: model.imageUrl, withCropRect: nil)
    }
    
    func setDistance(toValue distance:Int) {
        stopsDistanceItemView.setDistance(toValue: distance)
        addStopsDistanceView()
    }
    
    func setStops(toValue stops:Int) {
        stopsDistanceItemView.setStops(toValue: stops)
        addStopsDistanceView()
    }
    
    private func addStopsDistanceView() {
        if stopsDistanceItemView.superview == nil {
            headerView.addSubview(stopsDistanceItemView)
            updateConstraints()
        }
    }
    
    private func updateLayoutForCurrentMode() {
        assert(mode != nil, "There must be a valid mode for this item view.")
        
        switch mode! {
        case .closed:
			descriptionLabel.numberOfLines = 2
            descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: model.shortDescription.stringByDecodingHTMLEntities,
                                                                                    font: .aicShortTextFont,
                                                                                    lineHeight:descriptionLineHeight)
            descriptionLabel.lineBreakMode = .byTruncatingTail
			
            
            if shouldAnimateModeChange {
                UIView.animate(withDuration: animationDuration, animations: {
                    self.revealContentButton.alpha = 0.0
                    }, completion: {(value:Bool) in
                        self.revealContentButton.isHidden = true
                })
            }
            else {
                revealContentButton.isHidden = true
            }
            
            break
            
        case .open:
            descriptionLabel.numberOfLines = 0
            descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: model.longDescription.stringByDecodingHTMLEntities,
                                                                                font: .aicShortTextFont,
                                                                                lineHeight:descriptionLineHeight)
            revealContentButton.isHidden = false
            descriptionLabel.isHidden = false
            
            if shouldAnimateModeChange {
                revealContentButton.alpha = 0.0
                UIView.animate(withDuration: animationDuration, animations: {
                    self.revealContentButton.alpha = 1.0
                    self.descriptionLabel.alpha = 1.0
                })
            }
            else {
                self.revealContentButton.alpha = 1.0
                self.descriptionLabel.alpha = 1.0
            }
            break
        }
        
        updateConstraints()
    }
    
    override func updateConstraints() {
        contentView.snp.remakeConstraints({ (make) -> Void in
            make.edges.equalTo(contentView.superview!)
            
            make.bottom.equalTo(descriptionLabel).offset(descriptionMargins.bottom).priority(Common.Layout.Priority.high.rawValue)
        })
        
        // Header
        // Don't remake this one, it breaks things. Need to figure out why in future.
        headerView.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(headerView.superview!)
        }
        
        headerImageView.snp.remakeConstraints({ (make) -> Void in
            if mode == .closed {
                make.top.left.right.equalTo(headerImageView.superview!).inset(headerImageMarginsClosed)
                make.height.equalTo((UIScreen.main.bounds.width - headerImageMarginsClosed.left - headerImageMarginsClosed.right) *  CGFloat(headerImageViewDetailRatio))
            } else {
                make.top.left.right.equalTo(headerImageView.superview!).inset(headerImageMarginsOpen)
                make.width.equalTo(headerImageView.superview!)
                make.height.equalTo(headerImageView.snp.width).multipliedBy(headerImageViewDetailRatio)
            }
            
            make.bottom.equalTo(headerImageView.superview!)
        })
        
        // Details
        if stopsDistanceItemView.superview != nil {
            stopsDistanceItemView.snp.remakeConstraints { (make) -> Void in
                make.left.right.bottom.equalTo(headerImageView)
            }
        }
        
        // Title
        titleLabel.snp.remakeConstraints({ (make) -> Void in
            make.top.equalTo(headerView.snp.bottom).offset(titleMargins.top)
            make.left.right.equalTo(titleLabel.superview!).inset(titleMargins)
            make.height.greaterThanOrEqualTo(1).priority(Common.Layout.Priority.low.rawValue)
        })
        
        // Reveal Button
        revealContentButton.snp.remakeConstraints({ (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(revealContentButtonMargins.top)
            make.left.right.equalTo(revealContentButton.superview!).inset(revealContentButtonMargins)
            make.height.equalTo(revealContentButtonHeight)
        })
        
        // Description Label
        descriptionLabel.snp.remakeConstraints({ (make) -> Void in
            if mode == .closed {
                make.top.equalTo(titleLabel.snp.bottom).offset(descriptionMargins.top)
            } else {
                make.top.equalTo(revealContentButton.snp.bottom).offset(revealContentButtonMargins.top)
            }
            
            make.left.right.equalTo(descriptionLabel.superview!).inset(descriptionMargins)
            make.height.greaterThanOrEqualTo(1)
        })
        
        super.updateConstraints()
    }
}

// Gesture Handlers
extension NewsToursTableViewCell {
    @objc func wasTapped() {
        delegate?.newsToursTableViewCellWasTapped(self)
    }
    
    @objc func revealContentTapped() {
        self.delegate?.newsToursTableViewCellRevealContentTapped(self)
    }
}

extension NewsToursTableViewCell : AICImageViewDelegate {
    func aicImageViewDidFinishLoadingImageAsynchronously() {
        imageIsLoaded = true
        updateConstraints()
    }
}
