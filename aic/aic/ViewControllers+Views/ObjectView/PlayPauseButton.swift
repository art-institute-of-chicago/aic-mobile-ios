/*
 Abstract:
 Toggle button for play/pause, shared between audio players
*/

import UIKit

protocol PlayPauseButtonDelegate: class {
    func playPauseButton(_ view:PlayPauseButton, modeChanged mode: PlayPauseButton.Mode)
}

class PlayPauseButton : UIButton {
    enum Mode {
        case playing
        case paused
        
        mutating func toggle() {
            switch self {
            case .playing:
                self = .paused
            case .paused:
                self = .playing
            }
        }
    }
    
    // MARK: Properties
    weak var delegate:PlayPauseButtonDelegate?
    
    var buttonsSet = false
    private var playButtonImage:UIImage?
    private var pauseButtonImage:UIImage?
    
    private var defaultSize = CGSize(width: 44, height: 44)
    
    var mode:Mode = .playing {
        didSet {
            setButtonForCurrentMode()
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0,width: 0,height: 0))
        
        // Configure
        backgroundColor = UIColor.clear
        
        playButtonImage = UIImage(named: "playSm")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        pauseButtonImage = UIImage(named: "pauseSm")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        imageView?.contentMode = UIViewContentMode.center
        
        self.frame.size = defaultSize
        
        if playButtonImage!.size != pauseButtonImage!.size {
            print("PlayPauseButtonView: Button Images should be the same size.")
        }
        
        // Add gestures
        let tap = UITapGestureRecognizer(target: self, action:#selector(PlayPauseButton.buttonTapped(_:)))
        addGestureRecognizer(tap)
        
        // Init mode
        mode = Mode.playing
        setButtonForCurrentMode()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setScale(_ scale:Float) {
        self.frame.size = CGSize(width: defaultSize.width * CGFloat(scale), height: defaultSize.height * CGFloat(scale))
    }
    
    private func setButtonForCurrentMode() {
        switch mode {
        case Mode.playing:
            setImage(pauseButtonImage, for: UIControlState())
        case Mode.paused:
            setImage(playButtonImage, for: UIControlState())
        }
    }
    
    @objc internal func buttonTapped(_ sender:UIButton!) {
        mode.toggle()
        
        delegate?.playPauseButton(self, modeChanged: self.mode)
    }
}
