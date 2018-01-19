/*
 Abstract:
 View controller for individual intro screen
*/

import UIKit

class InstructionsItemViewController: UIViewController {
    var index = -1
	
	let iconMarginTop: CGFloat = 145
	
	let titleMargins = UIEdgeInsetsMake(32, 45, 0, 45)
	let subtitleMargins = UIEdgeInsetsMake(15, 45, 0, 45)
	
	let iconImage = UIImageView()
	let titleLabel = UILabel()
	let subtitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = .clear
		
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .white
		titleLabel.font = .aicInstructionsTitleFont
		titleLabel.textAlignment = NSTextAlignment.center
		titleLabel.preferredMaxLayoutWidth = 300
		
		subtitleLabel.numberOfLines = 0
		subtitleLabel.font = .aicInstructionsSubtitleFont
		subtitleLabel.textAlignment = NSTextAlignment.center
		subtitleLabel.textColor = .white
		
		// Add Subviews
		self.view.addSubview(iconImage)
		self.view.addSubview(titleLabel)
		self.view.addSubview(subtitleLabel)
		
		createViewConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setContent(forInstructionScreenModel model: AICInstructionsScreenModel) {
        iconImage.image = model.iconImage
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }
	
	func createViewConstraints() {
		iconImage.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		iconImage.autoPinEdge(.top, to: .top, of: self.view, withOffset: iconMarginTop)
		
		titleLabel.autoPinEdge(.top, to: .bottom, of: iconImage, withOffset: titleMargins.top)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: titleMargins.left)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -titleMargins.right)
		
		subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: subtitleMargins.top)
		subtitleLabel.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: subtitleMargins.left)
		subtitleLabel.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -subtitleMargins.right)
	}
}
