/*
 Abstract:
 Section View controller for What's On (News) Section
*/

import UIKit
import CoreLocation

protocol WhatsOnSectionViewControllerDelegate : class {
    func whatsOnSectionViewController(_ whatsOnSectionViewController:WhatsOnSectionViewController, shouldShowNewsItemOnMap item:AICNewsItemModel)
}

class WhatsOnSectionViewController : NewsToursSectionViewController {
    var items:[AICNewsItemModel] = [] {
        didSet {
            self.listTableView.reloadData()
        }
    }
    
    weak var delegate:WhatsOnSectionViewControllerDelegate?
    
    override init(section:AICSectionModel) {
        let whatsOnView = WhatsOnSectionView(section: section, revealView: NewsToursRevealView())
        super.init(section:section)
		self.view = whatsOnView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        //items = TestModels.sharedInstance.testNewsItems
        items = AppDataManager.sharedInstance.getAllNewsItems()
    }
    
    /**
     Custom NewsTourItemView implementation for What's On section
    */
    override func getModel(forRow row: Int) -> AICNewsTourItemProtocol? {
        return items[row]
    }
    
    override func setDistances(fromUserLocation userLocation: CLLocation) {
        for cell in listTableView.visibleCells {
            if let cell = cell as? NewsToursTableViewCell {
                if let model = cell.model as? AICNewsItemModel {
                    let distance  = Common.Location.getTime(fromUserLocation: userLocation, toObjectLocation: model.location)
                    cell.setDistance(toValue: Int(distance))
                }
            }
        }
    }
}

// MARK: UITableViewDelegate
extension WhatsOnSectionViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}

extension WhatsOnSectionViewController {
    override func newsToursTableViewCellWasTapped(_ cell: NewsToursTableViewCell) {
        super.newsToursTableViewCellWasTapped(cell)
        if cell.mode == .open {
            AICAnalytics.sendNewsItemExpandedEvent(forNewsItem: cell.model as! AICNewsItemModel)
        }
    }
    
    override func newsToursTableViewCellRevealContentTapped(_ cell: NewsToursTableViewCell) {
        super.newsToursTableViewCellRevealContentTapped(cell)
        delegate?.whatsOnSectionViewController(self, shouldShowNewsItemOnMap: cell.model as! AICNewsItemModel)
    }
}
