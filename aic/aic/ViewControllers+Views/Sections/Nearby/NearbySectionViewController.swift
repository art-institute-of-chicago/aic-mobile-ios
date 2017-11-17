/*
 Abstract:
 Section View controller for Nearby (Map) view
*/

import UIKit

class NearbySectionViewController : SectionViewController {    
    let nearbyView:NearbySectionView
    
    var titleIsHidden = false
    
    override init(section:AICSectionModel) {
        // Create our view + Tab Bar Item then initialize
        nearbyView = NearbySectionView(section:section)
        super.init(section:section)
		self.view = nearbyView
        
        // Switch our BG Color out to provide contrast between the map and the title view
        color = .aicMapColor
        
        nearbyView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        recalculateViewableMapArea()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func recalculateViewableMapArea() {
//        view.layoutIfNeeded()
//        let titleBottomY = self.nearbyView.titleView.bounds.height - self.nearbyView.scrollView.contentOffset.y
//        self.viewableMapArea = CGRect(x: 0, y: titleBottomY, width: self.nearbyView.bounds.width,  height: UIScreen.main.bounds.height - titleBottomY - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight)
//    }
	
    fileprivate func showTitle() {
        if titleIsHidden {
            self.nearbyView.scrollView.contentOffset.y = 0
            //recalculateViewableMapArea()
            titleIsHidden = false
        }
    }
    
    fileprivate func hideTitle() {
        if !titleIsHidden {
            self.nearbyView.scrollView.contentOffset.y = self.nearbyView.titleView.descriptionLabel.frame.origin.y + self.nearbyView.titleView.descriptionLabel.frame.height
            //recalculateViewableMapArea()
            titleIsHidden = true
        }
    }
}

// Nearby View delegate
extension NearbySectionViewController : NearbySectionViewDelegate {
    func shouldMinimizeTopNavigation() {
        hideTitle()
    }
    
    func shouldMaximizeTopNavigation() {
        showTitle()
    }
}
