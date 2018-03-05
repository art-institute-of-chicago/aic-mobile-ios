/*
 Abstract:
 Custom annotation views for objects (Artworks)
*/

import UIKit
import Alamofire
import MapKit
import Kingfisher

protocol MapObjectAnnotationViewDelegate : class {
    func mapObjectAnnotationViewPlayPressed(_ object: MapObjectAnnotationView)
}

class MapObjectAnnotationView: MapAnnotationView {
    
    class var reuseIdentifier: String {
        return "mapObject"
    }
    
    enum Mode {
        case minimized
        case maximized
		case tourMinimized
		case tourMaximized
		case tourOtherFloor
    }
    
    var mode:Mode = .minimized {
        didSet {
            if oldValue != mode {
                setContentForCurrentMode(withAnimation: true)
            }
        }
    }
    
    weak var delegate:MapObjectAnnotationViewDelegate?
    
    private var objectAnnotation:MapObjectAnnotation? = nil
    
    private let animationDuration = 0.25
    private let minimizedScale:CGFloat = 0.15
	private let tourMinimizedScale: CGFloat = 0.75
    
    private let titleLabelWidth:CGFloat = 150
    private let titleLabelHeight:CGFloat = 45
    private let titleLabelMarginLeft:CGFloat = 10
    
    private let thumbHolderShrunkWidth:CGFloat = Common.Map.thumbSize + Common.Map.thumbHolderMargin * 2
    private let thumbHolderExpandedWidth:CGFloat = 260
    private let thumbHolderHeight:CGFloat = Common.Map.thumbSize + Common.Map.thumbHolderMargin * 2
    
    private let headphonesMarginRight:CGFloat = 15
    
    private var imageLoaded = false
    
    // Sub Views
    private let imageView = AICImageView()
    private let imageHolderView = UIView() // Circle frame with tail
    private let imageHolderTailView = UIImageView()
	private let imageDarkOverlay = UIView()
	private let tourStopNumberLabel = UILabel()
    
    private let headphonesIcon = UIImageView()
    
    private let titleLabel = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        guard let objectAnnotation = annotation as? MapObjectAnnotation else {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            return
        }
        
        super.init(annotation:annotation, reuseIdentifier:reuseIdentifier)
		
        // Configure
        backgroundColor = .clear
        layer.zPosition = Common.Map.AnnotationZPosition.objectsDeselected.rawValue + CGFloat(objectAnnotation.floor)
        
//        self.layer.masksToBounds = false
//        self.layer.shadowOffset = CGSizeMake(0, 0)
//        self.layer.shadowRadius = 5
//        self.layer.shadowOpacity = 0.5
        self.layer.drawsAsynchronously = true
        //self.layer.shouldRasterize = true
        
        imageHolderView.frame = CGRect(x: 0, y: 0, width: thumbHolderShrunkWidth, height: thumbHolderHeight)
        imageHolderView.layer.cornerRadius = thumbHolderShrunkWidth/2
        imageHolderView.backgroundColor = .white
        
        imageHolderTailView.image = #imageLiteral(resourceName: "calloutTail")
        imageHolderTailView.sizeToFit()
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Common.Map.thumbSize/2
        imageView.layer.masksToBounds = true
        imageView.frame.origin = CGPoint(x: Common.Map.thumbHolderMargin, y: Common.Map.thumbHolderMargin)
        imageView.frame.size = CGSize(width: Common.Map.thumbSize, height: Common.Map.thumbSize)
        imageView.isUserInteractionEnabled = true
		
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
        
		headphonesIcon.image = #imageLiteral(resourceName: "audioPlay").colorized(.aicMapColor)
        headphonesIcon.sizeToFit()
        headphonesIcon.frame.origin = CGPoint(x: thumbHolderExpandedWidth - headphonesIcon.frame.width - headphonesMarginRight, y: thumbHolderHeight/2 - headphonesIcon.frame.height/2)
        
        titleLabel.font = .aicMapObjectTextFont
        titleLabel.textColor = .aicMapColor
        titleLabel.numberOfLines = 2
        titleLabel.frame = CGRect(x: imageView.frame.width + Common.Map.thumbHolderMargin + titleLabelMarginLeft, y: thumbHolderHeight/2, width: titleLabelWidth, height: titleLabelHeight)
        
        // Add Subviews
        addSubview(imageHolderTailView)
        addSubview(imageHolderView)
        addSubview(imageView)
		addSubview(imageDarkOverlay)
		imageDarkOverlay.addSubview(tourStopNumberLabel)
		
		// Constraint number position to center of image
		tourStopNumberLabel.autoAlignAxis(.vertical, toSameAxisOf: imageDarkOverlay)
		tourStopNumberLabel.autoAlignAxis(.horizontal, toSameAxisOf: imageDarkOverlay, withOffset: -2)
		
        // Add Gestures
        let playTapGesture = UITapGestureRecognizer(target: self, action: #selector(MapObjectAnnotationView.playButtonWasTapped(_:)))
        imageHolderView.isUserInteractionEnabled = true
        addGestureRecognizer(playTapGesture)
        
        setAnnotation(forObjectAnnotation: annotation as! MapObjectAnnotation)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
		
//        mode = .minimized
//        isSelected = false

        imageView.image = nil
        imageLoaded = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAnnotation(forObjectAnnotation annotation:MapObjectAnnotation) {
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
		}
		else {
			imageDarkOverlay.isHidden = true
		}
		
	}
    
    private func shrinkThumbHolder() {
        imageHolderView.frame.size.width = thumbHolderShrunkWidth
        positionThumbHolderTail(forThumbholderWidth: thumbHolderShrunkWidth)
    }
    
    private func expandThumbholder() {
        imageHolderView.frame.size.width = thumbHolderExpandedWidth
        positionThumbHolderTail(forThumbholderWidth: thumbHolderExpandedWidth)
    }
    
    private func positionThumbHolderTail(forThumbholderWidth thumbHolderWidth:CGFloat) {
        imageHolderTailView.frame.origin = CGPoint(x: thumbHolderWidth/2 - imageHolderTailView.frame.width/2, y: imageHolderView.frame.height - imageHolderTailView.frame.height/2)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if self.isSelected != selected {
            self.isSelected = selected
			
			// never expand if in tour mode
			if mode == .tourMinimized || mode == .tourMaximized || mode == .tourOtherFloor {
				return
			}
			
            if selected {
                addSubview(imageHolderTailView)
                addSubview(imageView)
				if objectAnnotation?.nid != nil {
					addSubview(headphonesIcon)
				}
                addSubview(titleLabel)
                
                headphonesIcon.alpha = 0.0
                titleLabel.alpha = 0.0
                
                loadImage()
                
                UIView.animate(withDuration: animationDuration, animations: {
                    self.expandThumbholder()
					
                    self.transform = CGAffineTransform(scaleX: 1, y: 1);
                    self.bounds = self.imageHolderView.frame.union(self.imageHolderTailView.frame)
                    self.updateCenterOffsetForTransformedSize()
                })
                
                UIView.animate(withDuration: animationDuration, delay: animationDuration, options: UIViewAnimationOptions(), animations: {
                    self.titleLabel.alpha = 1.0
                    self.headphonesIcon.alpha = 1.0
                    }, completion: { _ in }
                )
                
                layer.zPosition = Common.Map.AnnotationZPosition.objectsSelected.rawValue + CGFloat(objectAnnotation!.floor)
            } else {
                setContentForCurrentMode(withAnimation: true)
            }
        }
    }
    
    private func updateCenterOffsetForTransformedSize() {
        let transformedBounds = self.bounds.applying(transform);
        centerOffset = CGPoint(x: 0, y: -transformedBounds.height/2)
    }
    
    private func loadImage() {
        if !imageLoaded {
            if let annotation = objectAnnotation {
				imageView.kf.indicatorType = .activity
				imageView.kf.setImage(with: annotation.thumbnailUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cache, url) in
					if image != nil {
						if let cropRect = annotation.thumbnailCropRect {
							self.imageView.image = AppDataManager.sharedInstance.getCroppedImage(image: image!, viewSize: self.imageView.frame.size, cropRect: cropRect)
						}
					}
				})
				imageLoaded = true
            }
        }
    }
    
    internal func setContentForCurrentMode(withAnimation animated:Bool) {
        // Add/Remove views
        titleLabel.removeFromSuperview()
        headphonesIcon.removeFromSuperview()
		
		switch mode {
		case .minimized:
			imageView.cancelLoading()
			imageView.image = nil
			imageLoaded = false
			
			self.alpha = 1.0
			
			imageHolderTailView.removeFromSuperview()
			imageView.removeFromSuperview()
			imageDarkOverlay.removeFromSuperview()
			
			layer.zPosition = Common.Map.AnnotationZPosition.objectsDeselected.rawValue + CGFloat(objectAnnotation!.floor)
			break
			
		case .maximized:
			loadImage()
			
			self.alpha = 1.0
			
			imageDarkOverlay.removeFromSuperview()
			addSubview(imageHolderTailView)
			addSubview(imageView)
			
			layer.zPosition = Common.Map.AnnotationZPosition.objectMaximized.rawValue + CGFloat(objectAnnotation!.floor)
			break
			
		case .tourMinimized, .tourOtherFloor:
			loadImage()
			
			self.alpha = mode == .tourMinimized ? 1.0 : 0.5
			
			if mode == . tourMinimized {
				addSubview(imageHolderTailView)
			}
			else {
				imageHolderTailView.removeFromSuperview()
			}
			addSubview(imageView)
			addSubview(imageDarkOverlay)
			
			layer.zPosition = Common.Map.AnnotationZPosition.objectsDeselected.rawValue + CGFloat(objectAnnotation!.floor)
			break
			
		case .tourMaximized:
			loadImage()
			
			self.alpha = 1.0
			
			addSubview(imageHolderTailView)
			addSubview(imageView)
			addSubview(imageDarkOverlay)
			
			layer.zPosition = Common.Map.AnnotationZPosition.objectMaximized.rawValue + CGFloat(objectAnnotation!.floor)
			break
		}
        

        // Change frames with animation
        let duration = animated ? animationDuration : 0
        UIView.animate(withDuration: duration, animations: {
            self.shrinkThumbHolder()
            
            switch self.mode {
            case .minimized:
                self.transform = CGAffineTransform(scaleX: self.minimizedScale, y: self.minimizedScale)
                self.bounds = self.imageHolderView.frame
                break
                
            case .maximized:
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.bounds = self.imageHolderView.frame.union(self.imageHolderTailView.frame)
				break
				
			case .tourMinimized, .tourOtherFloor:
				self.transform = CGAffineTransform(scaleX: self.tourMinimizedScale, y: self.tourMinimizedScale)
				self.bounds = self.imageHolderView.frame
				
				self.tourStopNumberLabel.transform = CGAffineTransform(scaleX: 1.0 / self.tourMinimizedScale, y: 1.0 / self.tourMinimizedScale)
				break
				
			case .tourMaximized:
				self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
				self.bounds = self.imageHolderView.frame
				
				self.tourStopNumberLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
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
    @objc internal func playButtonWasTapped(_ gesture:UIGestureRecognizer) {
		// if in tour mode, do now tap to play audio
		if mode == .tourMaximized || mode == .tourMinimized || mode == .tourOtherFloor {
			return
		}
		
        if isSelected {
            delegate?.mapObjectAnnotationViewPlayPressed(self)
        }
    }
}
