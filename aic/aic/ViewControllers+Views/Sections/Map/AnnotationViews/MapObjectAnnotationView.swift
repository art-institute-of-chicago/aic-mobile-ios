/*
 Abstract:
 Custom annotation views for objects (Artworks)
*/

import UIKit
import Alamofire
import MapKit
import Kingfisher

protocol MapObjectAnnotationViewDelegate: class {
    func mapObjectAnnotationViewPlayPressed(_ object: MapObjectAnnotationView)
}

class MapObjectAnnotationView: MapAnnotationView {
   static let reuseIdentifier: String = "mapObject"

    enum Mode {
		case dot			// unselected: dot,			selected: expanded info
		case image			// unselected: small image,	selected: big image
		case smallImageInfo	// unselected: small image, selected: expanded info
		case imageInfo		// unselected: big image, 	selected: expanded info
    }

	func setMode(mode: Mode, inTour: Bool = false) {
		let updateMode = self.mode != mode || self.isInTour != inTour

		self.mode = mode
		self.isInTour = inTour

		if updateMode {
			setContentForCurrentMode(withAnimation: true)
		}
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

    private let headphonesMarginRight: CGFloat = 15

    // Sub Views
    private let imageView = AICImageView()
    private let backgroundView = UIView() // Circle frame with tail
    private let tailView = UIImageView()
	private let imageDarkOverlay = UIView()
	private let tourStopNumberLabel = UILabel()
    private let playIcon = UIImageView()

    private let titleLabel = UILabel()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        guard let objectAnnotation = annotation as? MapObjectAnnotation else {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            return
        }

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        // Configure
        backgroundColor = .clear
        layer.zPosition = Common.Map.AnnotationZPosition.objectsDeselected.rawValue + CGFloat(objectAnnotation.floor)

//        self.layer.masksToBounds = false
//        self.layer.shadowOffset = CGSizeMake(0, 0)
//        self.layer.shadowRadius = 5
//        self.layer.shadowOpacity = 0.5
        self.layer.drawsAsynchronously = true
        //self.layer.shouldRasterize = true

        backgroundView.frame = CGRect(x: 0, y: 0, width: thumbHolderShrunkWidth, height: thumbHolderHeight)
        backgroundView.layer.cornerRadius = thumbHolderShrunkWidth/2
        backgroundView.backgroundColor = .white

        tailView.image = #imageLiteral(resourceName: "calloutTail")
        tailView.sizeToFit()

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Common.Map.thumbSize/2
        imageView.layer.masksToBounds = true
        imageView.frame.origin = CGPoint(x: Common.Map.thumbHolderMargin, y: Common.Map.thumbHolderMargin)
        imageView.frame.size = CGSize(width: Common.Map.thumbSize, height: Common.Map.thumbSize)
        imageView.isUserInteractionEnabled = true
		imageView.image = nil

		imageDarkOverlay.backgroundColor = UIColor(white: 0.2, alpha: 0.4)
		imageDarkOverlay.layer.cornerRadius = Common.Map.thumbSize/2
		imageDarkOverlay.layer.masksToBounds = true
		imageDarkOverlay.frame.origin = CGPoint(x: Common.Map.thumbHolderMargin, y: Common.Map.thumbHolderMargin)
		imageDarkOverlay.frame.size = CGSize(width: Common.Map.thumbSize, height: Common.Map.thumbSize)

		tourStopNumberLabel.numberOfLines = 1
		tourStopNumberLabel.text = ""
		tourStopNumberLabel.font = .aicMapTextFont
		tourStopNumberLabel.textAlignment = .center
		tourStopNumberLabel.textColor = .white

		playIcon.image = #imageLiteral(resourceName: "audioPlay").colorized(.aicMapColor)
        playIcon.sizeToFit()
        playIcon.frame.origin = CGPoint(x: thumbHolderExpandedWidth - playIcon.frame.width - headphonesMarginRight, y: thumbHolderHeight/2 - playIcon.frame.height/2)

        titleLabel.font = .aicMapObjectTextFont
        titleLabel.textColor = .aicMapColor
        titleLabel.numberOfLines = 2
        titleLabel.frame = CGRect(x: imageView.frame.width + Common.Map.thumbHolderMargin + titleLabelMarginLeft, y: thumbHolderHeight/2, width: titleLabelWidth, height: titleLabelHeight)

        // Add Subviews
		imageDarkOverlay.addSubview(tourStopNumberLabel)

		// Constraint number position to center of image
		tourStopNumberLabel.autoAlignAxis(.vertical, toSameAxisOf: imageDarkOverlay)
		tourStopNumberLabel.autoAlignAxis(.horizontal, toSameAxisOf: imageDarkOverlay, withOffset: -2)

        // Add Gestures
        let playTapGesture = UITapGestureRecognizer(target: self, action: #selector(MapObjectAnnotationView.playButtonWasTapped(_:)))
        backgroundView.isUserInteractionEnabled = true
        addGestureRecognizer(playTapGesture)

        setAnnotation(forObjectAnnotation: annotation as! MapObjectAnnotation)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

//        mode = .minimized
        isSelected = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        tailView.frame.origin = CGPoint(x: thumbHolderWidth/2 - tailView.frame.width/2, y: backgroundView.frame.height - tailView.frame.height/2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if self.isSelected != selected {
            self.isSelected = selected

			switch self.mode {
			case .dot:
				if self.isSelected == true {
					addSubview(tailView)
					addSubview(imageView)
					addSubview(titleLabel)
					addSubview(playIcon)

					loadImage()
					playIcon.alpha = 0.0
					titleLabel.alpha = 0.0

					layer.zPosition = Common.Map.AnnotationZPosition.objectMaximized.rawValue + CGFloat(objectAnnotation!.floor)

					UIView.animate(withDuration: animationDuration, animations: {
						self.expandThumbholder()

						self.backgroundView.backgroundColor = .white
						self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
						self.bounds = self.backgroundView.frame.union(self.tailView.frame)

						self.updateCenterOffsetForTransformedSize()

						self.setNeedsLayout()
						self.layoutIfNeeded()
					}, completion: { (completed) in
						if completed {
							UIView.animate(withDuration: self.animationDuration, animations: {
								self.titleLabel.alpha = 1.0
								self.playIcon.alpha = 1.0
							})
						}
					})
				} else {
					setContentForCurrentMode(withAnimation: true)
				}
				break

			case .imageInfo, .smallImageInfo:
				if self.isSelected == true {
					backgroundView.backgroundColor = .white

					addSubview(titleLabel)
					addSubview(playIcon)

					playIcon.alpha = 0.0
					titleLabel.alpha = 0.0

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
								self.titleLabel.alpha = 1.0
								self.playIcon.alpha = 1.0
							})
						}
					})

					layer.zPosition = Common.Map.AnnotationZPosition.objectsSelected.rawValue + CGFloat(objectAnnotation!.floor)
				} else {
					setContentForCurrentMode(withAnimation: true)
				}
				break

			case .image:
				if self.isSelected == true {
					UIView.animate(withDuration: animationDuration, animations: {
						self.backgroundView.backgroundColor = .white
						self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
						self.bounds = self.backgroundView.frame.union(self.tailView.frame)

						self.updateCenterOffsetForTransformedSize()

						self.setNeedsLayout()
						self.layoutIfNeeded()

						self.tourStopNumberLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
					})
				} else {
					setContentForCurrentMode(withAnimation: true)
				}
				break
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
			if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: annotation.thumbnailUrl.absoluteString) {
				self.imageView.image = image
				self.cropImage()
			} else {
				imageView.kf.indicatorType = .activity
				imageView.kf.setImage(with: annotation.thumbnailUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
					if image != nil {
						self.imageView.image = image
						self.cropImage()
					}
				})
			}
		}
    }

	private func cropImage() {
		if let image = self.imageView.image {
			if let annotation = objectAnnotation {
				if let cropRect = annotation.thumbnailCropRect {
					self.imageView.image = AppDataManager.sharedInstance.getCroppedImage(image: image, viewSize: self.imageView.frame.size, cropRect: cropRect)
				}
			}
		}
	}

    internal func setContentForCurrentMode(withAnimation animated: Bool) {
		self.isSelected = false

		// Add/Remove views
		for view in subviews {
			view.removeFromSuperview()
		}
		addSubview(backgroundView)

		if mode == .image || mode == .smallImageInfo || mode == .imageInfo {
			addSubview(tailView)
			addSubview(imageView)
		}

		if isInTour {
			addSubview(imageDarkOverlay)
		}

		// Image
		if mode == .dot {
			imageView.image = nil
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
        UIView.animate(withDuration: duration, animations: {
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

			case .image, .smallImageInfo:
				self.backgroundView.backgroundColor = .white
				self.transform = CGAffineTransform(scaleX: self.minimizedScale, y: self.minimizedScale)
				self.bounds = self.backgroundView.frame.union(self.tailView.frame)

				self.tourStopNumberLabel.transform = CGAffineTransform(scaleX: 1.0 / self.minimizedScale, y: 1.0 / self.minimizedScale)
				break
			}

            self.updateCenterOffsetForTransformedSize()

			self.setNeedsLayout()
			self.layoutIfNeeded()
        })
	}
}

// MARK: Gesture Recognizers
extension MapObjectAnnotationView {
    @objc internal func playButtonWasTapped(_ gesture: UIGestureRecognizer) {
		if mode == .imageInfo || mode == .smallImageInfo {
			if self.isSelected {
				delegate?.mapObjectAnnotationViewPlayPressed(self)
			}
		}
    }
}
