/*
 Abstract:
 Main View controller for Object View
 - Displays information about artworks
 - Plays associated audio files in both mini and regular audio player
 - Links to other tours
*/

import UIKit
import AVFoundation
import MediaPlayer
import Alamofire

@objc protocol ObjectViewControllerDelegate: class {
    func objectViewController(controller:ObjectViewController, didUpdateYPosition position:CGFloat)
    func objectViewControllerDidShowMiniPlayer(controller:ObjectViewController)
}

class ObjectViewController: UIViewController {
    // MARK: Properties
    weak var delegate:ObjectViewControllerDelegate?
    
    enum Mode {
        case hidden
        case mini
        case fullScreen
    }
    
    let remoteSkipTime = 10 // Number of seconds to skip forward/back wiht MPRemoteCommandCenter seek
    
    var mode : Mode = Mode.hidden
    
    // Message text
    let loadingMessage = "Loading"
    let loadFailureTitle = "Failed to load this item."
    let loadFailureMessage = "We were unable to load the object at this time. Please check your connection and try again."
    let reloadButtonTitle = "Try Again"
    let cancelButtonTitle = "Cancel"
    
    // Animations
    private let fullscreenCollapseAnimationDuration = 0.25
    
    // Layout
    fileprivate var viewMinYPos:CGFloat = 0.0
    fileprivate var viewMaxYPos:CGFloat = 0.0
    fileprivate let viewSnapRegion:CGFloat = 0.25
    var audioPlayerInitialY:CGFloat = 0
    
    // AVPlayer
    fileprivate let avPlayer = AVPlayer()
    private var audioProgressTimer:Timer?
    private var audioPlayerProgressTimer:Timer? = nil
    
    var currentAudioFile:AICAudioFileModel? = nil
    var currentAudioFileMaxProgress:Float = 0
    
    // Cover Image for MPMediaPlayer + Object view
    var coverImage:UIImage? = nil
    
    // Views
    fileprivate let objectView = ObjectView()
    
    var shouldSnapView = true // Should we try to snap the view to the top/bottom or are we scrolling inside it
    var isUpdatingObjectViewProgressSlider = false
    
    
    // MARK: Initialization
    override func loadView() {
        view = objectView
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func viewDidLoad() {
        self.becomeFirstResponder()
        super.viewDidLoad()
        
        // Set properties
    
        viewMinYPos = -CGFloat(self.getMiniPlayerHeight())
        viewMaxYPos = UIScreen.main.bounds.height - Common.Layout.tabBarHeight - getMiniPlayerHeight()
        
        audioPlayerInitialY = objectView.imageView.frame.height - objectView.audioPlayerView.height
        objectView.audioPlayerView.frame.origin.y = audioPlayerInitialY
        
        
        // Set Events/Gestures
        
        // Mini Audio Player
        let fullscreenTap = UITapGestureRecognizer(target:self, action:#selector(ObjectViewController.fullscreenButtonTapped(_:)))
        objectView.miniAudioPlayerView.closeButton.addGestureRecognizer(fullscreenTap)
        
        let miniAudioPlayerTap = UITapGestureRecognizer(target: self, action:#selector(ObjectViewController.miniAudioPlayerTapped))
        objectView.miniAudioPlayerView.addGestureRecognizer(miniAudioPlayerTap)
        
        // Audio Player
        objectView.audioPlayerView.slider.addTarget(self, action: #selector(ObjectViewController.audioPlayerSliderValueChanged(_:)), for: UIControlEvents.valueChanged)
        objectView.audioPlayerView.slider.addTarget(self,
                                                    action: #selector(ObjectViewController.audioPlayerSliderStartedSliding(_:)),
                                                    for: UIControlEvents.touchDown
        )
        objectView.audioPlayerView.slider.addTarget(self,
                                                    action: #selector(ObjectViewController.audioPlayerSliderFinishedSliding(_:)),
                                                    for: [UIControlEvents.touchUpInside, UIControlEvents.touchUpOutside, UIControlEvents.touchCancel]
        )
        
        let panGesture = UIPanGestureRecognizer(target:self, action: #selector(ObjectViewController.handleObjectVCPanGesture(_:)))
        view.addGestureRecognizer(panGesture)
        
        // Assign Delegates
        objectView.scrollView.delegate = self
        objectView.miniAudioPlayerView.playPauseButton.delegate = self
        objectView.audioPlayerView.playPauseButton.delegate = self
        panGesture.delegate = self
        
        
        configureAVAudioSession()
        NotificationCenter.default.addObserver(self, selector: #selector(ObjectViewController.configureAVAudioSession), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
//    func audioRouteChangedNotification() {
//        let bluetoothConnected = (AVAudioSession.sharedInstance().currentRoute.outputs.filter({$0.portType == AVAudioSessionPortBluetoothA2DP || $0.portType == AVAudioSessionPortBluetoothHFP }).first != nil)
//        print("Bluetooth Connected: \(bluetoothConnected)")
//        
//        for output in AVAudioSession.sharedInstance().currentRoute.outputs {
//            print("Output type: \(output.portType)")
//            print("Output name: \(output.portName)")
//        }
//        
//        print(AVAudioSessionPortBluetoothHFP)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set as
        self.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        initializeMPRemote()
    }
    
    func setProgressBarColor(_ color:UIColor) {
        objectView.miniAudioPlayerView.setProgressBarColor(color)
    }
    
    // MARK: Object Loading
    func setContent(forObjectModel object:AICObjectModel, audioGuideID: Int?) {
        //Check the index of the audio guide id and load the appropriate audio file
        var audioFile: AICAudioFileModel?
        if audioGuideID != nil {
            let audioGuideIDIndex = object.audioGuideIDs!.index(of: audioGuideID!)
            if object.audioFiles!.count > audioGuideIDIndex! {
                audioFile = object.audioFiles![audioGuideIDIndex!]
            }
        }
        
        if audioFile == nil {
            audioFile = object.audioFiles!.first!
        }
        
        if load(audioFile: audioFile!, coverImageURL: object.imageUrl as URL) {
            objectView.display(object: object)
        }
    }
    
    func setContent(forTourOverviewModel tourOverview:AICTourOverviewModel) {
        if load(audioFile: tourOverview.audio, coverImageURL: tourOverview.imageUrl as URL) {
            objectView.display(tourOverview: tourOverview)
        }
    }
    
    func setContent(forTour tour:AICTourModel, atStopIndex stopIndex:Int) {
        let stop = tour.stops[stopIndex]
        if load(audioFile: stop.audio, coverImageURL: stop.object.imageUrl as URL) {
            objectView.display(tour: tour, atStopIndex:stopIndex)
        }
    }
    
    private func load(audioFile:AICAudioFileModel, coverImageURL:URL) -> Bool {
        
        if let currentAudioFile = currentAudioFile {
            // Make sure we haven't already tried to load this file
            if (audioFile.nid == currentAudioFile.nid) {
                return false
            }
        
            // Log analytics
            // GA only accepts int values, so send an int from 1-10
            let progressValue:Int = Int(currentAudioFileMaxProgress * 100)
            AICAnalytics.objectViewAudioItemPlayedEvent(audioItem: currentAudioFile, pctComplete: progressValue)
            print(currentAudioFileMaxProgress)
        }
        
        currentAudioFile = audioFile
        currentAudioFileMaxProgress = 0
        
        // Clear out current player
        self.audioPlayerProgressTimer?.invalidate()
        
        // Reset visuals
        objectView.miniAudioPlayerView.resetProgress()
        objectView.audioPlayerView.resetProgress()
        
        // Set the player view to show loading status
        showLoadingMessage()
        
        // Load the cover image
        Alamofire.request(coverImageURL).responseData { (response) in
            switch response.result {
            case .failure( _ ):
                DispatchQueue.main.async(execute: {
                    self.showLoadError(forAudioFile: audioFile, coverImageURL: coverImageURL)
                })
                return
            default:
                break
            }
            
            guard let coverImage = UIImage(data:response.data!) else {
                DispatchQueue.main.async(execute: {
                    self.showLoadError(forAudioFile: audioFile, coverImageURL: coverImageURL)
                })
                return
            }
            
            self.coverImage = coverImage
    
            self.objectView.setImage(self.coverImage!)
        
            // Load the file
            let asset = AVURLAsset(url: audioFile.url)
            
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
                        NotificationCenter.default.addObserver(self, selector: #selector(ObjectViewController.audioPlayerDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                        
                        // Set the item as our player's current item
                        self.avPlayer.replaceCurrentItem(with: playerItem)
                       
                        // Show the audio file
                        self.showAudioControls()
                        
                        // Create NSTimer to check for audio update progress and update as needed
                        if self.audioProgressTimer == nil {
                            self.audioPlayerProgressTimer = Timer.scheduledTimer(timeInterval: 0.25,
                                                                                                target: self,
                                                                                                selector: #selector(ObjectViewController.updateAudioPlayerProgress),
                                                                                                userInfo: nil,
                                                                                                repeats: true
                            )
                        }
                        
                        // Set the MPNowPlaying information
                        let songInfo: [String : AnyObject] = [
                            MPMediaItemPropertyTitle: NSString(string: audioFile.title),
                            MPMediaItemPropertyArtist: NSString(string: "Art Institute of Chicago"),
                            MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: self.coverImage!),
                            MPMediaItemPropertyPlaybackDuration: NSNumber(floatLiteral: (CMTimeGetSeconds(self.avPlayer.currentItem!.asset.duration))),
                            MPMediaItemPropertyAlbumTrackCount: NSNumber(floatLiteral: 0),
                            MPNowPlayingInfoPropertyPlaybackQueueIndex: NSNumber(floatLiteral: 0),
                            MPNowPlayingInfoPropertyPlaybackQueueCount: NSNumber(floatLiteral: 0)
                        ]
                        
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
                        
                        // Auto-play on load
                        
                        self.play()
                        
                        break
                        
                    default:
                        print("Unknown error")
                    }
                    
                })
            }
        }
        
        return true
    }
    
    private func showLoadError(forAudioFile audioFile:AICAudioFileModel, coverImageURL:URL) {
        // Preset a UIAlertView that allows the user to try to load the file.
        let alertView = UIAlertController(title: loadFailureTitle, message: loadFailureMessage, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: self.reloadButtonTitle, style: .default, handler: { (alertAction) -> Void in
            self.currentAudioFile = nil
            _ = self.load(audioFile: audioFile, coverImageURL: coverImageURL)
        }))
        
        alertView.addAction(UIAlertAction(title: self.cancelButtonTitle, style: .cancel, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    // Set the loading status as the track title
    private func showLoadingMessage() {
        self.objectView.miniAudioPlayerView.showMessage(loadingMessage)
        self.objectView.audioPlayerView.showMessage(message: loadingMessage)
    }
    
    private func showAudioControls() {
        self.objectView.miniAudioPlayerView.showProgressAndControls(currentAudioFile!.title)
        self.objectView.audioPlayerView.showProgressAndControls(withTitle: currentAudioFile!.title)
    }
    
    // MARK: Dimensions
    func getMiniPlayerHeight() -> CGFloat {
        return objectView.miniAudioPlayerViewHeight
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
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(ObjectViewController.play))
        
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(ObjectViewController.pause))
        
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals = [10]
        MPRemoteCommandCenter.shared().skipForwardCommand.addTarget(self, action: #selector(ObjectViewController.skipForward))
        
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipBackwardCommand.preferredIntervals = [10]
        MPRemoteCommandCenter.shared().skipBackwardCommand.addTarget(self, action: #selector(ObjectViewController.skipBackward))
    }
    
    @objc internal func play() {
        if let currentItem = avPlayer.currentItem {
            // If we are at the end, start from the beginning
            let currentTime = floor(CMTimeGetSeconds(currentItem.currentTime()))
            let duration = floor(CMTimeGetSeconds(currentItem.asset.duration))
            
            if currentTime >= duration {
                currentItem.seek(to: CMTime(seconds: 0.0, preferredTimescale: avPlayer.currentItem!.duration.timescale))
            }
            
            // Play
            self.avPlayer.play()
            synchronizePlayPauseButtons(forMode: PlayPauseButton.Mode.playing)
            
            // Update MPNowPlaying
            var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
            info![MPNowPlayingInfoPropertyPlaybackRate] = NSInteger(1.0)
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            
            // Enable proximity sensing, needed when user is holding phone to their ear to listen to audio
            UIDevice.current.isProximityMonitoringEnabled = true
        }
    }
    
    @objc internal func pause() {
        if avPlayer.currentItem != nil {
            self.avPlayer.pause()
            synchronizePlayPauseButtons(forMode: PlayPauseButton.Mode.paused)
            
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
    
    fileprivate func synchronizePlayPauseButtons(forMode mode:PlayPauseButton.Mode) {
        objectView.miniAudioPlayerView.playPauseButton.mode = mode
        objectView.audioPlayerView.playPauseButton.mode = mode
    }
    
    // MARK: Hide/Show/Position entire view
    func showMiniPlayer(withAnimation:Bool = true) {
        view.isHidden = false
        
        let duration = withAnimation ? fullscreenCollapseAnimationDuration : 0
        UIView.animate(withDuration: duration, animations: {
            self.setPosition(yPosition: self.viewMaxYPos)
        }) 
        
        // Toggle visibility of fullscreen/collapse buttons
        objectView.miniAudioPlayerView.closeButton.isHidden = false
        
        // Show the status bar
        Common.Layout.showStatusBar = true
        
        mode = .mini
        
        delegate?.objectViewControllerDidShowMiniPlayer(controller: self)
        
        // Log analytics
        AICAnalytics.restorePreviousScreen()
    }
    
    func showFullscreen(withAnimation:Bool = true) {
        view.isHidden = false
        
        let duration = withAnimation ? fullscreenCollapseAnimationDuration : 0
        UIView.animate(withDuration: duration, animations: {
            self.setPosition(yPosition: self.viewMinYPos)
        }) 
        
        // Toggle visibility of fullscreen/collapse buttons
        objectView.miniAudioPlayerView.closeButton.isHidden = true
        
        // Hide the status bar
        Common.Layout.showStatusBar = false
        
        mode = .fullScreen
        
        // Log analytics
        AICAnalytics.trackScreen(named: "Object View")
    }
    
    func hide() {
        view.isHidden = true
    }
    
    fileprivate func setPosition(yPosition:CGFloat) {
        // Clamp + set
        let yPosition = clamp(val: yPosition, minVal: viewMinYPos, maxVal: viewMaxYPos)
        view.frame.origin = CGPoint(x: 0, y: yPosition)
        
        // Notify Delegate
        delegate?.objectViewController(controller: self, didUpdateYPosition: yPosition)
    }
}

// MARK: Gesture Handlers
extension ObjectViewController : UIGestureRecognizerDelegate {
    @objc internal func handleObjectVCPanGesture(_ sender: UIPanGestureRecognizer) {
        if !shouldSnapView {
            return
        }
        
        guard let view = sender.view else {
            return
        }
        
        // Calculate the new position
        let translation = sender.translation(in: view)
        let newY:CGFloat = view.frame.origin.y + translation.y
        
        // If we've ended, snap to top or bottom
        if sender.state == UIGestureRecognizerState.ended {
            // Calculate whee we are between top and bottom
            let pctInScreenArea = newY/viewMaxYPos
            
            // If we're close to top or bottom just snap
            if pctInScreenArea > 1.0 - viewSnapRegion {
                showMiniPlayer()
            }
                
            else if pctInScreenArea < viewSnapRegion {
                showFullscreen()
            }
                
            // Otherwise, snap based on velocity (direction)
            else {
                if(sender.velocity(in: view).y > 0) {
                    showMiniPlayer()
                } else {
                    showFullscreen()
                }
            }
        } else {
            setPosition(yPosition: newY)
        }
        
        // Clean up gesture
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UISlider {
            return false
        }
        
        return true
    }
    
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (self.objectView.scrollView.contentOffset.y <= 0) && !isUpdatingObjectViewProgressSlider {
           return true
        }
        
        return false
    }
}

// MARK: Scroll View Delegate
extension ObjectViewController : UIScrollViewDelegate {
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        
        let isScrolledToTop = (yOffset <= 0 || self.view.frame.origin.y > -objectView.miniAudioPlayerView.frame.height)
        
        if isScrolledToTop {
            shouldSnapView = true
        } else {
            shouldSnapView = false
        }
        
        scrollView.contentOffset.y = isScrolledToTop ? 0 : yOffset
    }
}


// MARK: Audio Control Methods
extension ObjectViewController : PlayPauseButtonDelegate {
    internal func playPauseButton(_ viewController:PlayPauseButton, modeChanged mode: PlayPauseButton.Mode) {
        switch mode {
        case PlayPauseButton.Mode.playing:
            if avPlayer.currentItem?.duration == avPlayer.currentTime() {
                seekToTime(0)
            }
            play()
            
        case PlayPauseButton.Mode.paused:
            pause()
        }
    }
}

// MARK: Events
extension ObjectViewController {
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
            let pct = Float(progress/duration)
            if pct > currentAudioFileMaxProgress {
                currentAudioFileMaxProgress = pct
            }
            
            // Update the progress bar views
            objectView.audioPlayerView.updateProgress(progress: progress, duration: duration, setSliderValue: !isUpdatingObjectViewProgressSlider)
            objectView.miniAudioPlayerView.updateProgress(progress, duration: duration)
            
            // Update now playing with progress
            var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
            info![MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSInteger(progress)
            
            DispatchQueue.main.async {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            }
        }
    }
    
    @objc internal func audioPlayerDidFinishPlaying(_ notification:Notification) {
        synchronizePlayPauseButtons(forMode: .paused)
    }
    
    // Audio player Slider Events
    
    @objc internal func audioPlayerSliderStartedSliding(_ slider:UISlider) {
        // Stop the progress from updating, otherwise the two funcs fight
        isUpdatingObjectViewProgressSlider = true
    }
    
    
    @objc internal func audioPlayerSliderValueChanged(_ slider:UISlider) {
        if let currentItem = avPlayer.currentItem {
            let newTime = CMTimeGetSeconds(currentItem.asset.duration) * Double(objectView.audioPlayerView.slider.value)
            seekToTime(newTime)
            updateAudioPlayerProgress()
        }
    }
    
    @objc internal func audioPlayerSliderFinishedSliding(_ slider:UISlider) {
        isUpdatingObjectViewProgressSlider = false
        updateAudioPlayerProgress()
    }
    
    @objc internal func fullscreenButtonTapped(_ sender:UIButton!) {
        self.showFullscreen()
    }
    
    @objc internal func miniAudioPlayerTapped() {
        self.showFullscreen()
    }
    
    @objc internal func collapseButtonTapped(_ sender:UIButton!) {
        objectView.scrollView.setContentOffset(CGPoint(x: 0, y: -objectView.scrollView.contentInset.top), animated: true)
        self.showMiniPlayer()
    }
}
