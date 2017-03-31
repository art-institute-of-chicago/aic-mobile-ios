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

	let newBannerView = UIView()
	let newBannerGradientLayer = CAGradientLayer()
	let newBannerLabel = UILabel()
	var imageIsLoaded = false
	let headerImageView = AICImageView()
	let stopsDistanceItemView = NewsToursStopsDistanceView()

	// Model for appropriate content
	var model:AICNewsTourItemProtocol {
		didSet {
			updateLayoutForCurrentMode()
		}
	}

	// Subviews
	let titleLabel = UILabel()
	var revealContentButton:UIButton! = nil
	let descriptionLabel = UILabel()
	var additionalInformationLabel:UILabel? = nil

	init(model:AICNewsTourItemProtocol) {
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
		titleLabel.attributedText = getAttributedStringWithLineHeight(text: model.title.stringByDecodingHTMLEntities, font: UIFont.aicTitleFont()!, lineHeight: titleLineHeight)
		titleLabel.numberOfLines = 0
		titleLabel.textColor = UIColor.black

		// Description
		descriptionLabel.numberOfLines = 0
		descriptionLabel.font = UIFont.aicShortTextFont()
		descriptionLabel.textColor = UIColor.black

		// Additional Info
		if let additionalInfo = model.additionalInformation {
			additionalInformationLabel = UILabel()
			additionalInformationLabel?.numberOfLines = 1
			additionalInformationLabel?.font = UIFont.aicItalicTextFont()
			additionalInformationLabel?.textColor = UIColor.black
			additionalInformationLabel?.text = additionalInfo
		}

		// Reveal content Button
		if model.type == .tour {
			revealContentButton = AICButton()
		} else {
			revealContentButton = UIButton()
			revealContentButton.setImage(UIImage(named:"buttonPin"), for: UIControlState())
			revealContentButton.setTitleColor(UIColor.aicButtonsColor(), for: UIControlState())
			revealContentButton.titleLabel!.font = UIFont.aicTitleFont()
			revealContentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left;
			revealContentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
		}

		revealContentButton.setTitle(model.revealTitle, for: UIControlState())
		revealContentButton.isHidden = true

		contentView.backgroundColor = UIColor.white

		//New Banner Flag
		if model.bannerString != nil {
			newBannerView.isHidden = true
			newBannerView.alpha = 0.0

			let bannerFont = UIFont(name: "SourceSansPro-Semibold", size: 18.0)!
			let attributedBannerString = NSMutableAttributedString.init(string: model.bannerString!, attributes: [
				NSKernAttributeName : 1.75,
				NSForegroundColorAttributeName : UIColor.darkGray,
				NSFontAttributeName : bannerFont
				])
			newBannerLabel.attributedText = attributedBannerString
			newBannerLabel.textAlignment = .right
			newBannerLabel.adjustsFontSizeToFitWidth = true
			newBannerLabel.minimumScaleFactor = 0.5
			newBannerLabel.sizeToFit()
			newBannerView.frame = CGRect(x: 0, y: 0, width: newBannerLabel.frame.size.width + 20, height: 40)

			newBannerView.addSubview(newBannerLabel)
			headerImageView.addSubview(newBannerView)
		}

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
			if model.type == .tour {
				descriptionLabel.numberOfLines = 2
				descriptionLabel.attributedText = getAttributedString(forHTMLText: model.shortDescription, font: UIFont.aicShortTextFont()!)
				descriptionLabel.lineBreakMode = .byTruncatingTail
			}

			if shouldAnimateModeChange {
				UIView.animate(withDuration: animationDuration, animations: {
					if self.imageIsLoaded {
						self.newBannerView.alpha = 1.0
					}
					self.revealContentButton.alpha = 0.0
					if self.model.type == .news {
						self.descriptionLabel.alpha = 0.0
					}
				}, completion: {(value:Bool) in
					if self.imageIsLoaded{
						self.newBannerView.isHidden = false
					}
					self.revealContentButton.isHidden = true
					if self.model.type == .news {
						self.descriptionLabel.isHidden = true
					}
				})
			}
			else {
				revealContentButton.isHidden = true
			}

			break

		case .open:
			descriptionLabel.numberOfLines = 0
			descriptionLabel.attributedText = getAttributedString(forHTMLText: model.longDescription, font: UIFont.aicShortTextFont()!)

			revealContentButton.isHidden = false
			descriptionLabel.isHidden = false
			newBannerView.isHidden = true

			if shouldAnimateModeChange {
				if self.imageIsLoaded {
					newBannerView.alpha = 1.0
				}
				revealContentButton.alpha = 0.0
				if model.type == .news {
					descriptionLabel.alpha = 0.0
				}
				UIView.animate(withDuration: animationDuration, animations: {
					self.newBannerView.alpha = 0.0
					self.revealContentButton.alpha = 1.0
					self.descriptionLabel.alpha = 1.0
				})
			}
			else {
				self.newBannerView.alpha = 0.0
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

			if model.type == .tour {
				make.bottom.equalTo(descriptionLabel).offset(descriptionMargins.bottom).priority(Common.Layout.Priority.high.rawValue)
			} else {
				make.bottom.equalTo(additionalInformationLabel!).offset(descriptionMargins.bottom).priority(Common.Layout.Priority.high.rawValue)
			}
		})

		// Header
		// Don't remake this one, it breaks things. Need to figure out why in future.
		headerView.snp.makeConstraints { (make) in
			make.top.left.right.equalTo(headerView.superview!)
		}

		headerImageView.snp.remakeConstraints({ (make) in
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

		if model.bannerString != nil{
			newBannerView.snp.remakeConstraints { (make) in
				make.top.right.equalTo(headerView).inset(newBannerMargins)
				make.width.equalTo(newBannerLabel.frame.size.width + 40)
				make.height.equalTo(40)
			}
			newBannerLabel.snp.remakeConstraints({ (make) in
				make.right.equalTo(newBannerView.snp.right).inset(newBannerLabelMargins)
				make.top.bottom.equalTo(newBannerView)
				make.height.equalTo(newBannerView)
			})

			//Add gradient
			newBannerGradientLayer.frame = newBannerView.bounds
			newBannerGradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
			newBannerGradientLayer.locations = [0.0, 1.0]
			newBannerGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
			let endPoint = (newBannerView.frame.size.width - newBannerLabel.frame.size.width) / newBannerView.frame.size.width
			newBannerGradientLayer.endPoint = CGPoint(x: endPoint, y: 0.5)
			if newBannerView.layer.sublayers?[0] != newBannerGradientLayer {
				newBannerView.layer.insertSublayer(newBannerGradientLayer, at: 0)
			}
		}

		// Details
		if stopsDistanceItemView.superview != nil {
			stopsDistanceItemView.snp.remakeConstraints { (make) in
				make.left.right.bottom.equalTo(headerImageView)
			}
		}

		// Title
		titleLabel.snp.remakeConstraints({ (make) in
			make.top.equalTo(headerView.snp.bottom).offset(titleMargins.top)
			make.left.right.equalTo(titleLabel.superview!).inset(titleMargins)
			make.height.greaterThanOrEqualTo(1).priority(Common.Layout.Priority.low.rawValue)
		})

		// Reveal Button
		revealContentButton.snp.remakeConstraints({ (make) in
			make.top.equalTo(titleLabel.snp.bottom).offset(revealContentButtonMargins.top)
			make.left.right.equalTo(revealContentButton.superview!).inset(revealContentButtonMargins)
			make.height.equalTo(revealContentButtonHeight)
		})

		// Description Label
		descriptionLabel.snp.remakeConstraints({ (make) in
			if mode == .closed {
				make.top.equalTo(titleLabel.snp.bottom).offset(descriptionMargins.top)
			} else {
				make.top.equalTo(revealContentButton.snp.bottom).offset(revealContentButtonMargins.top)
			}

			make.left.right.equalTo(descriptionLabel.superview!).inset(descriptionMargins)
			make.height.greaterThanOrEqualTo(1)
		})


		// Additional Info (News only)
		if model.type == .news {
			additionalInformationLabel!.snp.remakeConstraints({ (make) in
				if mode == .open {
					make.top.equalTo(descriptionLabel.snp.bottom)
				} else {
					make.top.equalTo(titleLabel.snp.bottom)
				}

				make.left.right.equalTo(additionalInformationLabel!.superview!).inset(descriptionMargins)
			})
		}

		super.updateConstraints()
	}
}

// Gesture Handlers
extension NewsToursTableViewCell {
	func wasTapped() {
		delegate?.newsToursTableViewCellWasTapped(self)
	}

	func revealContentTapped() {
		self.delegate?.newsToursTableViewCellRevealContentTapped(self)
	}
}

extension NewsToursTableViewCell : AICImageViewDelegate {
	func aicImageViewDidFinishLoadingImageAsynchronously() {
		imageIsLoaded = true
		updateConstraints()
		//Animate in banner view if needed
		if model.bannerString != nil {
			newBannerView.alpha = 0.0
			newBannerView.isHidden = false
			UIView.animate(withDuration: 0.5, animations: {
				self.newBannerView.alpha = 1.0
			})
		}
	}
}
