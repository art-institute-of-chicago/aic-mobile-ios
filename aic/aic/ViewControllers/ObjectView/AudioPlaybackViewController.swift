//
//  ObjectViewAudioControlDelegate.swift
//  aic
//
//  Created by Stephen Varga on 3/15/16.
//  Copyright © 2016 Potion Design. All rights reserved.
//
import UIKit

protocol AudioPlaybackViewControllerDelegate: class {
    func audioPlaybackPausePressed(audioPlayback:AudioPlaybackViewController)
    func audioPlaybackPlayPressed(audioPlayback:AudioPlaybackViewController)
}

class AudioPlaybackViewController : UIViewController {
    
    // MARK: Properties
    
    weak var delegate:AudioPlaybackViewControllerDelegate?
    
    var playButton:UIButton?
    var pauseButton:UIButton?
    
    var sliderUISlider:UISlider?
    
    var titleLabel:UILabel?
    
    // MARK: Initializers
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setLabel(labelText:String) {
        titleLabel?.text = labelText
    }
    
    func attachButtonActions() {
        playButton?.addTarget(self, action: "playButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        pauseButton?.addTarget(self, action: "pauseButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func playButtonPressed(sender:UIButton!) {
        guard let delegate = self.delegate else {
            return
        }
        
        playButton?.hidden = true
        pauseButton?.hidden = false
        
        delegate.audioPlaybackPlayPressed(self)
    }
    
    
    func pauseButtonPressed(sender:UIButton!) {
        guard let delegate = self.delegate else {
            return
        }
        
        playButton?.hidden = false
        pauseButton?.hidden = true
        
        delegate.audioPlaybackPausePressed(self)
    }
}