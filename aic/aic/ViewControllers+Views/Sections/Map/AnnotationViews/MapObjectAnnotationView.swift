/*
 Abstract:
 Custom annotation views for objects (Artworks)
*/

import UIKit
import Alamofire
import MapKit
import Kingfisher

protocol MapObjectAnnotationViewDelegate : class {
    func mapObjectAnnotationViewPlayPressed(_ object:MapObjectAnnotationView)
}

class MapObjectAnnotationView: MapAnnotationView {
    
    class var reuseIdentifier:String {
        return "mapObject"
    }
    
    enum Mode {
        case minimized
        case maximized
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
    
    private let titleLabelWidth:CGFloat = 150
    private let titleLabelHeight:CGFloat = 45
    private let titleLabelMarginLeft:CGFloat = 10
    
    private let thumbHolderShrunkWidth:CGFloat = Common.Map.thumbSize + Common.Map.thumbHolderMargin * 2
    private let thumbHolderExpandedWidth:CGFloat = 260
    private let thumbHolderHeight:CGFloat = Common.Map.thumbSize + Common.Map.thumbHolderMargin * 2
    
    private let headphonesMarginRight:CGFloat = 15
    
    private var imageLoaded = false
    
    // Sub Views
    private let thumbImageView = AICImageView()
    private let thumbHolderView = UIView() // Circle frame with tail
    private let thumbHolderTailView = UIImageView()
    
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
        
        thumbHolderView.frame = CGRect(x: 0, y: 0, width: thumbHolderShrunkWidth, height: thumbHolderHeight)
        thumbHolderView.layer.cornerRadius = thumbHolderShrunkWidth/2
        thumbHolderView.backgroundColor = .white
        
        thumbHolderTailView.image = #imageLiteral(resourceName: "calloutTail")
        thumbHolderTailView.sizeToFit()
        
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.layer.cornerRadius = Common.Map.thumbSize/2
        thumbImageView.layer.masksToBounds = true
        thumbImageView.frame.origin = CGPoint(x: Common.Map.thumbHolderMargin, y: Common.Map.thumbHolderMargin)
        thumbImageView.frame.size = CGSize(width: Common.Map.thumbSize, height: Common.Map.thumbSize)
        thumbImageView.isUserInteractionEnabled = true
        
        headphonesIcon.image = #imageLiteral(resourceName: "headphonesSm")
        headphonesIcon.sizeToFit()
        headphonesIcon.frame.origin = CGPoint(x: thumbHolderExpandedWidth - headphonesIcon.frame.width - headphonesMarginRight, y: thumbHolderHeight/2 - headphonesIcon.frame.height/2)
        
        titleLabel.font = .aicShortTextFont
        titleLabel.textColor = .aicNearbyColor
        titleLabel.numberOfLines = 2
        titleLabel.frame = CGRect(x: thumbImageView.frame.width + Common.Map.thumbHolderMargin + titleLabelMarginLeft, y: thumbHolderHeight/2, width: titleLabelWidth, height: titleLabelHeight)
        
        // Add Subviews
        addSubview(thumbHolderTailView)
        addSubview(thumbHolderView)
        addSubview(thumbImageView)
        
        // Add Gestures
        let playTapGesture = UITapGestureRecognizer(target: self, action: #selector(MapObjectAnnotationView.playButtonWasTapped(_:)))
        thumbHolderView.isUserInteractionEnabled = true
        addGestureRecognizer(playTapGesture)
        
        setAnnotation(forObjectAnnotation: annotation as! MapObjectAnnotation)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
		
//        mode = .minimized
//        isSelected = false

        thumbImageView.image = nil
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
    
    private func shrinkThumbHolder() {
        thumbHolderView.frame.size.width = thumbHolderShrunkWidth
        positionThumbHolderTail(forThumbholderWidth: thumbHolderShrunkWidth)
    }
    
    private func expandThumbholder() {
        thumbHolderView.frame.size.width = thumbHolderExpandedWidth
        positionThumbHolderTail(forThumbholderWidth: thumbHolderExpandedWidth)
    }
    
    private func positionThumbHolderTail(forThumbholderWidth thumbHolderWidth:CGFloat) {
        thumbHolderTailView.frame.origin = CGPoint(x: thumbHolderWidth/2 - thumbHolderTailView.frame.width/2, y: thumbHolderView.frame.height - thumbHolderTailView.frame.height/2)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if self.isSelected != selected {
            self.isSelected = selected
            if selected {
                addSubview(thumbHolderTailView)
                addSubview(thumbImageView)
				if objectAnnotation?.nid != nil {
					addSubview(headphonesIcon)
				}
                addSubview(titleLabel)
                
                headphonesIcon.alpha = 0.0
                titleLabel.alpha = 0.0
                
                loadImage()
                
                UIView.animate(withDuration: animationDuration, animations: {
                    self.expandThumbholder()
                    
                    self.alpha = 1.0
                    self.transform = CGAffineTransform(scaleX: 1, y: 1);
                    self.bounds = self.thumbHolderView.frame.union(self.thumbHolderTailView.frame)
                    self.updateCenterOffsetForTransformedSize()
                })
                
                UIView.animate(withDuration: animationDuration, delay: animationDuration, options: UIViewAnimationOptions(), animations: {
                    self.titleLabel.alpha = CGFloat(1.0)
                    self.headphonesIcon.alpha = CGFloat(1.0)
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
                //thumbImageView.loadImageAsynchronously(fromUrl: annotation.imageUrl, withCropRect: annotation.object.thumbnailCropRect)
				thumbImageView.kf.setImage(with: annotation.thumbnailUrl)
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
            thumbHolderTailView.removeFromSuperview()
            thumbImageView.removeFromSuperview()
            
            thumbImageView.cancelLoading()
            thumbImageView.image = nil
            imageLoaded = false
            
            
            layer.zPosition = Common.Map.AnnotationZPosition.objectsDeselected.rawValue + CGFloat(objectAnnotation!.floor)
            break
            
        case .maximized:
            addSubview(thumbHolderTailView)
            addSubview(thumbImageView)
            
            loadImage()
            
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
                self.bounds = self.thumbHolderView.frame
                break
                
            case .maximized:
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.bounds = self.thumbHolderView.frame.union(self.thumbHolderTailView.frame)
            }
            
            self.updateCenterOffsetForTransformedSize()
        }) 
    }
}

// MARK: Gesture Recognizers
extension MapObjectAnnotationView {
    @objc internal func playButtonWasTapped(_ gesture:UIGestureRecognizer) {
        if isSelected {
            delegate?.mapObjectAnnotationViewPlayPressed(self)
        }
    }
}
