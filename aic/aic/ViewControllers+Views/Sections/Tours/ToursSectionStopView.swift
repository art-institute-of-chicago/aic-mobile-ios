/*
 Abstract:
 An individual stop on a tour, represented as an item in the tours scroller
*/

import UIKit
import ImageIO
import Alamofire

protocol ToursSectionStopViewDelegate : class {
    func stopViewWasSelected(stopView:ToursSectionStopView)
}

class ToursSectionStopView: BaseView {
    weak var delegate:ToursSectionStopViewDelegate?
    
    fileprivate var imageURL:URL
    let thumbnailSize:CGSize
    let thumbnailImageView = AICImageView()
    let playButton = UIButton()
    let contentView = UIView()
    
    var thumbnailCropRect: CGRect?
    
    init(size:CGSize, imageUrl:URL, cropRect: CGRect?) {
        self.thumbnailSize = size
        self.imageURL = imageUrl
        self.thumbnailCropRect = cropRect
        super.init(frame:CGRect.zero)
        
        thumbnailImageView.contentMode = UIViewContentMode.scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        thumbnailImageView.delegate = self
        
        playButton.setImage(UIImage(named:"tourItemPlayButton"), for: UIControlState())
        playButton.isHidden = true
        
        // Add subviews
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(playButton)
        
        addSubview(contentView)
        
        //Add Gestures
        let playButtonTap = UITapGestureRecognizer(target: self, action:#selector(ToursSectionStopView.playButtonTapped))
        playButton.addGestureRecognizer(playButtonTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        thumbnailImageView.loadImageAsynchronously(fromUrl: self.imageURL, withCropRect: thumbnailCropRect)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            contentView.snp.makeConstraints({ (make) -> Void in
                make.edges.equalTo(contentView.superview!)
            })
            
            thumbnailImageView.snp.makeConstraints({ (make) -> Void in
                make.edges.equalTo(thumbnailImageView.superview!).priority(Common.Layout.Priority.low.rawValue)
                make.size.equalTo(thumbnailSize)
            })
            
            playButton.snp.makeConstraints({ (make) -> Void in
                make.edges.equalTo(thumbnailImageView)
            })
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}

// MARK: Gesture Recognizers
extension ToursSectionStopView {
    @objc internal func playButtonTapped() {
        delegate?.stopViewWasSelected(stopView: self)
    }
}

extension ToursSectionStopView : AICImageViewDelegate {
    func aicImageViewDidFinishLoadingImageAsynchronously() {
        playButton.isHidden = false
    }
}
