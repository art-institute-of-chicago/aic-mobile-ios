/*
 Abstract:
 Main view for Objects
*/

import UIKit
import Alamofire
import SnapKit

class ObjectView: UIView {
    // MARK: Properties
    var hasSetContent = false
    
    let miniAudioPlayerView = MiniAudioPlayerView()
    let miniAudioPlayerViewHeight:CGFloat = 40
    
    private let imageInsets = UIEdgeInsetsMake(50, 10, 10, 10)
    private let imageMinHeightRatio:CGFloat = 0.74666667
    private let imageMaxHeightRatio:CGFloat = 0.96
    private var heightConstraint: Constraint? = nil
    
    let imageViewHolder = UIView()
    let imageViewGradientLayer = CAGradientLayer()
    let imageView = UIImageView()
    let scrollView = UIScrollView()
    let scrollViewContentView = UIView()
    
    let audioPlayerView = AudioPlayerView()
    
    let collapseButton = UIButton()
    
    private let contentViewHolder = UIView()
    private let objectInfoContentView = ObjectInfoView()
    private let relatedToursContentView = ObjectRelatedToursView()
    private let transcriptContentView = ObjectTranscriptView()
    private let creditsContentView = ObjectCreditsView()
    
    var didSetupConstraints = false
    
    init() {
        super.init(frame:CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + miniAudioPlayerViewHeight))
        backgroundColor = UIColor.white
        
        //Configure
        collapseButton.backgroundColor = UIColor.clear
        collapseButton.setImage(#imageLiteral(resourceName: "collapse"), for: UIControlState())
        
        scrollView.frame = UIScreen.main.bounds
        scrollView.frame.origin.y = miniAudioPlayerView.frame.height
        
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.clipsToBounds = true
        
        imageView.layer.masksToBounds = false;
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0);
        imageView.layer.shadowRadius = 5;
        imageView.layer.shadowOpacity = 0.5;
        
        imageViewGradientLayer.colors = [UIColor.aicAudiobarColor().cgColor, UIColor.aicLightGrayColor().cgColor]
        imageViewGradientLayer.locations = [0.0, 1.0]
        imageViewHolder.layer.addSublayer(imageViewGradientLayer)
        
        collapseButton.backgroundColor = UIColor.clear
        collapseButton.setImage(#imageLiteral(resourceName: "collapse"), for: UIControlState())
        collapseButton.contentMode = UIViewContentMode.center
        collapseButton.frame.size = CGSize(width: 44, height: 44)
        
        contentViewHolder.backgroundColor = UIColor.white
        
        transcriptContentView.enableCollapsing()
        
        // Add Subviews
        imageViewHolder.addSubview(imageView)
        
        scrollViewContentView.addSubview(contentViewHolder)
        scrollViewContentView.addSubview(imageViewHolder)
        scrollViewContentView.addSubview(audioPlayerView)
        
        scrollView.addSubview(scrollViewContentView)
        
        addSubview(miniAudioPlayerView)
        addSubview(scrollView)
        addSubview(collapseButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageViewHolder.layoutIfNeeded()
        imageViewGradientLayer.frame = imageViewHolder.bounds
        imageViewGradientLayer.setNeedsDisplay()
    }
    
    func display(object:AICObjectModel) {
        display(object: object, audioFile: object.audioFiles!.first!)
    }
    
    func display(tour:AICTourModel, atStopIndex stopIndex:Int) {
        let stop = tour.stops[stopIndex]
        display(object: stop.object, audioFile: stop.audio, onTour:tour)
    }
    
    private func display(object:AICObjectModel, audioFile:AICAudioFileModel, onTour:AICTourModel? = nil) {
        reset()
        
        var contentViewSubviews:[ObjectContentSectionView] = []
        
        if let tombstone = object.tombstone {
            objectInfoContentView.set(info: tombstone)
            contentViewSubviews.append(objectInfoContentView)
        }
        
        // Add related tours subview if there are any relate tours
        let excludedTour = Common.Testing.filterOutRelatedTours ? onTour : nil
        let relatedTours = AppDataManager.sharedInstance.getRelatedTours(forObject: object, excludingTour: excludedTour)
        
        if !relatedTours.isEmpty {
            relatedToursContentView.set(relatedTours: relatedTours)
            contentViewSubviews.append(relatedToursContentView)
        }
        
        transcriptContentView.set(transcript: audioFile.transcript)
        contentViewSubviews.append(transcriptContentView)
        
        if object.credits != nil || object.imageCopyright != nil {
            creditsContentView.set(credits: object.credits, imageCopyright: object.imageCopyright)
            contentViewSubviews.append(creditsContentView)
        }
        
        addInfoContent(subviews:contentViewSubviews)
        updateConstraints()
    }
    
    func display(tourOverview:AICTourOverviewModel) {
        reset()
        
        var contentViewSubviews:[ObjectContentSectionView] = []
        
        objectInfoContentView.set(info: tourOverview.description)
        contentViewSubviews.append(objectInfoContentView)
        
        transcriptContentView.set(transcript: tourOverview.audio.transcript)
        contentViewSubviews.append(transcriptContentView)
        
        creditsContentView.set(credits: tourOverview.credits, imageCopyright: nil)
        contentViewSubviews.append(creditsContentView)
        
        addInfoContent(subviews:contentViewSubviews)
        updateConstraints()
    }
    
    // Add the content views to the holder
    private func addInfoContent(subviews:[ObjectContentSectionView]) {
        for view in subviews {
            view.topLine.isHidden = (view == subviews.first)
            contentViewHolder.addSubview(view)
        }
        
        hasSetContent = true
    }
    
    private func reset() {
        miniAudioPlayerView.reset()
        audioPlayerView.reset()
        
        // Clear out the previous image
        self.imageView.image = nil
        
        // Clear out all of the content
        for subview in contentViewHolder.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func setImage(_ image:UIImage) {
        // Get the dominant colors for letterboxing, then set the image
        image.getColors(completionHandler: { (colors) in
            // Set the image
            self.imageView.image = image
            
            // Find the new height for the image
            var imageHeightRatio = image.size.height/image.size.width
            imageHeightRatio = clamp(val: imageHeightRatio, minVal: self.imageMinHeightRatio, maxVal: self.imageMaxHeightRatio)
            
            // Set the constraint
            self.heightConstraint?.deactivate()
            self.imageViewHolder.snp.makeConstraints({ (make) -> Void in
                self.heightConstraint = make.height.equalTo(self.imageView.snp.width).multipliedBy(imageHeightRatio).constraint
            })
            
            self.imageViewGradientLayer.colors = [colors.backgroundColor.cgColor, UIColor.aicLightGrayColor().cgColor]
            self.imageViewGradientLayer.setNeedsDisplay()
            
            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            })
        })
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            miniAudioPlayerView.snp.remakeConstraints { (make) -> Void in
                make.top.left.right.equalTo(miniAudioPlayerView.superview!)
                make.height.equalTo(miniAudioPlayerViewHeight)
            }
            
            // Scroll Views
            scrollView.snp.remakeConstraints { (make) -> Void in
                make.left.right.bottom.equalTo(scrollView.superview!)
                make.top.equalTo(miniAudioPlayerView.snp.bottom)
            }
            
            scrollViewContentView.snp.remakeConstraints { (make) -> Void in
                make.edges.equalTo(scrollView)
                make.width.equalTo(scrollView)
                make.bottom.equalTo(contentViewHolder) // This makes the scroll view expand to the size of the content!
            }
            
            // Image + Audio Player
            imageView.snp.remakeConstraints { (make) -> Void in
                make.edges.equalTo(imageView.superview!).inset(imageInsets)
            }
            
            imageViewHolder.snp.makeConstraints({ (make) -> Void in
                make.left.right.equalTo(scrollView)
                make.top.equalTo(scrollViewContentView)
                self.heightConstraint = make.height.equalTo(imageView.snp.width).multipliedBy(imageMaxHeightRatio).constraint
            })
            
            audioPlayerView.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(imageViewHolder.snp.bottom)
                make.left.right.equalTo(audioPlayerView.superview!)
            }
            
            // Content Views
            contentViewHolder.snp.remakeConstraints({ (make) -> Void in
                make.top.equalTo(audioPlayerView.snp.bottom).priority(Common.Layout.Priority.high.rawValue)
                make.left.right.equalTo(contentViewHolder.superview!)
            })
            
            didSetupConstraints = true
        }
        
        
        for (index, view) in contentViewHolder.subviews.enumerated() {
            let view = view as! ObjectContentSectionView
            view.snp.remakeConstraints({ (make) -> Void in
                if(index == 0) {
                    make.top.equalTo(view.superview!)
                } else {
                    make.top.equalTo(contentViewHolder.subviews[index-1].snp.bottom)
                }
                
                if view == contentViewHolder.subviews.last {
                    make.bottom.equalTo(contentViewHolder)
                }
                
                make.left.right.equalTo(view.superview!)
            })
        }
    
        // Collapse button
        collapseButton.snp.remakeConstraints { (make) -> Void in
            make.right.equalTo(self.snp.right)
            make.top.equalTo(miniAudioPlayerView.snp.bottom)
            make.size.equalTo(collapseButton.frame.size)
        }
    
        super.updateConstraints()
    }
}
