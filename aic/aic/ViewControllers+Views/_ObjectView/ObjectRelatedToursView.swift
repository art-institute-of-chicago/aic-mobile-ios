/*
 Abstract:
 Related tours, if this object is on any tours this view has links to those tours
*/

import UIKit

class ObjectRelatedToursView: ObjectContentSectionView {
    override init() {
        super.init()
        
        self.titleLabel.text = "Related tours"
        self.bodyTextView.dataDetectorTypes = UIDataDetectorTypes.link
        self.bodyTextView.setDefaultsForAICAttributedTextView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(relatedTours tours:[AICTourModel]) {
        let links:NSMutableAttributedString = NSMutableAttributedString()

        for tour in tours {
			var tourModel = tour
			if let _ = tour.translations[Common.currentLanguage] {
				tourModel.language = Common.currentLanguage
			}
			
            var linkText = tourModel.title
            if tour.nid != tours.last?.nid {
                linkText += "\n"
            }

            let url = Common.DeepLinks.getURL(forTour: tour)
            let linkAttrString = NSMutableAttributedString(string: linkText)

            let range = NSMakeRange(0, linkAttrString.string.count)
            linkAttrString.addAttributes([NSAttributedStringKey.link : url], range: range)

            links.append(linkAttrString)
        }

        bodyTextView.attributedText = links
        bodyTextView.font = .aicTitleFont
    }
}
