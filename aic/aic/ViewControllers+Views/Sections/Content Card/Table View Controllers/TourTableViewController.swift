//
//  TourTableViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol TourTableViewControllerDelegate : class {
	func tourContentCardDidPressStartTour(tour: AICTourModel, language: Common.Language, stopIndex: Int?)
}

class TourTableViewController : UITableViewController {
	var tourModel: AICTourModel
	var language: Common.Language = .english
	
	weak var tourTableDelegate: TourTableViewControllerDelegate? = nil
	
	init(tour: AICTourModel) {
		tourModel = tour
		if tourModel.availableLanguages.contains(Common.currentLanguage) {
			language = Common.currentLanguage
			tourModel.language = Common.currentLanguage
		}
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
		self.tableView.register(UINib(nibName: "TourContentCell", bundle: Bundle.main), forCellReuseIdentifier: TourContentCell.reuseIdentifier)
		self.tableView.register(UINib(nibName: "ContentButtonCell", bundle: Bundle.main), forCellReuseIdentifier: ContentButtonCell.reuseIdentifier)
		self.tableView.register(CardTitleView.self, forHeaderFooterViewReuseIdentifier: CardTitleView.reuseIdentifier)
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}
	
	@objc private func updateLanguage() {
		self.tableView.reloadData()
	}
	
	// MARK: Button Events
	
	@objc func tourStartButtonPressed(button: UIButton) {
		self.tourTableDelegate?.tourContentCardDidPressStartTour(tour: tourModel, language: language, stopIndex: nil)
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
			cell.languageSelectorView.delegate = self
			cell.startTourButton.setTitle("Start Tour".localized(using: "ContentCard"), for: .normal)
			cell.startTourButton.addTarget(self, action: #selector(tourStartButtonPressed(button:)), for: .touchUpInside)
			return cell
		}
		else if indexPath.row == 1 {
			// tour overview cell
			let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
			let overviewLocation = tourModel.stops.first!.object.gallery.title
			cell.setContent(imageUrl: tourModel.imageUrl, cropRect: nil, title: tourModel.title, subtitle: overviewLocation)
			cell.dividerLineBottom.isHidden = true
			return cell
		}
		else {
			// tour stop cell
			let object = tourModel.stops[indexPath.row - 2].object
			let title = "\(indexPath.row - 1).\t\(object.title)"
			let subtitle = "\t\(object.gallery.title)"
			
			let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
			cell.setContent(imageUrl: object.thumbnailUrl, cropRect: object.imageCropRect, title: title, subtitle: subtitle)
			cell.dividerLineBottom.isHidden = true
			return cell
		}
	}
}

// MARK: Layout
extension TourTableViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CardTitleView.reuseIdentifier) as! CardTitleView
		titleView.titleLabel.text = tourModel.title
		return titleView
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 80
	}
}

// MARK: Scroll Delegate
extension TourTableViewController {
    /// Avoid bouncing at the top of the TableView
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0) {
            scrollView.contentOffset = CGPoint.zero
        }
    }
}

// MARK: Interaction
extension TourTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// tour overview stop
		if indexPath.row == 1 {
			self.tourTableDelegate?.tourContentCardDidPressStartTour(tour: tourModel, language: language, stopIndex: nil)
		}
		// tour stop
		else if indexPath.row > 1 {
			let stopIndex: Int = indexPath.row - 2
			if stopIndex < tourModel.stops.count {
				self.tourTableDelegate?.tourContentCardDidPressStartTour(tour: tourModel, language: language, stopIndex: stopIndex)
			}
		}
	}
}

// MARK: LanguageSelectorViewDelegate
extension TourTableViewController : LanguageSelectorViewDelegate {
	func languageSelectorDidSelect(language: Common.Language) {
		self.language = language
		tourModel.language = language
		self.tableView.reloadData()
	}
}

