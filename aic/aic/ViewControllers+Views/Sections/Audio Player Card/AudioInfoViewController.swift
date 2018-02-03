//
//  AudioPlayerTableViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/3/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class AudioInfoViewController : UIViewController {
    var artworkModel: AICObjectModel? = nil
    var tourModel: AICTourModel? = nil
    
    let scrollView: UIScrollView = UIScrollView()
    
    let imageView: UIImageView = UIImageView()
    let audioPlayerView: AudioPlayerView = AudioPlayerView()
    
    var imageViewHeight: NSLayoutConstraint? = nil
    let imageMaxHeight: CGFloat = 344.0
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        // Add subviews
        self.view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(audioPlayerView)
        
        createViewConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.layoutIfNeeded()
        self.scrollView.contentSize.width = self.view.frame.width
        self.scrollView.contentSize.height = audioPlayerView.frame.origin.y + audioPlayerView.frame.height
        
        //updateLanguage()
    }
    
    func createViewConstraints() {
        scrollView.autoPinEdge(.top, to: .top, of: self.view)
        scrollView.autoPinEdge(.leading, to: .leading, of: self.view)
        scrollView.autoPinEdge(.trailing, to: .trailing, of: self.view)
        scrollView.autoPinEdge(.bottom, to: .bottom, of: self.view)
        
        imageView.autoPinEdge(.top, to: .top, of: self.view, withOffset: Common.Layout.miniAudioPlayerHeight - 30.0)
        imageView.autoPinEdge(.leading, to: .leading, of: self.view)
        imageView.autoPinEdge(.trailing, to: .trailing, of: self.view)
        imageViewHeight = imageView.autoSetDimension(.height, toSize: imageMaxHeight)
        
        audioPlayerView.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 16)
        audioPlayerView.autoPinEdge(.leading, to: .leading, of: self.view)
        audioPlayerView.autoPinEdge(.trailing, to: .trailing, of: self.view)
        audioPlayerView.autoSetDimension(.height, toSize: audioPlayerView.height)
    }
    
    // Set Content
    
    func setArtworkContent(artwork: AICObjectModel) {
        artworkModel = artwork
        setContent(imageURL: artwork.imageUrl)
    }
    
    func setTourContent(tour: AICTourModel, stopIndex: Int) {
        tourModel = tour
        setContent(imageURL: tour.imageUrl)
    }
    
    private func setContent(imageURL: URL) {
        setImage(imageURL: imageURL)
    }
    
    private func setImage(imageURL: URL) {
        imageView.kf.setImage(with: imageURL, placeholder: nil, options: nil, progressBlock: nil) { image, error, cacheType, imageURL in
            // calculate image dimension to adjust height of imageview
            if let _ = image {
                let imageAspectRatio = image!.size.width / image!.size.height
                let viewAspectRatio = self.imageView.frame.width / self.imageViewHeight!.constant
                
                if imageAspectRatio > viewAspectRatio {
                    self.imageViewHeight!.constant = self.imageView.frame.width * (image!.size.height / image!.size.width)
                }
                else {
                    self.imageViewHeight!.constant = self.imageMaxHeight
                }
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: Scroll Delegate
extension AudioInfoViewController : UIScrollViewDelegate {
    /// Avoid bouncing at the top of the TableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0) {
            scrollView.contentOffset = CGPoint.zero
        }
    }
}
