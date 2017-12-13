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
		
		self.tableView.backgroundColor = .aicDarkGrayColor
		self.tableView.separatorStyle = .none
		self.tableView.rowHeight = UITableViewAutomaticDimension // Necessary for AutoLayout of cells
//		self.tableView.estimatedRowHeight = 30
		self.tableView.alwaysBounceVertical = false
		//self.tableView.bounces = false
		self.tableView.register(UINib(nibName: "TourContentCell", bundle: Bundle.main), forCellReuseIdentifier: TourContentCell.reuseIdentifier)
		self.tableView.register(UINib(nibName: "ContentButtonCell", bundle: Bundle.main), forCellReuseIdentifier: ContentButtonCell.reuseIdentifier)
	}
}

// MARK: Data Source
extension TourTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: TourContentCell.reuseIdentifier, for: indexPath) as! TourContentCell
			cell.tourModel = tourModel
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
			return cell
		}
		return UITableViewCell()
	}
}

// MARK: Layout
extension TourTableViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return nil
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 {
			return 0
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 40
	}
}

// MARK: Interaction
extension TourTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
}

