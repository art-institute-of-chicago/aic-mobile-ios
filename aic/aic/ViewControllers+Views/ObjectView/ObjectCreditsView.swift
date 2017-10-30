/*
 Abstract:
 Credits for the audio file in an object view
*/


import UIKit

class ObjectCreditsView: ObjectContentSectionView {

    override init() {
        super.init()
        
        self.titleLabel.text = "Credits"
        self.bodyTextView.font = UIFont.aicItalicTextFont()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(credits:String?, imageCopyright:String?) {
        var creditsText = ""
        
        if let credits = credits {
            creditsText = credits
        }
        
        if let copyright = imageCopyright {
            if credits != nil {
                creditsText = creditsText + "\n"
            }
            
            creditsText = creditsText + copyright
        }
        
        self.bodyTextView.text = creditsText
    }

}
