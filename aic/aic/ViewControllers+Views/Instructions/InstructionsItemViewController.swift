/*
 Abstract:
 View controller for individual intro screen
*/

import UIKit

class InstructionsItemViewController: UIViewController {
    var index = -1
    
    override func loadView() {
        self.view = InstructionsItemView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.updateConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setContent(forInstructionScreenModel model: AICInstructionsScreenModel) {
        let view = self.view as! InstructionsItemView
        
        view.iconImage.image = model.iconImage
        view.titleLabel.text = model.title
        view.subtitleLabel.text = model.subtitle
    }
}
