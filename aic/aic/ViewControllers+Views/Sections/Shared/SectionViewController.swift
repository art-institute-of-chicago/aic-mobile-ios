/*
 Abstract:
 Base view controller for all Section Views (NumberPad, What's On, Tours, Nearby and Info)
*/

import UIKit

protocol SectionViewControllerScrollDelegate : class {
	func sectionViewControllerWillAppearWithScrollView(scrollView: UIScrollView)
	func sectionViewControllerDidScroll(scrollView: UIScrollView)
}

class SectionViewController : UIViewController {
    var color:UIColor
    let sectionModel:AICSectionModel
	weak var scrollDelegate: SectionViewControllerScrollDelegate? = nil
    
    init(section:AICSectionModel) {
        self.sectionModel = section
        self.color = section.color
        super.init(nibName: nil, bundle: nil)
		
        // Set the tab bar item with universal insets
        self.tabBarItem = UITabBarItem(title: section.tabBarTitle, image: section.tabBarIcon, tag: section.nid)
        
        // Hide title and inset (center) images if not showing titles
        if Common.Layout.showTabBarTitles == false {
            self.tabBarItem.title = ""
            self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        }
        
        // Subscribe to tab bar height changes
        NotificationCenter.default.addObserver(self, selector: #selector(SectionViewController.tabBarHeightDidChange), name: NSNotification.Name(rawValue: Common.Notifications.tabBarHeightDidChangeNotification), object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Track this screen
        AICAnalytics.trackScreen(named: sectionModel.title)
    }
    
//    override func loadView() {
//        self.view = sectionView
//    }
	
    internal func reset() {
        // Override this to reset view when going back
    }
}

extension SectionViewController {
    // When the tab bar height changes, change the size of our view so anything bottom aligned
    // does not get hidden by the mini player
    @objc func tabBarHeightDidChange() {
//        self.sectionView.frame.size.height = UIScreen.main.bounds.height - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight
//        viewableMapArea = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight)
//        recalculateViewableMapArea()
    }
}
