/*
 Abstract:
 Represents a tooltip
 */

import UIKit

enum TooltipType {
	case popup
	case arrow
}

struct AICTooltipModel {
	let type: TooltipType
    let title: String
    var text: String
	var arrowPosition: CGPoint
}
