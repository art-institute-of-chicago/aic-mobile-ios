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
    let infoCoordinator = InfoNavigationCoordinator()
    
    var languageObserver = LanguageManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        let infoScreen = InfoScreen(language: languageObserver)
            .toolbar {
                Button {
                    // TODO: Connect search
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .foregroundStyle(.white)
            }
            .environmentObject(infoCoordinator)

        let rootVC = UIHostingController(rootView: infoScreen)
        addChild(rootVC)
        view.addSubview(rootVC.view)
        rootVC.view.autoPinEdgesToSuperviewEdges()
        rootVC.didMove(toParent: self)
    }

    func navigateToMemberCard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.infoCoordinator.shouldShowMemberCard = false
            self.infoCoordinator.shouldShowMemberCard = true
        }
    }
}
