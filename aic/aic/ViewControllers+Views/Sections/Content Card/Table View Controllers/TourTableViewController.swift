//
//  TourTableViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class TourTableViewController : UITableViewController {
	let tourModel: AICTourModel
	
	init(tour: AICTourModel) {
		tourModel = tour
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
		self.tableView.alwaysBounceVertical = false
		//self.tableView.bounces = false
		self.tableView.register(UINib(nibName: "TourContentCell", bundle: Bundle.main), forCellReuseIdentifier: TourContentCell.reuseIdentifier)
		self.tableView.register(UINib(nibName: "ContentButtonCell", bundle: Bundle.main), forCellReuseIdentifier: ContentButtonCell.reuseIdentifier)
		self.tableView.register(CardTitleView.self, forHeaderFooterViewReuseIdentifier: CardTitleView.reuseIdentifier)
		self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
	}
}

// MARK: Data Source
extension TourTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// tour intro + first stop (overview) + list of stops
		return 1 + 1 + tourModel.stops.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: TourContentCell.reuseIdentifier, for: indexPath) as! TourContentCell
			cell.tourModel = tourModel
			return cell
		}
		else if indexPath.row == 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
			cell.setContent(imageUrl: tourModel.imageUrl, title: tourModel.title, subtitle: "Tour Overview")
			cell.dividerLineBottom.isHidden = true
			return cell
		}
		else {
			let object = tourModel.stops[indexPath.row - 2].object
			let title = "\(indexPath.row - 1). \(object.title)"
			
			let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
			cell.setContent(imageUrl: object.imageUrl, title: title, subtitle: "Floor")
			cell.dividerLineBottom.isHidden = true
			return cell
		}
	}
}

// MARK: Layout
extension TourTableViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CardTitleView.reuseIdentifier) as! CardTitleView
		titleView.titleLabel.text = tourModel.title.stringByDecodingHTMLEntities
		return titleView
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 80
	}
}

// MARK: Interaction
extension TourTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
}

