//
//  ExhibitionTableViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/15/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol ExhibitionTableViewControllerDelegate : class {
	func exhibitionContentCardDidPressShowOnMap(exhibition: AICExhibitionModel)
}

class ExhibitionTableViewController : UITableViewController {
	let exhibitionModel: AICExhibitionModel
	
	weak var exhibitionTableDelegate: ExhibitionTableViewControllerDelegate? = nil
	
	init(exhibition: AICExhibitionModel) {
		exhibitionModel = exhibition
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .clear
		
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		
		self.tableView.backgroundColor = .aicDarkGrayColor
		self.tableView.separatorStyle = .none
		self.tableView.rowHeight = UITableViewAutomaticDimension // Necessary for AutoLayout of cells
		self.tableView.estimatedRowHeight = 200
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
		self.tableView.register(UINib(nibName: "ExhibitionContentCell", bundle: Bundle.main), forCellReuseIdentifier: ExhibitionContentCell.reuseIdentifier)
		self.tableView.register(CardTitleView.self, forHeaderFooterViewReuseIdentifier: CardTitleView.reuseIdentifier)
	}
	
	// MARK: Button Events
	
	@objc func exhibitionShowOnMapButtonPressed(button: UIButton) {
		self.exhibitionTableDelegate?.exhibitionContentCardDidPressShowOnMap(exhibition: exhibitionModel)
	}
	
	@objc func exhibitionBuyTicketsButtonPressed(button: UIButton) {
		if let url = URL(string: AppDataManager.sharedInstance.app.dataSettings[.ticketsUrl]!) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
}

// MARK: Data Source
extension ExhibitionTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: ExhibitionContentCell.reuseIdentifier, for: indexPath) as! ExhibitionContentCell
			cell.exhibitionModel = exhibitionModel
			cell.buyTicketsButton.addTarget(self, action: #selector(exhibitionBuyTicketsButtonPressed(button:)), for: .touchUpInside)
			cell.showOnMapButton.addTarget(self, action: #selector(exhibitionShowOnMapButtonPressed(button:)), for: .touchUpInside)
			return cell
		}
		return UITableViewCell()
	}
}

// MARK: Layout
extension ExhibitionTableViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CardTitleView.reuseIdentifier) as! CardTitleView
		titleView.titleLabel.text = exhibitionModel.title.stringByDecodingHTMLEntities
		return titleView
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 80
	}
}

// MARK: Scroll Delegate
extension ExhibitionTableViewController {
    /// Avoid bouncing at the top of the TableView
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0) {
            scrollView.contentOffset = CGPoint.zero
        }
    }
}

