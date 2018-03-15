//
//  ArtworkTableViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/15/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol ArtworkTableViewControllerDelegate : class {
	func artworkContentCardDidPressPlayAudio(artwork: AICObjectModel)
	func artworkContentCardDidPressShowOnMap(artwork: AICSearchedArtworkModel)
}

class ArtworkTableViewController : UITableViewController {
	var artworkModel: AICSearchedArtworkModel
	
	weak var artworkTableDelegate: ArtworkTableViewControllerDelegate? = nil
	
	init(artwork: AICSearchedArtworkModel) {
		artworkModel = artwork
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
		self.tableView.register(UINib(nibName: "ArtworkContentCell", bundle: Bundle.main), forCellReuseIdentifier: ArtworkContentCell.reuseIdentifier)
		self.tableView.register(CardTitleView.self, forHeaderFooterViewReuseIdentifier: CardTitleView.reuseIdentifier)
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}
	
	@objc private func updateLanguage() {
		self.tableView.reloadData()
	}
	
	// MARK: Button Events
	
	@objc func artworkPlayButtonPressed(button: UIButton) {
		if let artworkWithAudio = artworkModel.audioObject {
			self.artworkTableDelegate?.artworkContentCardDidPressPlayAudio(artwork: artworkWithAudio)
		}
	}
	
	@objc func artworkShowOnMapButtonPressed(button: UIButton) {
		self.artworkTableDelegate?.artworkContentCardDidPressShowOnMap(artwork: artworkModel)
	}
}

// MARK: Data Source
extension ArtworkTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: ArtworkContentCell.reuseIdentifier, for: indexPath) as! ArtworkContentCell
			cell.artworkModel = artworkModel
			cell.playAudioButton.setTitle("Play Audio".localized(using: "ContentCard"), for: .normal)
			cell.playAudioButton.addTarget(self, action: #selector(artworkPlayButtonPressed(button:)), for: .touchUpInside)
			cell.showOnMapButton.setTitle("Show On Map".localized(using: "ContentCard"), for: .normal)
			cell.showOnMapButton.addTarget(self, action: #selector(artworkShowOnMapButtonPressed(button:)), for: .touchUpInside)
			return cell
		}
		return UITableViewCell()
	}
}

// MARK: Layout
extension ArtworkTableViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CardTitleView.reuseIdentifier) as! CardTitleView
		titleView.titleLabel.text = artworkModel.title
		return titleView
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 80
	}
}

// MARK: Scroll Delegate
extension ArtworkTableViewController {
    /// Avoid bouncing at the top of the TableView
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0) {
            scrollView.contentOffset = CGPoint.zero
        }
    }
}
