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
	var tourOverviewModel: AICTourOverviewModel? = nil
    var tourModel: AICTourModel? = nil
    
    let scrollView: UIScrollView = UIScrollView()
    let imageView: UIImageView = UIImageView()
	let languageSelector: LanguageSelectorView = LanguageSelectorView()
    let audioPlayerView: AudioPlayerView = AudioPlayerView()
	let descriptionLabel: UILabel = UILabel()
	let relatedToursView = AudioInfoSectionView()
	let transcriptView = AudioInfoSectionView()
	let creditsView = AudioInfoSectionView()
    
    var imageViewHeight: NSLayoutConstraint? = nil
    let imageMaxHeight: CGFloat = 344.0
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .clear
		
		scrollView.delegate = self
		scrollView.backgroundColor = .clear
		scrollView.isScrollEnabled = true
		scrollView.showsVerticalScrollIndicator = false
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
		
		imageView.backgroundColor = .clear
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		
		descriptionLabel.font = .aicCardDescriptionFont
		descriptionLabel.numberOfLines = 0
		descriptionLabel.textColor = .white
		
		transcriptView.delegate = self
		
		creditsView.delegate = self
		
		// Add subviews
		scrollView.addSubview(imageView)
		scrollView.addSubview(languageSelector)
		scrollView.addSubview(audioPlayerView)
		scrollView.addSubview(descriptionLabel)
		scrollView.addSubview(relatedToursView)
		scrollView.addSubview(transcriptView)
		scrollView.addSubview(creditsView)
		self.view.addSubview(scrollView)
		
		createViewConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.layoutIfNeeded()
        self.scrollView.contentSize.width = self.view.frame.width
        self.scrollView.contentSize.height = creditsView.frame.origin.y + creditsView.frame.height
		
        //updateLanguage()
    }
	
	// MARK: Constraints
    
    func createViewConstraints() {
        scrollView.autoPinEdge(.top, to: .top, of: self.view)
        scrollView.autoPinEdge(.leading, to: .leading, of: self.view)
        scrollView.autoPinEdge(.trailing, to: .trailing, of: self.view)
        scrollView.autoPinEdge(.bottom, to: .bottom, of: self.view)
        
        imageView.autoPinEdge(.top, to: .top, of: scrollView, withOffset: Common.Layout.miniAudioPlayerHeight - 30.0)
        imageView.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
        imageView.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
        imageViewHeight = imageView.autoSetDimension(.height, toSize: imageMaxHeight)
        
        audioPlayerView.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 16)
        audioPlayerView.autoPinEdge(.leading, to: .leading, of: self.view)
        audioPlayerView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		languageSelector.autoSetDimensions(to: LanguageSelectorView.selectorSize)
		languageSelector.autoPinEdge(.bottom, to: .top, of: audioPlayerView, withOffset: -16)
		languageSelector.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
		
		descriptionLabel.autoPinEdge(.top, to: .bottom, of: audioPlayerView, withOffset: 32)
		descriptionLabel.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
		descriptionLabel.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
		
		relatedToursView.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 32)
		relatedToursView.autoPinEdge(.leading, to: .leading, of: self.view)
		relatedToursView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		transcriptView.autoPinEdge(.top, to: .bottom, of: relatedToursView)
		transcriptView.autoPinEdge(.leading, to: .leading, of: self.view)
		transcriptView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		creditsView.autoPinEdge(.top, to: .bottom, of: transcriptView)
		creditsView.autoPinEdge(.leading, to: .leading, of: self.view)
		creditsView.autoPinEdge(.trailing, to: .trailing, of: self.view)
    }
	
	private func updateLayout() {
		self.view.layoutSubviews()
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		
		self.scrollView.contentSize.height = creditsView.frame.origin.y + creditsView.frame.height
	}
    
	// MARK: Set Content
    
	func setArtworkContent(artwork: AICObjectModel, audio: AICAudioFileModel, tour: AICTourModel? = nil) {
		reset()
		
        artworkModel = artwork
        setImage(imageURL: artwork.imageUrl)
		if let description = artwork.tombstone {
			setDescription(description: description)
		}
		
		// Add related tours subview if there are any relate tours
		if let _ = tour {
			let excludedTour = Common.Testing.filterOutRelatedTours ? tour : nil
			let relatedTours = AppDataManager.sharedInstance.getRelatedTours(forObject: artwork, excludingTour: excludedTour)

			if !relatedTours.isEmpty {
				relatedToursView.set(relatedTours: relatedTours)
				relatedToursView.show(collapseEnabled: false)
			}
			else {
				relatedToursView.hide()
			}
		}
		else {
			relatedToursView.hide()
		}
		
		// Language
		if let _ = tour {
			if audio.availableLanguages.count > 1 {
				languageSelector.isHidden = false
				languageSelector.close()
				languageSelector.setLanguages(languages: audio.availableLanguages, defaultLanguage: audio.language)
			}
		}
		updateLanguage(language: audio.language)
		
		transcriptView.show(collapseEnabled: true)
		transcriptView.bodyTextView.text = audio.transcript
		
		var creditsString = ""
		if (artwork.credits ?? "").isEmpty == false { creditsString += artwork.credits! }
		if (artwork.imageCopyright ?? "").isEmpty == false {
			if creditsString.count > 0 { creditsString += "\n\n" }
			creditsString += artwork.imageCopyright!
		}
		
		if creditsString.isEmpty == false {
			creditsView.show(collapseEnabled: true)
			creditsView.bodyTextView.text = creditsString
		}
		else {
			creditsView.hide()
		}
		
		updateLayout()
    }
	
	func updateAudioContent(audio: AICAudioFileModel) {
		updateLanguage(language: audio.language)
		
		transcriptView.show(collapseEnabled: true)
		transcriptView.bodyTextView.text = audio.transcript
		
		updateLayout()
	}
	
	func setTourOverviewContent(tourOverview: AICTourOverviewModel) {
		reset()
		
		tourOverviewModel = tourOverview
		setImage(imageURL: tourOverview.imageUrl)
		setDescription(description: tourOverview.description)
		
		updateLayout()
	}
	
	func showLoadingMessage(message: String) {
		audioPlayerView.showLoadingMessage(message: message)
		updateLayout()
	}
	
	func showTrackTitle(title: String) {
		audioPlayerView.showTrackTitle(title: title)
		updateLayout()
	}
	
	// Language
	private func updateLanguage(language: Common.Language) {
		creditsView.titleLabel.text = "Credits".localized(using: "AudioPlayer")
		transcriptView.titleLabel.text = "Transcript".localized(using: "AudioPlayer")
	}
    
    private func setImage(imageURL: URL) {
		imageView.kf.indicatorType = .activity
		imageView.kf.setImage(with: imageURL)
//		imageView.kf.setImage(with: imageURL, placeholder: nil, options: nil, progressBlock: nil) { image, error, cacheType, imageURL in
//            // calculate image dimension to adjust height of imageview
//            if let _ = image {
//                let imageAspectRatio = image!.size.width / image!.size.height
//                let viewAspectRatio = self.imageView.frame.width / self.imageViewHeight!.constant
//
//                if imageAspectRatio > viewAspectRatio {
//                    self.imageViewHeight!.constant = self.imageView.frame.width * (image!.size.height / image!.size.width)
//                }
//                else {
//                    self.imageViewHeight!.constant = self.imageMaxHeight
//                }
//
//				self.updateLayout()
//            }
//        }
		updateLayout()
    }
	
	private func setDescription(description: String) {
		descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: description, font: .aicCardDescriptionFont, lineHeight: 22)
	}
	
	func reset() {
		audioPlayerView.reset()
		imageView.image = nil
		descriptionLabel.text = ""
		languageSelector.close()
		languageSelector.isHidden = true
		relatedToursView.hide()
		creditsView.hide()
		transcriptView.hide()
	}
}

// MARK: Scroll Delegate
extension AudioInfoViewController : UIScrollViewDelegate {
    /// Avoid bouncing at the top of the TableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollView.bounces = (scrollView.contentOffset.y > 20)
    }
}

// MARK: AudioInfoSectionViewDelegate
extension AudioInfoViewController : AudioInfoSectionViewDelegate {
	func audioInfoSectionDidUpdateHeight(audioInfoSectionView: AudioInfoSectionView) {
		updateLayout()
	}
}


