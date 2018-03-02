/*
 Abstract:
 View for DepartmentAnnotations, shows the department name + image
 and can be selected to zoom in on department
 */
import MapKit

class MapDepartmentAnnotationView: MapAnnotationView {
    class var reuseIdentifier:String {
        return "mapDepartment"
    }
	
	let imageSize: CGSize = CGSize(width: 46.0, height: 46.0)
    let insets:UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
    let labelMargin: CGFloat = 10
    
    let holderView = UIView()
    let holderTailImageView = UIImageView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        guard let departmentAnnotation = annotation as? MapDepartmentAnnotation else {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            print("Attempted to init MapDepartmentAnnotationView without a MapDepartmentAnnotation")
            return
        }
        
        super.init(annotation:departmentAnnotation, reuseIdentifier:reuseIdentifier)
        
        // Set Properties
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        
        self.layer.zPosition = Common.Map.AnnotationZPosition.department.rawValue
        
        self.isEnabled = true
        self.canShowCallout = false
        
        holderView.backgroundColor = UIColor.aicMapColor.darker()
        holderView.isUserInteractionEnabled = true
        
        let holderTailImage = #imageLiteral(resourceName: "calloutTail").withRenderingMode(.alwaysTemplate)
        
        holderTailImageView.image = holderTailImage
        holderTailImageView.sizeToFit()
        holderTailImageView.tintColor = UIColor.aicMapColor.darker()
        
        addSubview(holderTailImageView)
        addSubview(holderView)
        
        setAnnotation(forDepartmentAnnotation: departmentAnnotation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear out previous views
        for subview in holderView.subviews {
            subview.removeFromSuperview()
        }
        
        alpha = 0.0
    }
    
    func setAnnotation(forDepartmentAnnotation annotation:MapDepartmentAnnotation) {
        // Save Annotation
        self.annotation = annotation
        // Create image
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: insets.left, y: insets.top), size: imageSize))
		if let image = annotation.image {
			imageView.image = image
		}
		imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        holderView.addSubview(imageView)
        
        // Create label
        let label = UILabel()
        label.numberOfLines = 0
        
        label.text = annotation.title
        label.font = .aicTextFont
		label.textAlignment = .center
        label.textColor = .white
        label.sizeToFit()
        label.frame.origin.x = imageView.frame.maxX + labelMargin
        holderView.addSubview(label)
        
        holderView.frame.size = CGSize(width: label.frame.maxX + insets.right, height: imageView.frame.maxY + insets.bottom)
        holderTailImageView.frame.origin = CGPoint(x: holderView.frame.width/2 - holderTailImageView.frame.width/2, y: holderView.frame.size.height - 10)
        
        label.frame.origin.y = holderView.frame.height/2 - label.frame.height/2
        
        centerOffset = CGPoint(x: 0, y: -holderTailImageView.frame.maxY/2)
        
        
        self.bounds = holderView.frame
    }
}
