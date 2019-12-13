/*
 Abstract:
 Base class for map annotations with shared animation properties
 */

import MapKit

class MapAnnotationView: MKAnnotationView {

    override var annotation: MKAnnotation? {
        didSet {
            animateIn()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        alpha = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        alpha = 0.0
    }

    internal func animateIn() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1.0
        })
    }
}
