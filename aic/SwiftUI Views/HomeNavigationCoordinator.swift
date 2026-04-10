//
//  HomeNavigationCoordinator.swift
//  aic
//
//  Created by David Bireta on 4/9/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

final class HomeNavigationCoordinator: ObservableObject {
    var showExhibitionOnMap: (_ exhibition: AICExhibitionModel) -> Void = { _ in }
}
