/*
 Abstract:
 Base view controller for all Section Views (NumberPad, What's On, Tours, Nearby and Info)
*/

import UIKit

protocol SectionViewControllerDelegate : class {
    func sectionViewController(_ sectionViewController:SectionViewController, viewableMapAreaDidChange viewableArea:CGRect)
}

class SectionViewController : UIViewController {
    var color:UIColor
    let sectionModel:AICSectionModel
    let sectionView:SectionView!
    
    // Listen to changes in viewable map area and report to delegate
    var viewableMapArea:CGRect = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight) {
        didSet {
            if sectionView.superview != nil {
                viewableAreaDelegate?.sectionViewController(self, viewableMapAreaDidChange: viewableMapArea)
            }
        }
    }
    
    weak var viewableAreaDelegate:SectionViewControllerDelegate?
    
    init(section:AICSectionModel, sectionView:SectionView) {
        self.sectionModel = section
        self.sectionView = sectionView
        self.color = section.color
        
        super.init(nibName: nil, bundle: nil)
        
        // Set up delegate for scrolling
        self.sectionView.scrollView.delegate = self
        
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
    
    override func loadView() {
        self.view = sectionView
    }
    
    func recalculateViewableMapArea() {
        viewableMapArea = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight)
    }
    
    internal func reset() {
        // Override this to reset view when going back
    }
}

extension SectionViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let v = self.view as! SectionView
        
        let descriptionLabel = v.titleView.descriptionLabel
        if scrollView.contentOffset.y > 0 {
            let alpha = map(val: Double(scrollView.contentOffset.y), oldRange1: 50.0, oldRange2: 0.0, newRange1: 0.0, newRange2: 1.0)
            descriptionLabel.alpha = CGFloat(alpha)
        } else {
            descriptionLabel.alpha = 1.0
        }
    }
}

extension SectionViewController {
    // When the tab bar height changes, change the size of our view so anything bottom aligned
    // does not get hidden by the mini player
    func tabBarHeightDidChange() {
        self.sectionView.frame.size.height = UIScreen.main.bounds.height - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight
        viewableMapArea = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight)
        recalculateViewableMapArea()
    }
}
