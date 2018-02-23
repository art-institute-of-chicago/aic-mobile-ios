//
//  AudioPlayerNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/2/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Alamofire
import Kingfisher

class AudioPlayerNavigationController : CardNavigationController {
    var audioInfoVC: AudioInfoViewController = AudioInfoViewController()
    let miniAudioPlayerView: MiniAudioPlayerView = MiniAudioPlayerView()
	
	let remoteSkipTime: Int = 10 // Number of seconds to skip forward/back wiht MPRemoteCommandCenter seek
    
    // AVPlayer
    fileprivate let avPlayer = AVPlayer()
    private var audioProgressTimer: Timer?
    private var audioPlayerProgressTimer: Timer? = nil
	
	var currentArtwork: AICObjectModel? = nil
    var currentAudioFile: AICAudioFileModel? = nil
    var currentAudioFileMaxProgress: CGFloat = 0
	var selectedLanguage: Common.Language? = nil
    
    var isUpdatingObjectViewProgressSlider = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Close State as MiniPlayer
        closedState = .mini_player
        
        // Add main VC as subview to rootVC
        audioInfoVC.willMove(toParentViewController: rootVC)
        rootVC.view.addSubview(audioInfoVC.view)
        audioInfoVC.didMove(toParentViewController: rootVC)
        
        // Add subviews
        rootVC.view.addSubview(miniAudioPlayerView)
        
        createViewConstraints()
		
		// Language Selector Delegate
		audioInfoVC.languageSelector.delegate = self
		
        // Mini Player Tap and Close Events
        let miniAudioPlayerTap = UITapGestureRecognizer(target: self, action:#selector(miniAudioPlayerTapped))
        miniAudioPlayerView.addGestureRecognizer(miniAudioPlayerTap)
        
        miniAudioPlayerView.closeButton.addTarget(self, action: #selector(miniAudioPlayerCloseButtonPressed(button:)), for: .touchUpInside)
        
        // Audio Player Slider
        audioInfoVC.audioPlayerView.slider.addTarget(self, action: #selector(audioPlayerSliderValueChanged(slider:)), for: UIControlEvents.valueChanged)
        audioInfoVC.audioPlayerView.slider.addTarget(self, action: #selector(audioPlayerSliderStartedSliding(slider:)), for: UIControlEvents.touchDown)
        audioInfoVC.audioPlayerView.slider.addTarget(self, action: #selector(audioPlayerSliderFinishedSliding(slider:)), for: [UIControlEvents.touchUpInside, UIControlEvents.touchUpOutside, UIControlEvents.touchCancel]
        )
        
        // Play/Pause Button
		miniAudioPlayerView.playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed(button:)), for: .touchUpInside)
        audioInfoVC.audioPlayerView.playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed(button:)), for: .touchUpInside)
		
        // AV Session
        configureAVAudioSession()
        NotificationCenter.default.addObserver(self, selector: #selector(configureAVAudioSession), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    func createViewConstraints() {
        miniAudioPlayerView.autoPinEdge(.top, to: .top, of: rootVC.view)
        miniAudioPlayerView.autoPinEdge(.leading, to: .leading, of: rootVC.view)
        miniAudioPlayerView.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
        miniAudioPlayerView.autoSetDimension(.height, toSize: Common.Layout.miniAudioPlayerHeight)
        
        audioInfoVC.view.autoPinEdge(.top, to: .top, of: rootVC.view, withOffset: contentTopMargin)
        audioInfoVC.view.autoPinEdge(.leading, to: .leading, of: rootVC.view)
        audioInfoVC.view.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
        audioInfoVC.view.autoSetDimension(.height, toSize: Common.Layout.cardContentHeight + Common.Layout.tabBarHeight - contentTopMargin)
    }
    
    // Progress Bar Color
    
    func setProgressBarColor(color: UIColor) {
		miniAudioPlayerView.setProgressBarColor(color: color)
    }
    
    // MARK: Play Audio
    
	func playArtworkAudio(artwork: AICObjectModel, audio: AICAudioFileModel) {
		currentArtwork = artwork
		
        if load(audioFile: audio, coverImageURL: artwork.imageUrl as URL) {
			miniAudioPlayerView.reset()
			audioInfoVC.setArtworkContent(artwork: artwork, audio: audio)
        }
    }
	
	func playTourOverviewAudio(tour: AICTourModel) {
		// set correct language on audio
		var audio = tour.overview.audio
		audio.language = tour.language
		
		if load(audioFile: audio, coverImageURL: tour.imageUrl as URL) {
			miniAudioPlayerView.reset()
			audioInfoVC.setTourOverviewContent(tourOverview: tour.overview)
		}
	}
    
    // MARK: Load Audio
    
    private func load(audioFile: AICAudioFileModel, coverImageURL: URL) -> Bool {
		
        if let currentAudioFile = currentAudioFile {
            // If it's a new artwork, log analytics
            if (audioFile.nid != currentAudioFile.nid) {
				// Log analytics
				// GA only accepts int values, so send an int from 1-10
				let progressValue: Int = Int(currentAudioFileMaxProgress * 100)
				AICAnalytics.objectViewAudioItemPlayedEvent(audioItem: currentAudioFile, pctComplete: progressValue)
            }
			// If it's same nid and language, don't load audio
			else if selectedLanguage == nil {
				return false
			}
        }
		
        currentAudioFile = audioFile
        currentAudioFileMaxProgress = 0
		
		// even if the player defaults to a language
		// check to see if the user changed it
		if selectedLanguage != nil {
			currentAudioFile!.language = selectedLanguage!
		}
        
        // Clear out current player
        audioPlayerProgressTimer?.invalidate()
        
        // Reset visuals
        miniAudioPlayerView.resetProgress()
        audioInfoVC.audioPlayerView.resetProgress()
        
        // Set the player view to show loading status
        showLoadingMessage()
		
		// Load the file
		let asset = AVURLAsset(url: currentAudioFile!.url)
		asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
			let error:NSErrorPointer = nil
			let status = asset.statusOfValue(forKey: "tracks", error: error)
			
			// Make sure we're on the main thread for UI Updates (alert, timer, etc.)
			DispatchQueue.main.async(execute: {
				switch status {
				case .failed, .cancelled:
					self.showLoadError(forAudioFile: audioFile, coverImageURL: coverImageURL)
					break
					
				case .loaded:
					// Create Audio Player
					let playerItem = AVPlayerItem(asset: asset)
					NotificationCenter.default.addObserver(self, selector: #selector(AudioPlayerNavigationController.audioPlayerDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
					
					// Set the item as our player's current item
					self.avPlayer.replaceCurrentItem(with: playerItem)
					
					// Show the audio file
					self.showAudioControls()
					
					// Create NSTimer to check for audio update progress and update as needed
					if self.audioProgressTimer == nil {
						self.audioPlayerProgressTimer = Timer.scheduledTimer(timeInterval: 0.25,
																			 target: self,
																			 selector: #selector(AudioPlayerNavigationController.updateAudioPlayerProgress),
																			 userInfo: nil,
																			 repeats: true
						)
					}
					
					// Retrieve cover image
					KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: coverImageURL, cacheKey: coverImageURL.absoluteString), options: KingfisherManager.shared.defaultOptions, progressBlock: nil, completionHandler: { (image, error, cacheType, imageUrl) in
						if image == nil {
							self.audioInfoVC.imageView.image = nil
							return
						}
						
						// MPMediaItemPropertyArtwork
						let artworkMediaItem = MPMediaItemArtwork.init(boundsSize: image!.size, requestHandler: { (size) -> UIImage in
							return image!
						})
						
						// Set the MPNowPlaying information
						let songInfo: [String : AnyObject] = [
							MPMediaItemPropertyTitle: NSString(string: self.currentAudioFile!.trackTitle),
							MPMediaItemPropertyArtist: NSString(string: "Art Institute of Chicago"),
							MPMediaItemPropertyArtwork: artworkMediaItem,
							MPMediaItemPropertyPlaybackDuration: NSNumber(floatLiteral: (CMTimeGetSeconds(self.avPlayer.currentItem!.asset.duration))),
							MPMediaItemPropertyAlbumTrackCount: NSNumber(floatLiteral: 0),
							MPNowPlayingInfoPropertyPlaybackQueueIndex: NSNumber(floatLiteral: 0),
							MPNowPlayingInfoPropertyPlaybackQueueCount: NSNumber(floatLiteral: 0),
							MPNowPlayingInfoPropertyPlaybackRate: NSInteger(1.0) as AnyObject
						]
						
						MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
					})
					
					// Auto-play on load
					self.play()
					
					break
					
				default:
					print("Unknown error")
				}
			})
		}
        
        return true
    }
    
    private func showLoadError(forAudioFile audioFile: AICAudioFileModel, coverImageURL: URL) {
		// Preset a UIAlertView that allows the user to try to load the file.
        let alertView = UIAlertController(title: "Load Failure Title".localized(using: "AudioPlayer"), message: "Load Failure Message".localized(using: "AudioPlayer"), preferredStyle: .alert)
		
		// Retry Action
        alertView.addAction(UIAlertAction(title: "Load Failure Reload Button Title".localized(using: "AudioPlayer"), style: .default, handler: { (alertAction) -> Void in
            self.currentAudioFile = nil
            _ = self.load(audioFile: audioFile, coverImageURL: coverImageURL)
        }))
		
		// Cancel Action
		alertView.addAction(UIAlertAction(title: "Load Failure Cancel Button Title".localized(using: "AudioPlayer"), style: .cancel, handler: { (alertAction) -> Void in
			self.hide()
		}))
		
        self.present(alertView, animated: true, completion: nil)
    }
    
    // Set the loading status as the track title
    private func showLoadingMessage() {
        let localizedLoadingMessage = "Loading Message".localized(using: "AudioPlayer")
        miniAudioPlayerView.showLoadingMessage(message: localizedLoadingMessage)
        audioInfoVC.audioPlayerView.showLoadingMessage(message: localizedLoadingMessage)
    }
    
    private func showAudioControls() {
        miniAudioPlayerView.showTrackTitle(title: currentAudioFile!.trackTitle)
        audioInfoVC.audioPlayerView.showTrackTitle(title: currentAudioFile!.trackTitle)
    }
    
    // MARK: Audio Playback
    
    @objc internal func configureAVAudioSession() {
        do {
            // Determine playback category based on bluetooth connection to avoid HFP playback through A2DP headphones
            let bluetoothConnected = (AVAudioSession.sharedInstance().currentRoute.outputs.filter({$0.portType == AVAudioSessionPortBluetoothA2DP || $0.portType == AVAudioSessionPortBluetoothHFP }).first != nil)
            let playbackCategory = bluetoothConnected ? AVAudioSessionCategoryPlayback : AVAudioSessionCategoryPlayAndRecord
            
            // Init session with correct category
            try AVAudioSession.sharedInstance().setCategory(playbackCategory, with: AVAudioSessionCategoryOptions.allowBluetooth)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Could not initialize audio session")
        }
    }
    
    private func initializeMPRemote() {
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = false
        MPRemoteCommandCenter.shared().seekBackwardCommand.isEnabled = false
        
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = false
        MPRemoteCommandCenter.shared().seekForwardCommand.isEnabled = false
        
        // You must also register for any other command in order to take control
        // of the command center, or else disabling other commands does not work.
        // For example:
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true;
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(play))
        
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(pause))
        
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals = [NSNumber(value: remoteSkipTime)]
        MPRemoteCommandCenter.shared().skipForwardCommand.addTarget(self, action: #selector(skipForward))
        
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipBackwardCommand.preferredIntervals = [NSNumber(value: remoteSkipTime)]
        MPRemoteCommandCenter.shared().skipBackwardCommand.addTarget(self, action: #selector(skipBackward))
    }
    
    @objc internal func play() {
        if let currentItem = avPlayer.currentItem {
            // If we are at the end, start from the beginning
            let currentTime = floor(CMTimeGetSeconds(currentItem.currentTime()))
            let duration = floor(CMTimeGetSeconds(currentItem.asset.duration))
			
			if duration < 1 {
				if let audio = currentAudioFile {
					if let artwork = currentArtwork {
						showLoadError(forAudioFile: audio, coverImageURL: artwork.imageUrl)
					}
				}
				return
			}
			
            if currentTime >= duration {
                currentItem.seek(to: CMTime(seconds: 0.0, preferredTimescale: avPlayer.currentItem!.duration.timescale))
            }
            
            // Play
            avPlayer.play()
            synchronizePlayPauseButtons(isPlaying: true)
            
            // Enable proximity sensing, needed when user is holding phone to their ear to listen to audio
            UIDevice.current.isProximityMonitoringEnabled = true
        }
    }
    
    @objc internal func pause() {
        if avPlayer.currentItem != nil {
            avPlayer.pause()
            synchronizePlayPauseButtons(isPlaying: false)
            
            var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
            info![MPNowPlayingInfoPropertyPlaybackRate] = NSInteger(0.0)
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            
            // Enable proximity sensing, needed when user is holding phone to their ear to listen to audio
            UIDevice.current.isProximityMonitoringEnabled = false
        }
    }
    
    internal func seekToTime(_ timeInSeconds:Double) {
        if let currentItem = avPlayer.currentItem {
            currentItem.seek(to: CMTime(seconds: timeInSeconds, preferredTimescale: currentItem.duration.timescale))
            updateAudioPlayerProgress()
        }
    }
    
    @objc internal func skipForward() {
        if let currentItem = avPlayer.currentItem {
            let duration = CMTimeGetSeconds(currentItem.duration)
            let currentTime = CMTimeGetSeconds(avPlayer.currentTime())
            var skipTime = currentTime + Double(remoteSkipTime)
            
            if skipTime > duration {
                skipTime = duration
            }
            
            seekToTime(skipTime)
        }
    }
    
    @objc internal func skipBackward() {
        if avPlayer.currentItem != nil {
            let currentTime = CMTimeGetSeconds(avPlayer.currentTime())
            var skipTime = currentTime - Double(remoteSkipTime)
            if skipTime < 0{
                skipTime = 0
            }
            
            seekToTime(skipTime)
        }
    }
    
    fileprivate func synchronizePlayPauseButtons(isPlaying: Bool) {
        miniAudioPlayerView.playPauseButton.isSelected = isPlaying
        audioInfoVC.audioPlayerView.playPauseButton.isSelected = isPlaying
    }
    
    // Show/Hide
    
    override func showFullscreen() {
        super.showFullscreen()
        self.view.backgroundColor = .aicDarkGrayColor
        self.downArrowImageView.alpha = 1.0
        self.miniAudioPlayerView.alpha = 0.0
    }
    
    override func showMiniPlayer() {
        super.showMiniPlayer()
        UIView.animate(withDuration: 0.25) {
            self.downArrowImageView.alpha = 0.0
        }
    }
	
	override func cardWillShowMiniPlayer() {
		audioInfoVC.languageSelector.close()
	}
	
    override func cardDidShowMiniPlayer() {
        UIView.animate(withDuration: 0.25) {
            self.miniAudioPlayerView.alpha = 1.0
        }
        UIView.animate(withDuration: 0.25, delay: 0.25, animations: {
            self.view.backgroundColor = .clear
        }, completion: nil)
    }
	
	override func cardWillHide() {
		audioInfoVC.languageSelector.close()
	}
}

// Pan Gesture
extension AudioPlayerNavigationController {
    override internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == cardPanGesture {
            if audioInfoVC.scrollView.contentOffset.y <= 0 {
                return true
            }
        }
        return false
    }
}

// MARK: Events

extension AudioPlayerNavigationController {
    // Received event from lock screen (remote control)
    override func remoteControlReceived(with event: UIEvent?) {
        // Make sure an audio file is loaded
        if avPlayer.currentItem != nil {
            // If it is, respond to event
            if event?.type == UIEventType.remoteControl {
                switch (event?.subtype)! {
                    
                // Play/Pause buttons
                case UIEventSubtype.remoteControlPlay:
                    play()
                    break
                    
                case UIEventSubtype.remoteControlPause:
                    pause()
                    break
                    
                // Headphone remote control toggle
                case UIEventSubtype.remoteControlTogglePlayPause:
                    if avPlayer.rate != 0 && avPlayer.error == nil {
                        pause()
                    } else {
                        play()
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    // Update the progress for the mini and regular audio players
    // every frame
    @objc internal func updateAudioPlayerProgress() {
        
        if avPlayer.currentItem != nil && avPlayer.currentItem!.status == AVPlayerItemStatus.readyToPlay {
            let progress = CMTimeGetSeconds(avPlayer.currentTime())
            let duration = CMTimeGetSeconds(avPlayer.currentItem!.asset.duration)
            
            // Record the progress for analytics
            let pct = CGFloat(progress/duration)
            if pct > currentAudioFileMaxProgress {
                currentAudioFileMaxProgress = pct
            }
            
            // Update the progress bar views
            audioInfoVC.audioPlayerView.updateProgress(progress: progress, duration: duration, setSliderValue: !isUpdatingObjectViewProgressSlider)
			miniAudioPlayerView.updateProgress(progress: progress, duration: duration)
            
            // Update now playing with progress
			if var info = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            	info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSInteger(progress)
            	DispatchQueue.main.async {
                	MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            	}
			}
        }
    }
    
    @objc internal func audioPlayerDidFinishPlaying(_ notification:Notification) {
        synchronizePlayPauseButtons(isPlaying: false)
    }
    
    // Audio player Slider Events
    
    @objc internal func audioPlayerSliderStartedSliding(slider: UISlider) {
        // Stop the progress from updating, otherwise the two funcs fight
        isUpdatingObjectViewProgressSlider = true
    }
    
    
    @objc internal func audioPlayerSliderValueChanged(slider: UISlider) {
        if let currentItem = avPlayer.currentItem {
            let newTime = CMTimeGetSeconds(currentItem.asset.duration) * Double(audioInfoVC.audioPlayerView.slider.value)
            seekToTime(newTime)
            updateAudioPlayerProgress()
        }
    }
    
    @objc internal func audioPlayerSliderFinishedSliding(slider: UISlider) {
        isUpdatingObjectViewProgressSlider = false
        updateAudioPlayerProgress()
    }
    
    @objc internal func miniAudioPlayerCloseButtonPressed(button: UIButton) {
		pause()
		hide()
		currentAudioFile = nil
		// TODO: remove track from MPNowPlayingInfoCenter and RemoteControl
    }
    
    @objc internal func miniAudioPlayerTapped() {
        showFullscreen()
    }
	
	@objc internal func playPauseButtonPressed(button: UIButton) {
		// Play
		if button.isSelected == false {
			if avPlayer.currentItem?.duration == avPlayer.currentTime() {
				seekToTime(0)
			}
			play()
		}
		// Pause
		else {
			pause()
		}
	}
}

// MARK: LanguageSelectorViewDelegate

extension AudioPlayerNavigationController : LanguageSelectorViewDelegate {
	func languageSelectorDidSelect(language: Common.Language) {
		if let _ = currentAudioFile {
			selectedLanguage = language // set the language to indicate the language has been selected using the LanguageSelector
			if load(audioFile: currentAudioFile!, coverImageURL: currentArtwork!.imageUrl as URL) {
				miniAudioPlayerView.reset()
				audioInfoVC.setArtworkContent(artwork: currentArtwork!, audio: currentAudioFile!)
			}
			selectedLanguage = nil
		}
	}
}
