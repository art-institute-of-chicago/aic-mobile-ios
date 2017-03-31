/*
 Abstract:
 Inset view within a tour item, showing the distance to an object
 and the numbers of stops in a tour.
*/

import UIKit

class NewsToursStopsDistanceView : BaseView {
    let height = 40
    let margins = UIEdgeInsetsMake(10, 25, 10, 25)
    
    let contentView = UIView()
    let stopsView = NewsToursStopsDistanceItemView(icon: UIImage(named: "iconStops")!)
    let distanceView = NewsToursStopsDistanceItemView(icon: UIImage(named:"iconDistance")!)
    let distanceMarginLeft = 10
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // Add Subviews
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDistance(toValue distance:Int) {
        let plural = distance > 1 ? "s" : ""
        let distanceStr = "\(distance) Minute\(plural) Away"
        distanceView.value = distanceStr
        contentView.addSubview(distanceView)
        updateConstraints()
    }
    
    func setStops(toValue stops:Int) {
        let plural = stops > 1 ? "s" : ""
        let stopsStr = "\(stops) Stop\(plural)"
        
        stopsView.value = stopsStr
        contentView.addSubview(stopsView)
        updateConstraints()
    }
    
    override func updateConstraints() {
        contentView.snp.remakeConstraints({ (make) in
            make.edges.equalTo(contentView.superview!).inset(margins)
        })
        
        if stopsView.superview != nil {
            stopsView.snp.remakeConstraints({ (make) in
                make.top.left.equalTo(stopsView.superview!)
                make.bottom.equalTo(contentView)
            })
        }
        
        if distanceView.superview != nil {
            distanceView.snp.remakeConstraints({ (make) in
                if stopsView.superview != nil {
                    make.left.equalTo(stopsView.snp.right).offset(distanceMarginLeft)
                } else {
                    make.top.left.equalTo(distanceView.superview!)
                }
                
                make.bottom.equalTo(contentView)
            })
        }
        
        super.updateConstraints()
    }
}
