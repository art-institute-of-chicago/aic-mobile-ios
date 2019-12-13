/*
 Abstract:
 The floor selector creates and holds floor buttons, which let users change floors
*/

import UIKit

class MapFloorSelectorView: UIView {

	static let buttonSize: CGFloat = 40.0

    private let floorButtonLabels = ["LL", "1", "2", "3"]

    private let locationButtonPaddingTop: CGFloat = 5
    var locationButton = UIButton()

    // Subviews
    var floorButtons: [MapFloorSelectorButton] = []

	init(totalFloors: Int) {
        super.init(frame: CGRect.zero)

        // Set Drop Shadow
        layer.masksToBounds = false
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowRadius = 5;
//        layer.shadowOpacity = 0.5;

        // Create floor buttons
        for floorNum in 0..<totalFloors {
			let btn = MapFloorSelectorButton(size: MapFloorSelectorView.buttonSize, floorNum: floorNum, floorLabel: floorButtonLabels[floorNum])
            floorButtons.append(btn)
        }

        // Layout floor Buttons in reverse order
		let totalHeight = MapFloorSelectorView.buttonSize * CGFloat(floorButtons.count)
        for button in floorButtons {
            button.frame.origin = CGPoint(x: 0, y: totalHeight - CGFloat(button.tag) * MapFloorSelectorView.buttonSize - MapFloorSelectorView.buttonSize)
        }

        // Create heading button
        let locationButtonOrigin = CGPoint(x: 0, y: floorButtons.first!.frame.maxY + locationButtonPaddingTop)
		let locationButtonSize = CGSize(width: MapFloorSelectorView.buttonSize, height: MapFloorSelectorView.buttonSize)
        locationButton.frame =  CGRect(origin: locationButtonOrigin, size: locationButtonSize)

        // Add Subviews
        for button in floorButtons {
            addSubview(button)
        }

        addSubview(locationButton)

        // Set our frame
        calculateFrame()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func calculateFrame() {
        self.frame.origin = CGPoint(x: 0, y: 0)
        self.frame.size.width = MapFloorSelectorView.buttonSize

        var bottomView: UIView! = nil
        if locationButton.superview != nil {
            bottomView = locationButton
        } else {
            bottomView = floorButtons.first
        }

        self.frame.size.height = bottomView.frame.maxY
    }
}
