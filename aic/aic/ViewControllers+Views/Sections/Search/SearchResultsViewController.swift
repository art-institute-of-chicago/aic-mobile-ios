//
//  SearchResultsTableViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SearchResultsViewController : UITableViewController {
	let promotedSearchStrings: [String] = ["Essentials Tour", "Impressionism", "American Gothic"]
	
	var filter: Common.Search.Filter = .empty {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	let contentTitleHeight: CGFloat = 65
	let resultsSectionTitleHeight: CGFloat = 50
	
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .aicDarkGrayColor
		
		self.tableView.separatorStyle = .none
		self.tableView.rowHeight = UITableViewAutomaticDimension // Necessary for AutoLayout of cells
		self.tableView.alwaysBounceVertical = false
		//self.tableView.bounces = false
		self.tableView.register(UINib(nibName: "SuggestedSearchCell", bundle: Bundle.main), forCellReuseIdentifier: SuggestedSearchCell.reuseIdentifier)
	}
}

extension SearchResultsViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if filter == .suggested {
			if section > 0 {
			let titleView = ContentTitleView(title: "Artworks")
				titleView.setDarkStyle(true)
				titleView.backgroundColor = .yellow
				return titleView
			}
			return nil
		}
		let titleView = ResultsSectionTitleView(title: "Search Content")
		return titleView
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if filter == .suggested {
			return contentTitleHeight
		}
		return resultsSectionTitleHeight
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row < 3 {
			let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedSearchCell.reuseIdentifier, for: indexPath) as! SuggestedSearchCell
			return cell
		}
		return UITableViewCell()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if filter == .empty {
			return 6
		}
		else if filter == .suggested {
			return 5
		}
		return 1
	}
}
