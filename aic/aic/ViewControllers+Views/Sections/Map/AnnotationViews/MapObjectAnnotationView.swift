/*
Abstract:
Custom annotation views for objects (Artworks)
*/

import UIKit
import Alamofire
import MapKit
import Kingfisher

protocol MapObjectAnnotationViewDelegate: AnyObject {
	func mapObjectAnnotationViewDidPressPlay(_ object: MapObjectAnnotationView)
}

class MapObjectAnnotationView: MapAnnotationView {
    static let playButtonTag = 0x340A277
	static let reuseIdentifier = "MapObjectAnnotationViewIdentifier"

	enum Mode {
		case dot			// unselected: dot,			selected: expanded info
		case image			// unselected: small image,	selected: big image
		case smallImageInfo	// unselected: small image, selected: expanded info
		case imageInfo		// unselected: big image, 	selected: expanded info
	}

	private var mode: Mode = .dot
	private var isInTour: Bool = false

	weak var delegate: MapObjectAnnotationViewDelegate?

	private var objectAnnotation: MapObjectAnnotation?

	private let animationDuration = 0.25
	private let dotScale: CGFloat = 0.15
	private let minimizedScale: CGFloat = 0.75

	private let titleLabelWidth: CGFloat = 150
	private let titleLabelHeight: CGFloat = 45
	private let titleLabelMarginLeft: CGFloat = 10

	private let thumbHolderShrunkWidth: CGFloat = Common.Map.thumbSize + Common.Map.thumbHolderMargin * 2
	private let thumbHolderExpandedWidth: CGFloat = 260
	private let thumbHolderHeight: CGFloat = Common.Map.thumbSize + Common.Map.thumbHolderMargin * 2

	// Sub Views
	private let iconImageView = AICImageView()
	private let backgroundView = UIView() // Circle frame with tail
	private let tailView = UIImageView()
	private let imageDarkOverlay = UIView()
	private let tourStopNumberLabel = UILabel()
	private let titleLabel = UILabel()
    private var playButton = UIButton()

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		guard let objectAnnotation = annotation as? MapObjectAnnotation else {
			super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
			return
		}

		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup(floor: objectAnnotation.floor)
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		isSelected = false
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    func setMode(mode: Mode, inTour: Bool = false) {
        let updateMode = self.mode != mode || self.isInTour != inTour

        self.mode = mode
        self.isInTour = inTour

        if updateMode {
            setContentForCurrentMode(withAnimation: true)
        }
    }

	func setAnnotation(forObjectAnnotation annotation: MapObjectAnnotation) {
		self.annotation = annotation
		self.objectAnnotation = annotation
		self.setContentForCurrentMode(withAnimation: false)

		// Set the title
		titleLabel.text = objectAnnotation!.title
		titleLabel.frame.origin.y = thumbHolderHeight/2 - titleLabel.frame.size.height/2
	}

	func setTourStopNumber(number: Int) {
		if number > 0 {
			self.tourStopNumberLabel.text = String(number)
			imageDarkOverlay.isHidden = false
		} else {
			imageDarkOverlay.isHidden = true
		}

	}

	private func shrinkThumbHolder() {
		backgroundView.frame.size.width = thumbHolderShrunkWidth
		positionThumbHolderTail(forThumbholderWidth: thumbHolderShrunkWidth)
	}

	private func expandThumbholder() {
		backgroundView.frame.size.width = thumbHolderExpandedWidth
		positionThumbHolderTail(forThumbholderWidth: thumbHolderExpandedWidth)
	}

	private func positionThumbHolderTail(forThumbholderWidth thumbHolderWidth: CGFloat) {
        tailView.frame.origin = CGPoint(
            x: thumbHolderWidth/2 - tailView.frame.width/2,
            y: backgroundView.frame.height - tailView.frame.height/2
        )
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		if self.isSelected != selected {
			self.isSelected = selected

			switch self.mode {
			case .dot:
				if self.isSelected {
					addSubview(tailView)
					addSubview(iconImageView)
					addSubview(titleLabel)
                    addSubview(playButton)

					loadImage()
                    playButton.alpha = 0
					titleLabel.alpha = 0

					layer.zPosition = Common.Map.AnnotationZPosition.objectMaximized.rawValue + CGFloat(objectAnnotation!.floor)

					UIView.animate(withDuration: animationDuration, animations: {
						self.expandThumbholder()

						self.backgroundView.backgroundColor = .white
						self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
						self.bounds = self.backgroundView.frame.union(self.tailView.frame) // ????

						self.updateCenterOffsetForTransformedSize()

						self.setNeedsLayout()
						self.layoutIfNeeded()
					}, completion: { completed in
						if completed {
							UIView.animate(withDuration: self.animationDuration) {
								self.titleLabel.alpha = 1
                                self.playButton.alpha = 1
							}
						}
					})
				} else {
					setContentForCurrentMode(withAnimation: true)
				}

			case .imageInfo, .smallImageInfo:
				if self.isSelected {
					backgroundView.backgroundColor = .white

					addSubview(titleLabel)
                    addSubview(playButton)

                    playButton.alpha = 0
					titleLabel.alpha = 0

					UIView.animate(withDuration: animationDuration, animations: {
						self.expandThumbholder()

						self.transform = CGAffineTransform(scaleX: 1, y: 1)
						self.bounds = self.backgroundView.frame.union(self.tailView.frame)

						self.updateCenterOffsetForTransformedSize()

						self.setNeedsLayout()
						self.layoutIfNeeded()
					}, completion: { (completed) in
						if completed {
							UIView.animate(withDuration: self.animationDuration, animations: {
								self.titleLabel.alpha = 1
                                self.playButton.alpha = 1
							})
						}
					})

					layer.zPosition = Common.Map.AnnotationZPosition.objectsSelected.rawValue + CGFloat(objectAnnotation!.floor)

				} else {
					setContentForCurrentMode(withAnimation: true)
				}

			case .image:
				if self.isSelected {
					UIView.animate(withDuration: animationDuration) {
						self.backgroundView.backgroundColor = .white
						self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
						self.bounds = self.backgroundView.frame.union(self.tailView.frame)

						self.updateCenterOffsetForTransformedSize()

						self.setNeedsLayout()
						self.layoutIfNeeded()

						self.tourStopNumberLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
					}
				} else {
					setContentForCurrentMode(withAnimation: true)
				}
			}
		}
	}

	private func updateCenterOffsetForTransformedSize() {
		let transformedBounds = self.bounds.applying(transform)
		centerOffset = CGPoint(x: 0, y: -transformedBounds.height/2)
	}

	private func loadImage() {
		if let annotation = objectAnnotation {
			// Try to load image from cache
            if let image = ImageCache.default.retrieveImageInMemoryCache(
                forKey: annotation.thumbnailUrl.absoluteString
            ) {
				iconImageView.image = image
                cropImage()
			} else {
				iconImageView.kf.indicatorType = .activity
                iconImageView.kf.setImage(with: annotation.thumbnailUrl) { result in
					if let result = try? result.get() {
						self.iconImageView.image = result.image
						self.cropImage()
					}
				}
			}
		}
	}

	private func cropImage() {
		if let image = iconImageView.image {
			if let annotation = objectAnnotation {
				if let cropRect = annotation.thumbnailCropRect {
                    iconImageView.image = AppDataManager.sharedInstance.getCroppedImage(
                        image: image,
                        viewSize: iconImageView.frame.size,
                        cropRect: cropRect
                    )
				}
			}
		}
	}

	func setContentForCurrentMode(withAnimation animated: Bool) {
		self.isSelected = false

		// Add/Remove views
		for view in subviews {
			view.removeFromSuperview()
		}
		addSubview(backgroundView)

		if mode == .image || mode == .smallImageInfo || mode == .imageInfo {
			addSubview(tailView)
			addSubview(iconImageView)
		}

		if isInTour {
			addSubview(imageDarkOverlay)
		}

		// Image
		if mode == .dot {
			iconImageView.image = nil
		} else {
			loadImage()
		}

		// Z position
		switch mode {
		case .dot:
			layer.zPosition = Common.Map.AnnotationZPosition.objectsDeselected.rawValue + CGFloat(objectAnnotation!.floor)
			break

		case .image, .smallImageInfo, .imageInfo:
			layer.zPosition = Common.Map.AnnotationZPosition.objectMaximized.rawValue + CGFloat(objectAnnotation!.floor)
			break
		}

		// Animation
		let duration = animated ? animationDuration : 0
        UIView.animate(withDuration: duration,
                       animations: {
            self.shrinkThumbHolder()
            
            switch self.mode {
            case .dot:
                self.backgroundView.backgroundColor = .aicMapLightColor
                self.transform = CGAffineTransform(scaleX: self.dotScale, y: self.dotScale)
                self.bounds = self.backgroundView.frame
                break
                
            case .imageInfo:
                self.backgroundView.backgroundColor = .white
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.bounds = self.backgroundView.frame.union(self.tailView.frame)
                break
                
            case .image,
                    .smallImageInfo:
                self.backgroundView.backgroundColor = .white
                self.transform = CGAffineTransform(scaleX: self.minimizedScale, y: self.minimizedScale)
                self.bounds = self.backgroundView.frame.union(self.tailView.frame)
                
                self.tourStopNumberLabel.transform = CGAffineTransform(
                    scaleX: 1.0 / self.minimizedScale,
                    y: 1.0 / self.minimizedScale
                )
				break
			}

			self.updateCenterOffsetForTransformedSize()

			self.setNeedsLayout()
			self.layoutIfNeeded()
		})
	}
}

// MARK: - Setups
private extension MapObjectAnnotationView {

    func setup(floor: Int) {
        backgroundColor = .clear
        layer.zPosition = Common.Map.AnnotationZPosition.objectsDeselected.rawValue + CGFloat(floor)
        layer.drawsAsynchronously = true

        setupBackgroundView()
        setupIconImageView()
        setupImageDarkOverlay()
        setupTourStopNumberLabel()
        setupPlayButton()
        setupTitleLabel()
        setupTourStopNumberLabel()
        setAnnotation(forObjectAnnotation: annotation as! MapObjectAnnotation)
    }

    func setupIconImageView() {
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = Common.Map.thumbSize/2
        iconImageView.layer.masksToBounds = true
        iconImageView.frame.origin = CGPoint(x: Common.Map.thumbHolderMargin, y: Common.Map.thumbHolderMargin)
        iconImageView.frame.size = CGSize(width: Common.Map.thumbSize, height: Common.Map.thumbSize)
        iconImageView.isUserInteractionEnabled = true
        iconImageView.image = nil
    }

    func setupBackgroundView() {
        backgroundView.frame = CGRect(x: 0, y: 0, width: thumbHolderShrunkWidth, height: thumbHolderHeight)
        backgroundView.layer.cornerRadius = thumbHolderShrunkWidth/2
        backgroundView.backgroundColor = .white
        tailView.image = #imageLiteral(resourceName: "calloutTail")
        tailView.sizeToFit()
    }

    func setupImageDarkOverlay() {
        imageDarkOverlay.backgroundColor = UIColor(white: 0.2, alpha: 0.4)
        imageDarkOverlay.layer.cornerRadius = Common.Map.thumbSize/2
        imageDarkOverlay.layer.masksToBounds = true
        imageDarkOverlay.frame.origin = CGPoint(x: Common.Map.thumbHolderMargin, y: Common.Map.thumbHolderMargin)
        imageDarkOverlay.frame.size = CGSize(width: Common.Map.thumbSize, height: Common.Map.thumbSize)
    }

    func setupTourStopNumberLabel() {
        // Constraint number position to center of image
        imageDarkOverlay.addSubview(tourStopNumberLabel)
        tourStopNumberLabel.numberOfLines = 1
        tourStopNumberLabel.text = ""
        tourStopNumberLabel.font = .aicMapTextFont
        tourStopNumberLabel.textAlignment = .center
        tourStopNumberLabel.textColor = .white
        tourStopNumberLabel.autoAlignAxis(.vertical, toSameAxisOf: imageDarkOverlay)
        tourStopNumberLabel.autoAlignAxis(.horizontal, toSameAxisOf: imageDarkOverlay, withOffset: -2)
    }

    func setupTitleLabel() {
        titleLabel.font = .aicMapObjectTextFont
        titleLabel.textColor = .aicMapColor
        titleLabel.numberOfLines = 2
        titleLabel.frame = CGRect(
            x: iconImageView.frame.width + Common.Map.thumbHolderMargin + titleLabelMarginLeft,
            y: thumbHolderHeight/2,
            width: titleLabelWidth,
            height: titleLabelHeight
        )
    }

    func setupPlayButton() {
        let rightMargin = CGFloat(5)
        let image = #imageLiteral(resourceName: "audioPlay").colorized(.aicMapColor)
        let size = CGSize(width: 40, height: 40)
        let origin = CGPoint(
            x: thumbHolderExpandedWidth - size.width - rightMargin,
            y: thumbHolderHeight/2 - size.height/2
        )

        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.image = image
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            playButton = UIButton(configuration: configuration)

        } else {
            playButton.setImage(image, for: .normal)
            playButton.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        }

        playButton.frame = CGRect(origin: origin, size: size)
        playButton.tag = Self.playButtonTag
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Play button target-action
private extension MapObjectAnnotationView {

    @objc func playButtonTapped() {
        let isImageInfoMode = (mode == .imageInfo || mode == .smallImageInfo)
        guard self.isSelected && isImageInfoMode else { return }

        delegate?.mapObjectAnnotationViewDidPressPlay(self)
    }

}
