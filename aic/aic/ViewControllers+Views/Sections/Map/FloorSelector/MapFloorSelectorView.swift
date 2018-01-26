/*
 Abstract:
 The floor selector creates and holds floor buttons, which let users change floors
*/


import UIKit

class MapFloorSelectorView: UIView {
    
    private let buttonSizeRatio:CGFloat = 0.12
    private let buttonSize:CGFloat
    
    private let floorButtonLabels = ["LL", "1", "2", "3"]
    
    private let locationButtonPaddingTop:CGFloat = 5
    var locationButton = UIButton()
    
    
    // Subviews
    var floorButtons:[MapFloorSelectorUIButton] = []
    
    init(totalFloors:Int) {
        buttonSize = UIScreen.main.bounds.width * buttonSizeRatio
        
        super.init(frame:CGRect.zero)
        
        // Set Drop Shadow
        layer.masksToBounds = false;
        layer.shadowOffset = CGSize(width: 0, height: 0);
        layer.shadowRadius = 5;
        layer.shadowOpacity = 0.5;
        
        // Create floor buttons
        for floorNum in 0..<totalFloors {
            let btn = MapFloorSelectorUIButton(size:buttonSize, floorNum: floorNum, floorLabel: floorButtonLabels[floorNum])
            floorButtons.append(btn)
        }
        
        // Layout floor Buttons in reverse order
        let totalHeight = buttonSize * CGFloat(floorButtons.count)
        for button in floorButtons {
            button.frame.origin = CGPoint(x: 0, y: totalHeight - CGFloat(button.tag) * buttonSize - buttonSize)
        }
        
        // Create heading button
        let locationButtonOrigin = CGPoint(x: 0, y: floorButtons.first!.frame.maxY + locationButtonPaddingTop)
        let locationButtonSize = CGSize(width: buttonSize, height: buttonSize)
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
        self.frame.origin = CGPoint(x: 0,y: 0)
        self.frame.size.width = buttonSize
        
        var bottomView:UIView! = nil
        if locationButton.superview != nil {
            bottomView = locationButton
        } else {
            bottomView = floorButtons.first
        }
        
        self.frame.size.height = bottomView.frame.maxY
    }
}


