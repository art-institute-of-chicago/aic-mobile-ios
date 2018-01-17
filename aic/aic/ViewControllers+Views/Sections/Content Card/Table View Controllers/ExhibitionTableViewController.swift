//
//  ExhibitionTableViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/15/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class ExhibitionTableViewController : UITableViewController {
	let exhibitionModel: AICExhibitionModel
	
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
		self.tableView.alwaysBounceVertical = false
		//self.tableView.bounces = false
		//self.tableView.register(UINib(nibName: "TourContentCell", bundle: Bundle.main), forCellReuseIdentifier: TourContentCell.reuseIdentifier)
		//self.tableView.register(UINib(nibName: "ContentButtonCell", bundle: Bundle.main), forCellReuseIdentifier: ContentButtonCell.reuseIdentifier)
		self.tableView.register(CardTitleView.self, forHeaderFooterViewReuseIdentifier: CardTitleView.reuseIdentifier)
		self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
	}
}

// MARK: Data Source
extension ExhibitionTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
//			let cell = tableView.dequeueReusableCell(withIdentifier: TourContentCell.reuseIdentifier, for: indexPath) as! TourContentCell
//			cell.tourModel = tourModel
//			return cell
		}
		return UITableViewCell()
	}
}

// MARK: Layout
extension ExhibitionTableViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CardTitleView.reuseIdentifier) as! CardTitleView
		titleView.titleLabel.text = exhibitionModel.title
		return titleView
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 80
	}
}

