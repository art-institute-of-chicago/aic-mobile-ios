/*
Abstract:
Section View controller for Number Pad section
*/

import Localize_Swift
import SwiftUI
import UIKit

protocol AudioGuideNavigationControllerDelegate: AnyObject {
	func audioGuideDidSelectObjectAudio(object: AICObjectModel, audioGuideID: Int)
	func audioGuideDidSelectTourAudio(tour: AICTourModel, audioGuideID: Int)
}

class AudioGuideNavigationController: SectionNavigationController {
	// Delegate
	weak var sectionDelegate: AudioGuideNavigationControllerDelegate?

	override init(section: AICSectionModel) {
		super.init(section: section)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

        // SwiftUI View
        let audio = AudioScreen() { [self] tour, code in
            sectionDelegate?.audioGuideDidSelectTourAudio(tour: tour, audioGuideID: code)
        } selectedObjectAction: { [self] object, code in
            sectionDelegate?.audioGuideDidSelectObjectAudio(object: object, audioGuideID: code)
        }
        
        let rootVC = UIHostingController(rootView: audio)
        addChild(rootVC)
        view.addSubview(rootVC.view)
        rootVC.view.autoPinEdgesToSuperviewEdges()
        rootVC.didMove(toParent: self)
	}
}
