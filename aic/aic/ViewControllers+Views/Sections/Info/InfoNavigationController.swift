//
//  InfoNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/17/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import Localize_Swift
import SwiftUI
import UIKit

class InfoNavigationController: SectionNavigationController {
	var shouldShowMemberCard: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()
        
        Localize.setCurrentLanguage("en")
        
        let infoScreen = NavigationStack {
            InfoScreen()
                .toolbar {
                    Button {
                        // TODO: Connect search
//                        self.sectionDelegate?.showSearch()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .foregroundStyle(.white)
                }
                .environment(\.locale, Locale(identifier: Localize.currentLanguage()))
        }
        
        let rootVC = UIHostingController(rootView: infoScreen)
        addChild(rootVC)
        view.addSubview(rootVC.view)
        rootVC.view.autoPinEdgesToSuperviewEdges()
        rootVC.didMove(toParent: self)
    }
}
