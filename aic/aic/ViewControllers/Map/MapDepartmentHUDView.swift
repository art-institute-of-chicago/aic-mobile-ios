/*
 Abstract:
 An overlay that shows what department you are in when zoomed in on map
 */

import UIKit

class MapDepartmentHUDView: UIView {

    fileprivate let animationDuration = 0.5
    fileprivate let height:CGFloat = 50.0
    
    fileprivate let label = UILabel()
    
    init() {
        super.init(frame:CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width, height: height))
        
        backgroundColor = UIColor.aicNearbyColor().withAlphaComponent(0.5)
        
        label.frame = self.frame
        label.font = UIFont.aicSystemTextFont()
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.text = "Testing 1...2....3"
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDepartment(_ department:String) {
        label.text = department.replacingOccurrences(of: "\n", with: " ")
    }

    func show() {
        self.alpha = 0.0
        UIView.animate(withDuration: animationDuration, animations: { 
            self.alpha = 1.0
        }) 
    }
    
    func hide() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 0.0
        }) 
    }
}
