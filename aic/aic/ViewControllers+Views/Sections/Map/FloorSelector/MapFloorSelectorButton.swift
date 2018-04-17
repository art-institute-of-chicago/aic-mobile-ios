/*
 Abstract:
 Parses a custom SVG file from Designers with specific layer names to pull out annatation types + positions
*/

import UIKit

class MapFloorSelectorButton: UIButton {
    private struct ColorScheme {
        let labelColor:UIColor
        let deselectedColor:UIColor
        let selectedColor:UIColor
    }
    
    private let defaultColorScheme = ColorScheme(labelColor: .aicFloorTextColor, deselectedColor: .aicFloorUnselectedColor, selectedColor: .aicFloorColor)
    
    private let userLocationColorScheme = ColorScheme(labelColor: .white, deselectedColor: .aicBluedotUnselectedColor, selectedColor: .aicBluedotColor)

    var isUserLocationFloor = false {
        didSet {
            updateColors()
        }
    }
    var isSelectedFloor = false {
        didSet {
            updateColors()
        }
    }
    
    init(size:CGFloat, floorNum:Int, floorLabel: String) {
        
        let frame = CGRect(x: 0, y: 0, width: size, height: size)
        super.init(frame: frame)
        
        setTitle(floorLabel, for: UIControlState())
        setTitleColor(.black, for: UIControlState())
        setTitleColor(.blue, for: UIControlState.highlighted)
		
		titleLabel!.font = .aicPageTextFont
        
        backgroundColor = .white
        tag = floorNum
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func updateColors() {
        let colorScheme = isUserLocationFloor ? userLocationColorScheme : defaultColorScheme
        
        setTitleColor(colorScheme.labelColor, for: UIControlState())
        setTitleColor(colorScheme.labelColor, for: UIControlState.highlighted)
        
        backgroundColor = isSelectedFloor ? colorScheme.selectedColor : colorScheme.deselectedColor
    }
}
