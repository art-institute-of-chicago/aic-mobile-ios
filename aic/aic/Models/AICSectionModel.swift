/*
 Abstract:
 Data model for an app main section
 */

import UIKit

enum Section: Int {
	case home
	case audioGuide
    case map
    case info
}

struct AICSectionModel {
    let nid: Int

    // Background color for this section
    let color: UIColor

    // Section top title + Info
	let background: UIImage?
	let icon: UIImage
    let title: String

    // Tab Bar item info
    let tabBarTitle: String
    let tabBarIcon: UIImage
}
