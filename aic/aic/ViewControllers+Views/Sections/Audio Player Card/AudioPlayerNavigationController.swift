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

protocol AudioPlayerNavigationControllerDelegate : class {
	func audioPlayerDidFinishPlaying(audio: AICAudioFileModel)
}

class AudioPlayerNavigationController : CardNavigationController {
	var audioInfoVC: AudioInfoViewController = AudioInfoViewController()
	let miniAudioPlayerView: MiniAudioPlayerView = MiniAudioPlayerView()
	
	weak var sectionDelegate: AudioPlayerNavigationControllerDelegate? = nil
	
	let remoteSkipTime: Int = 10 // Number of seconds to skip forward/back with MPRemoteCommandCenter seek
	
	// AVPlayer
	fileprivate let avPlayer = AVPlayer()
	private var audioProgressTimer: Timer?
	private var audioPlayerProgressTimer: Timer? = nil
	
	// Audio
	var currentAudioFile: AICAudioFileModel? = nil
	var currentAudioFileMaxProgress: CGFloat = 0
	var selectedLanguage: Common.Language? = nil
	
	// Info
	var currentTourLanguage: Common.Language = .english
	var currentTourStopAudioFile: AICAudioFileModel? = nil
	var currentAudioBumper: AICAudioFileModel? = nil
    var previousTrackTitle: String = ""
    var currentTrackTitle: String = "" {
        didSet {
            previousTrackTitle = oldValue
        }
    }
	var currentImageURL: URL? = nil
    
    // Analytics data
    var analyticsSource: AICAnalytics.PlaybackSource = .AudioGuide
    var analyticsArtwork: AICObjectModel? = nil
    var analyticsTour: AICTourModel? = nil

	
	var autoPlay: Bool = false
	
	var isUpdatingObjectViewProgressSlider = false
	
	// Audio Guide Number (track it to log analytics when loading fails)
	var audioGuideNumber: Int? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set Close State as MiniPlayer
		closedState = .mini_player
		
		miniAudioPlayerView.frame.origin = CGPoint.zero
		miniAudioPlayerView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.miniAudioPlayerHeight)
		
		audioInfoVC.view.frame.origin = CGPoint(x: 0, y: contentTopMargin)
		audioInfoVC.view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardContentHeight + Common.Layout.tabBarHeight - contentTopMargin)
		
		// Add main VC as subview to rootVC
		audioInfoVC.willMove(toParent: rootVC)
		rootVC.view.addSubview(audioInfoVC.view)
		audioInfoVC.didMove(toParent: rootVC)
		
		// Add subviews
		rootVC.view.addSubview(miniAudioPlayerView)
		
		// Related Tours Link
		audioInfoVC.relatedToursView.bodyTextView.delegate = self
		
		// Language Selector Delegate
		audioInfoVC.languageSelector.delegate = self
		
		// Mini Player Tap and Close Events
		let miniAudioPlayerTap = UITapGestureRecognizer(target: self, action:#selector(miniAudioPlayerTapped))
		miniAudioPlayerView.addGestureRecognizer(miniAudioPlayerTap)
		
		miniAudioPlayerView.closeButton.addTarget(self, action: #selector(miniAudioPlayerCloseButtonPressed(button:)), for: .touchUpInside)
		
		// Audio Player Slider
		audioInfoVC.audioPlayerView.slider.addTarget(self, action: #selector(audioPlayerSliderValueChanged(slider:)), for: .valueChanged)
		audioInfoVC.audioPlayerView.slider.addTarget(self, action: #selector(audioPlayerSliderStartedSliding(slider:)), for: .touchDown)
		audioInfoVC.audioPlayerView.slider.addTarget(self, action: #selector(audioPlayerSliderFinishedSliding(slider:)), for: [.touchUpInside, .touchUpOutside, .touchCancel]
		)
		
		// Play/Pause Button
		miniAudioPlayerView.playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed(button:)), for: .touchUpInside)
		audioInfoVC.audioPlayerView.playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed(button:)), for: .touchUpInside)
		
		// AV Session
		configureAVAudioSession()
		NotificationCenter.default.addObserver(self, selector: #selector(configureAVAudioSession), name: AVAudioSession.routeChangeNotification, object: nil)
		
		// Accessibility
		downArrowButton.accessibilityLabel = "Close Audio Player"
		closeButton.accessibilityLabel = "Close Audio Player"
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Set as
		self.becomeFirstResponder()
		UIApplication.shared.beginReceivingRemoteControlEvents()
		initializeMPRemote()
	}
	
	// Progress Bar Color
	
	func setProgressBarColor(color: UIColor) {
		miniAudioPlayerView.setProgressBarColor(color: color)
	}
	
	// MARK: Play Audio
	
	func playArtworkAudio(artwork: AICObjectModel, audio: AICAudioFileModel, source: AICAnalytics.PlaybackSource, audioGuideNumber: Int? = nil) {
		currentAudioBumper = nil
		currentTourStopAudioFile = nil
		
		currentTrackTitle = artwork.title
		currentImageURL = artwork.imageUrl
		
		self.autoPlay = true
		
		self.audioGuideNumber = audioGuideNumber
		
		if load(audioFile: audio, coverImageURL: artwork.imageUrl as URL) {
			miniAudioPlayerView.reset()
			audioInfoVC.setArtworkContent(artwork: artwork, audio: audio)
		}
        
        // Log analytics
        AICAnalytics.sendAudioPlayedEvent(source: source,
                                          language: audio.language,
                                          audio: audio,
                                          artwork: artwork,
                                          tour: nil)
        analyticsSource = source
        analyticsArtwork = artwork
        analyticsTour = nil
	}
	
    func playTourOverviewAudio(tour: AICTourModel, source: AICAnalytics.PlaybackSource) {
		currentTourLanguage = tour.language
		
		let nextTourStop = tour.stops.first!
		setAudioBumperFor(nextTourStop: nextTourStop)
		
		currentTourStopAudioFile = tour.audioCommentary.audioFile
		
		currentTrackTitle = tour.title
		currentImageURL = tour.imageUrl
		
		self.autoPlay = true
		
		self.audioGuideNumber = nil
		
		// set correct language on audio
		var audio = tour.audioCommentary.audioFile
		audio.language = tour.language
		
		if load(audioFile: audio, coverImageURL: tour.imageUrl as URL) {
			miniAudioPlayerView.reset()
			audioInfoVC.setTourContent(tour: tour)
		}
        
        // Log analytics
        AICAnalytics.sendAudioPlayedEvent(source: source,
                                          language: tour.language,
                                          audio: audio,
                                          artwork: nil,
                                          tour: tour)
        analyticsSource = source
        analyticsArtwork = nil
        analyticsTour = tour
	}
	
	func playTourStopAudio(tourStop: AICTourStopModel, tour: AICTourModel) {
		currentTourLanguage = tour.language
		
		if let stopIndex = tour.getIndex(forStopObject: tourStop.object) {
			if stopIndex + 1 < tour.stops.count {
				setAudioBumperFor(nextTourStop: tour.stops[stopIndex + 1])
			}
		}
		
		currentTourStopAudioFile = tourStop.audio
		
		currentTrackTitle = tourStop.object.title
		currentImageURL = tourStop.object.imageUrl
		
		self.autoPlay = true
		
		self.audioGuideNumber = nil
		
		// set correct language on audio
		var audio = tourStop.audio
		audio.language = tour.language
		
		if load(audioFile: audio, coverImageURL: tourStop.object.imageUrl as URL) {
			miniAudioPlayerView.reset()
			audioInfoVC.setArtworkContent(artwork: tourStop.object, audio: audio, tour: tour)
		}
        
        // Log analytics
        AICAnalytics.sendAudioPlayedEvent(source: .TourStop,
                                          language: tour.language,
                                          audio: tourStop.audio,
                                          artwork: tourStop.object,
                                          tour: tour)
        analyticsSource = .TourStop
        analyticsArtwork = tourStop.object
        analyticsTour = tour
	}
	
	private func setAudioBumperFor(nextTourStop: AICTourStopModel) {
		currentAudioBumper = nil
		if let audioBumper = nextTourStop.audioBumper {
			if audioBumper.availableLanguages.contains(self.currentTourLanguage) {
				currentAudioBumper = nextTourStop.audioBumper
				currentAudioBumper!.language = self.currentTourLanguage
			}
		}
	}
	
	private func playAudioBumper(audioBumper: AICAudioFileModel) {
		self.audioGuideNumber = nil
		
		if load(audioFile: audioBumper, coverImageURL: self.currentImageURL!) {
		}
	}
	
	// MARK: Load Audio
	
	private func load(audioFile: AICAudioFileModel, coverImageURL: URL) -> Bool {
		
		if let previousAudioFile = currentAudioFile {
			// If it's a new artwork, log analytics
			if (audioFile.nid != previousAudioFile.nid) {
				// Log analytics
				// GA only accepts int values, so send an int from 1-100
				let pctComplete = Int(currentAudioFileMaxProgress * 100)
                AICAnalytics.sendAudioStoppedEvent(title: previousTrackTitle, audio: previousAudioFile, percentPlayed: pctComplete)
			}
			// If it's same nid and language, don't load audio
			else if selectedLanguage == nil {
				return false
			}
		}
		
		self.currentAudioFile = audioFile
		self.currentAudioFileMaxProgress = 0
        
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
						
						self.setMediaInformation(image: image!)
					})
					
					// Auto-play on load
					if self.autoPlay == true {
						self.play()
					}
					
					break
					
				default:
					print("Unknown error")
				}
			})
		}
		
		return true
	}
	
	private func setMediaInformation(image: UIImage) {
		// MPMediaItemPropertyArtwork
		let artworkMediaItem = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
			return image
		})
		
		// Set the MPNowPlaying information
		let songInfo: [String : AnyObject] = [
			MPMediaItemPropertyTitle: NSString(string: self.currentTrackTitle),
			MPMediaItemPropertyArtist: NSString(string: "Art Institute of Chicago"),
			MPMediaItemPropertyArtwork: artworkMediaItem,
			MPMediaItemPropertyPlaybackDuration: NSNumber(floatLiteral: (CMTimeGetSeconds(self.avPlayer.currentItem!.asset.duration))),
			MPMediaItemPropertyAlbumTrackCount: NSNumber(floatLiteral: 0),
			MPNowPlayingInfoPropertyPlaybackQueueIndex: NSNumber(floatLiteral: 0),
			MPNowPlayingInfoPropertyPlaybackQueueCount: NSNumber(floatLiteral: 0),
			MPNowPlayingInfoPropertyPlaybackRate: NSInteger(1.0) as AnyObject
		]
		
		MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
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
		
		// Log Analytics
		AICAnalytics.sendErrorAudioLoadFailEvent(number: audioFile.nid)
	}
	
	// Set the loading status as the track title
	private func showLoadingMessage() {
		let localizedLoadingMessage = "Loading Message".localized(using: "AudioPlayer")
		miniAudioPlayerView.showLoadingMessage(message: localizedLoadingMessage)
		audioInfoVC.showLoadingMessage(message: localizedLoadingMessage)
	}
	
	private func showAudioControls() {
		miniAudioPlayerView.showTrackTitle(title: self.currentTrackTitle)
		audioInfoVC.showTrackTitle(title: self.currentTrackTitle)
	}
	
	// MARK: Audio Playback
	
    @objc internal func configureAVAudioSession() {
        do {
            // Determine playback category based on bluetooth connection to avoid HFP playback through A2DP headphones
			let bluetoothConnected = AVAudioSession
				.sharedInstance()
				.currentRoute
				.outputs
				.filter {
					$0.portType == .bluetoothA2DP || $0.portType == .bluetoothHFP
				}
				.first != nil
            let playbackCategory = bluetoothConnected ? AVAudioSession.Category.playback : AVAudioSession.Category.playAndRecord
            
            // Init session with correct category
            try AVAudioSession.sharedInstance().setCategory(playbackCategory, options: .allowBluetooth)
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
		MPRemoteCommandCenter.shared().playCommand.addTarget { (mprcommand) -> MPRemoteCommandHandlerStatus in
			return self.play()
		}
        
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
		MPRemoteCommandCenter.shared().pauseCommand.addTarget { (mprcommand) -> MPRemoteCommandHandlerStatus in
			return self.pause()
		}
        
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals = [NSNumber(value: remoteSkipTime)]
		MPRemoteCommandCenter.shared().skipForwardCommand.addTarget { (mprcommand) -> MPRemoteCommandHandlerStatus in
			return self.skipForward()
		}
        
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipBackwardCommand.preferredIntervals = [NSNumber(value: remoteSkipTime)]
		MPRemoteCommandCenter.shared().skipBackwardCommand.addTarget { (mprcommand) -> MPRemoteCommandHandlerStatus in
			return self.skipBackward()
		}
    }
    
    @objc internal func play() -> MPRemoteCommandHandlerStatus {
        if let currentItem = avPlayer.currentItem {
            // If we are at the end, start from the beginning
            let currentTime = floor(CMTimeGetSeconds(currentItem.currentTime()))
            let duration = floor(CMTimeGetSeconds(currentItem.asset.duration))
			
			if duration < 1 {
				if let audio = currentAudioFile {
					showLoadError(forAudioFile: audio, coverImageURL: currentImageURL!)
				}
				return .success
			}
			
            if currentTime >= duration {
                currentItem.seek(to: CMTime(seconds: 0.0, preferredTimescale: avPlayer.currentItem!.duration.timescale))
            }
            
            // Play
            avPlayer.play()
            synchronizePlayPauseButtons(isPlaying: true)
            
            // Enable proximity sensing, needed when user is holding phone to their ear to listen to audio
            UIDevice.current.isProximityMonitoringEnabled = true
			
			return .success
        }
		return .commandFailed
    }
    
    @objc internal func pause() -> MPRemoteCommandHandlerStatus {
        if avPlayer.currentItem != nil {
            avPlayer.pause()
            synchronizePlayPauseButtons(isPlaying: false)
            
			if var info = MPNowPlayingInfoCenter.default().nowPlayingInfo {
				info[MPNowPlayingInfoPropertyPlaybackRate] = NSInteger(0.0)
            	MPNowPlayingInfoCenter.default().nowPlayingInfo = info
			}
			
            // Enable proximity sensing, needed when user is holding phone to their ear to listen to audio
            UIDevice.current.isProximityMonitoringEnabled = false
			return .success
        }
		return .commandFailed
    }
    
    internal func seekToTime(_ timeInSeconds:Double) {
        if let currentItem = avPlayer.currentItem {
            currentItem.seek(to: CMTime(seconds: timeInSeconds, preferredTimescale: currentItem.duration.timescale))
            updateAudioPlayerProgress()
        }
    }
    
    @objc internal func skipForward() -> MPRemoteCommandHandlerStatus {
        if let currentItem = avPlayer.currentItem {
            let duration = CMTimeGetSeconds(currentItem.duration)
            let currentTime = CMTimeGetSeconds(avPlayer.currentTime())
            var skipTime = currentTime + Double(remoteSkipTime)
            
            if skipTime > duration {
                skipTime = duration
            }
            
            seekToTime(skipTime)
			return .success
        }
		return .commandFailed
    }
    
    @objc internal func skipBackward() -> MPRemoteCommandHandlerStatus {
        if avPlayer.currentItem != nil {
            let currentTime = CMTimeGetSeconds(avPlayer.currentTime())
            var skipTime = currentTime - Double(remoteSkipTime)
            if skipTime < 0{
                skipTime = 0
            }
            
            seekToTime(skipTime)
			return .success
		}
		return .commandFailed
    }
    
    fileprivate func synchronizePlayPauseButtons(isPlaying: Bool) {
        miniAudioPlayerView.playPauseButton.isSelected = isPlaying
        audioInfoVC.audioPlayerView.playPauseButton.isSelected = isPlaying
    }
    
	// MARK: Show/Hide Card
    
    override func showFullscreen() {
        super.showFullscreen()
        self.view.backgroundColor = .aicDarkGrayColor
        self.downArrowButton.alpha = 1.0
		self.miniAudioPlayerView.alpha = 0.0
		
		// Accessibility
		audioInfoVC.willMove(toParent: self)
		self.view.addSubview(audioInfoVC.view)
		audioInfoVC.didMove(toParent: self)
		self.view.accessibilityElementsHidden = false
		self.view.accessibilityElements = [
			downArrowButton,
			audioInfoVC.view
		]
	}
    
    override func showMiniPlayer() {
        super.showMiniPlayer()
        UIView.animate(withDuration: 0.25) {
            self.downArrowButton.alpha = 0.0
        }
		
		// Accessibility
		self.view.addSubview(miniAudioPlayerView)
		self.view.accessibilityElementsHidden = false
		self.view.accessibilityElements = [
			miniAudioPlayerView
		]
    }
	
	override func cardDidShowFullscreen() {
		// Log analytics
		AICAnalytics.trackScreenView("Audio Player", screenClass: "AudioPlayerNavigationController")
		
		// Accessibility
		downArrowButton.isAccessibilityElement = true
		miniAudioPlayerView.removeFromSuperview()
		UIAccessibility.post(notification: .screenChanged, argument: audioInfoVC.audioPlayerView.titleLabel)
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
		
		// Accessibility
		downArrowButton.isAccessibilityElement = false
		audioInfoVC.view.removeFromSuperview()
    }
	
	override func cardWillHide() {
		audioInfoVC.languageSelector.close()
	}
	
	override func cardDidHide() {
        currentAudioFile = nil
		
		// Accessibility
		self.view.accessibilityElementsHidden = true
		self.view.accessibilityElements = [
		]
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
            if event?.type == .remoteControl {
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
        
        if avPlayer.currentItem != nil && avPlayer.currentItem?.status == .readyToPlay {
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
		
		// Log analytics
		if let currentAudio = currentAudioFile {
            AICAnalytics.sendAudioStoppedEvent(title: currentTrackTitle, audio: currentAudio, percentPlayed: 100)
		}
		
		// check that we are playing tour stop audio, before you play bumper or original track
		if let currentAudio = currentAudioFile,
			let currentTourStopAudio = currentTourStopAudioFile,
			let currentBumper = currentAudioBumper {
			
			if currentAudio.nid == currentTourStopAudio.nid {
				// if you just played tour stop audio
				// play audio bumper if there is one
				self.autoPlay = true
				playAudioBumper(audioBumper: currentBumper)
			}
			else if currentAudio.nid == currentBumper.nid {
				self.autoPlay = false
				if load(audioFile: currentTourStopAudioFile!, coverImageURL: currentImageURL!) {
					miniAudioPlayerView.reset()
				}
				
				// notify end of audio playback
				self.sectionDelegate?.audioPlayerDidFinishPlaying(audio: currentTourStopAudio)
				// and hide
				if self.currentState != .fullscreen {
					hide()
				}
			}
		}
		else if let currentAudio = currentAudioFile {
			// notify end of audio playback
			self.sectionDelegate?.audioPlayerDidFinishPlaying(audio: currentAudio)
			// rewind to 0
			seekToTime(0.0)
			// and hide
            if self.currentState != .fullscreen {
				hide()
			}
		}
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
		
		// Log Analytics
		if let audio = currentAudioFile {
			if currentAudioFileMaxProgress < 1.0 {
				var pctComplete = Int(currentAudioFileMaxProgress * 100)
                AICAnalytics.sendAudioStoppedEvent(title: currentTrackTitle, audio: audio, percentPlayed: pctComplete)
			}
		}
		
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
		if let audio = currentAudioFile {
			selectedLanguage = language // set the language to indicate the language has been selected using the LanguageSelector
			if load(audioFile: audio, coverImageURL: currentImageURL!) {
				miniAudioPlayerView.reset()
				audioInfoVC.updateAudioContent(audio: currentAudioFile!)
			}
			selectedLanguage = nil
            
            // Log Analytics
            AICAnalytics.sendAudioPlayedEvent(source: analyticsSource,
                                              language: language,
                                              audio: audio,
                                              artwork: analyticsArtwork,
                                              tour: analyticsTour)
		}
	}
}

// MARK: Related Tours Link

extension AudioPlayerNavigationController : UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if URL.absoluteString.range(of: "artic") != nil {
			pause()
			showMiniPlayer()
			return true
		}
		return false
	}
}
