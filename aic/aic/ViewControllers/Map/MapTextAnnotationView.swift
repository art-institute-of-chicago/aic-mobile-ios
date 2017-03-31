/*
 Abstract:
 Custom annotation view for outside information, i.e. "Michigan Ave entrance", "Pritzer Garden", etc.
 Shows a simple UILabel
*/

import MapKit

class MapTextAnnotationView: MapAnnotationView {
    var label:UILabel? = nil
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        layer.zPosition = Common.Map.AnnotationZPosition.text.rawValue
        layer.drawsAsynchronously = true
        isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAnnotation(forMapTextAnnotation annotation:MapTextAnnotation) {
        // Reset Label
        if self.label != nil {
            self.label!.removeFromSuperview()
        }
        
        self.label = UILabel()
        let label = self.label!
        
        // Determine the font based on the type of text annotation
        var font:UIFont! = nil
        
        switch annotation.type {
        case .Space:
            font = UIFont.aicSpacesFont()
            
        case .LandmarkGarden:
            font = UIFont.aicSystemTextFont()
            
        case .Gallery:
            font = UIFont.aicSystemTextFont()
        }
        
        self.annotation = annotation
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.maximumLineHeight = 18
        
        let attrString = NSMutableAttributedString(string: annotation.labelText)
        let range = NSMakeRange(0, attrString.length)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: range)
        attrString.addAttribute(NSFontAttributeName, value:font, range: range)
        
        label.attributedText = attrString
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.sizeToFit()
        
        addSubview(label)
        
        label.frame.origin = CGPoint(x: -label.bounds.width/2, y: -label.bounds.height/2)
        //self.frame.size = label.frame.size
    }
    
    func setTextColor(_ color:UIColor) {
        guard let label = self.label else {
            print("UILabel not created for MapTextAnnotationView. Can not set color.")
            return
        }
        
        if let annotation = self.annotation as? MapTextAnnotation {
            switch annotation.type {
            case .LandmarkGarden:
                label.textColor = color.darker()
                
            case .Space:
                label.textColor = color.lighter()
                
            case .Gallery:
                label.textColor = color.lighter()
            }
        }
    }
}

