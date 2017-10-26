/*
 Abstract:
 Base view for News (What's on) and Tours section views. Adds table view and reveal view functionality
*/

import UIKit
import CoreLocation

protocol NewsToursSectionViewControllerDelegate : class {
    func newsToursSectionViewController(_ controller: NewsToursSectionViewController, didCloseReveal reveal:NewsToursRevealView)
}

class NewsToursSectionViewController : SectionViewController {
    weak var newsToursDelegate: NewsToursSectionViewControllerDelegate? = nil
    
    var listTableView:UITableView!
    
    var cells:[NewsToursTableViewCell] = []
    
    override init(section:AICSectionModel, sectionView: SectionView) {
        super.init(section:section, sectionView: sectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        // Store a reference to the table view for convenience
        let sectionView = self.sectionView as! NewsToursSectionView
        listTableView = sectionView.listView
        
        // Set ourself to delegate and datasource for table view
        listTableView.delegate = self
        listTableView.dataSource = self
        
        listTableView.register(NewsToursTableViewCell.self, forCellReuseIdentifier: "cell")
        
        let revealCloseTap = UITapGestureRecognizer(target: self, action: #selector(NewsToursSectionViewController.revealViewCloseButtonTapped))
        sectionView.revealView.closeButton.addGestureRecognizer(revealCloseTap)
    }
    
    /**
     Override this method in your inheriting class to set up custom models
    */
    internal func getModel(forRow row:Int) -> AICNewsTourItemProtocol? {
        return nil
    }
    
    /**
     Override this method in your inheriting class to set up custom item views
     */
    internal func setAdditionalInformation(forCell cell:NewsToursTableViewCell) {}
    
    /**
     Override this method in your inheriting class to set up custom item views
     */
    internal func setDistances(fromUserLocation userLocation:CLLocation) {}
    
    
    override internal func recalculateViewableMapArea() {
        let sectionView = self.sectionView as! NewsToursSectionView
        
        if sectionView.mode == .reveal {
            self.viewableMapArea = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width,
                                              height: UIScreen.main.bounds.height - sectionView.revealView.bounds.height - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight
            )
        } else {
            self.viewableMapArea = self.view.frame
        }
    }
    
    internal func showReveal(forModel model:AICNewsTourItemProtocol) {
        let sectionView = self.sectionView as! NewsToursSectionView
        
        sectionView.setReveal(forModel: model)
        sectionView.mode = .reveal
        
        recalculateViewableMapArea()
    }
    
    internal func closeAllListCells(withAnimation animated:Bool, andUpdateTable:Bool = true) {
        if listTableView != nil {
            for rowNum in 0..<Int(listTableView.numberOfRows(inSection: 0)) {
                if let thisCell = listTableView.cellForRow(at: IndexPath(item:rowNum, section:0)) as? NewsToursTableViewCell {
                    if thisCell.mode == .open {
                        UIView.setAnimationsEnabled(animated)
                        thisCell.mode = .closed
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
            
            if andUpdateTable {
                listTableView.beginUpdates()
                listTableView.endUpdates()
            }
        }
    }
    
    override func reset() {
        let sectionView = self.sectionView as! NewsToursSectionView
        sectionView.mode = .list
        
        closeAllListCells(withAnimation: false)
        
        sectionView.scrollView.contentOffset.y = 0
        
        self.view.updateConstraints()
    }
}

// MARK: UICollectionViewDataSource
extension NewsToursSectionViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
}

extension NewsToursSectionViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assertionFailure("NewsToursSectionViewController numberOfRowsInSectionCalled, this method needs to be overriden by derived class")
        return 0
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = cells.filter({$0.tag == (indexPath as NSIndexPath).row}).first {
            return cell
        }
        
        let newsToursCell = NewsToursTableViewCell(model: getModel(forRow: (indexPath as NSIndexPath).row)!)
        newsToursCell.delegate = self
        newsToursCell.tag = (indexPath as NSIndexPath).row
        setAdditionalInformation(forCell: newsToursCell)
        
        cells.append(newsToursCell)
        return newsToursCell
    }
}

extension NewsToursSectionViewController : NewsToursTableViewCellDelegate {
    func newsToursTableViewCellWasTapped(_ cell: NewsToursTableViewCell) {
        if cell.mode == .closed {
            self.closeAllListCells(withAnimation: false, andUpdateTable: false)
            cell.mode = .open
            
            self.listTableView.beginUpdates()
            self.listTableView.endUpdates()
        } else {
            self.closeAllListCells(withAnimation: false)
        }
        
        self.sectionView.updateConstraints()
        
        self.sectionView.scrollView.setNeedsLayout()
        self.sectionView.scrollView.layoutIfNeeded()
        self.sectionView.scrollView.setNeedsDisplay()
        
        // Scroll to the top of this item, making sure it doesn't end up above the bottom
        let maxYOffset = sectionView.scrollView.contentSize.height - sectionView.scrollView.bounds.size.height
        
        var yOffset = self.listTableView.frame.origin.y + self.listTableView.rectForRow(at: IndexPath(item: cell.tag, section: 0)).origin.y - self.sectionView.titleView.minimizedHeight
        
        if yOffset > maxYOffset {
            yOffset = maxYOffset
        }
        
        self.sectionView.scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
    }
    
    func newsToursTableViewCellRevealContentTapped(_ cell: NewsToursTableViewCell) {
        showReveal(forModel: cell.model)
    }
}

extension NewsToursSectionViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update object distances only if we are in the museum (based on availability of the CLFloor object)
        if locations[0].floor != nil || Common.Testing.testNewsToursDistances == true {
            setDistances(fromUserLocation: locations[0])
        }
    }
}

// Reveal view gestures
extension NewsToursSectionViewController {
    @objc func revealViewCloseButtonTapped() {
        let sectionView = self.sectionView as! NewsToursSectionView
        sectionView.mode = .list
        
        closeAllListCells(withAnimation: false)
        sectionView.updateConstraints()
        
        recalculateViewableMapArea()
        newsToursDelegate?.newsToursSectionViewController(self, didCloseReveal:sectionView.revealView)
    }
}
