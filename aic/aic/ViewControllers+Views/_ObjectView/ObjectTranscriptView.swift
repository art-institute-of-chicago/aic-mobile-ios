/*
 Abstract:
 Transcript of the audio file
*/

import UIKit

class ObjectTranscriptView: ObjectContentSectionView {
    
    override init() {
        super.init()
        
        self.titleLabel.text = "Transcript"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: This text comes through HTML encoded, need to display it correctly
    func set(transcript:String) {
        let attrString = getAttributedString(forHTMLText: transcript, font: .aicTextFont)
        bodyTextView.attributedText = attrString
    }
}
