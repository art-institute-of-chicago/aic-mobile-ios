//
//  SearchResultsTableViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol ResultsTableViewControllerDelegate : class {
	func resultsTableDidSelect(searchText: String)
	func resultsTableDidSelect(artwork: AICSearchedArtworkModel)
	func resultsTableDidSelect(tour: AICTourModel)
	func resultsTableDidSelect(exhibition: AICExhibitionModel)
	func resultsTableDidSelect(filter: Common.Search.Filter)
	func resultsTableViewWillScroll()
}

/// ResultsTableViewController
///
/// TableViewController showing results for all content types and filters.
/// Different number of sections and rows are shown based on the active filter and the results.
///
/// - Filter: .empty
///   - Section 0: Promoted searches
///   - Section 1: Map Items
///
/// - Filter: .suggested
///   - Section 0: Autocomplete strings
///   - Section 1: No Results
///   - Section 2: Artworks
///   - Section 3: Tours
///   - Section 4: Exhibitions
///   - Section 5: Map Items
///
/// - Filter: .artworks
///   - Section 0: No Results
///   - Section 1: Artworks
///
/// - Filter: .tours
///   - Section 0: No Results
///   - Section 1: Tours
///
/// - Filter: .exhibitions
///   - Section 0: No Results
///   - Section 1: Exhibitions
///
class ResultsTableViewController : UITableViewController {
	var promotedSearchStringItems: [String] = []
	var autocompleteStringItems: [String] = []
	var artworkItems: [AICSearchedArtworkModel] = []
	var tourItems: [AICTourModel] = []
	var exhibitionItems: [AICExhibitionModel] = []
	
	var filter: Common.Search.Filter = .empty {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	weak var searchDelegate: ResultsTableViewControllerDelegate? = nil
	
	weak var sectionsVC: SectionsViewController? = nil
	
	private var contentLoadedForFilter: [Common.Search.Filter : Bool] = [:]
	
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
//		self.tableView.rowHeight = UITableViewAutomaticDimension // Necessary for AutoLayout of cells
//		self.tableView.estimatedRowHeight = 30
		self.tableView.alwaysBounceVertical = false
		//self.tableView.bounces = false
		self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
		self.tableView.register(UINib(nibName: "SuggestedSearchCell", bundle: Bundle.main), forCellReuseIdentifier: SuggestedSearchCell.reuseIdentifier)
		self.tableView.register(UINib(nibName: "ContentButtonCell", bundle: Bundle.main), forCellReuseIdentifier: ContentButtonCell.reuseIdentifier)
		self.tableView.register(UINib(nibName: "MapItemsCollectionContainerCell", bundle: Bundle.main), forCellReuseIdentifier: MapItemsCollectionContainerCell.reuseIdentifier)
		self.tableView.register(UINib(nibName: "NoResultsCell", bundle: Bundle.main), forCellReuseIdentifier: NoResultsCell.reuseIdentifier)
		self.tableView.register(ResultsSectionTitleView.self, forHeaderFooterViewReuseIdentifier: ResultsSectionTitleView.reuseIdentifier)
		self.tableView.register(ResultsContentTitleView.self, forHeaderFooterViewReuseIdentifier: ResultsContentTitleView.reuseIdentifier)
		
		promotedSearchStringItems = AppDataManager.sharedInstance.app.searchStrings
		
        self.filter = .empty
		
		resetContentLoaded()
	}
	
	// MARK: Content Loaded
	
	public func setContentLoadedForFilter(filter: Common.Search.Filter, loaded: Bool) {
		contentLoadedForFilter[filter] = loaded
	}
	
	public func resetContentLoaded() {
		autocompleteStringItems.removeAll()
		artworkItems.removeAll()
		tourItems.removeAll()
		exhibitionItems.removeAll()
		
		contentLoadedForFilter = [
			.tours : false,
			.artworks : false,
			.exhibitions : false
		]
	}
	
	private func isContentLoadedForFilter(filter: Common.Search.Filter) -> Bool {
		guard let loaded = contentLoadedForFilter[filter] else {
			return false
		}
		return loaded
	}
	
	private func isAllContentLoadedWithNoResults() -> Bool {
		return contentLoadedForFilter[.artworks] == true
			&& contentLoadedForFilter[.tours] == true
			&& contentLoadedForFilter[.exhibitions] == true
			&& artworkItems.count == 0
			&& tourItems.count == 0
			&& exhibitionItems.count == 0
	}
}

// MARK: Scroll events
extension ResultsTableViewController {
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.searchDelegate?.resultsTableViewWillScroll()
	}
}

// MARK: Data Source
extension ResultsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		if filter == .empty {
			return 2
		}
		else if filter == .suggested {
			return 6
		}
		else if filter == .artworks || filter == .tours || filter == .exhibitions {
			return 2
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if filter == .empty {
			if section == 0 {
				return promotedSearchStringItems.count
			}
			else if section == 1 {
				return 1
			}
		}
		else if filter == .suggested {
			if section == 0 {
				return min(autocompleteStringItems.count, 3)
			}
			else if section == 1 {
				if isAllContentLoadedWithNoResults() && autocompleteStringItems.isEmpty {
					return 1
				}
				return 0
			}
			else if section == 2 {
				return min(artworkItems.count, 3)
			}
			else if section == 3 {
				return min(tourItems.count, 3)
			}
			else if section == 4 {
				return min(exhibitionItems.count, 3)
			}
			else if section == 5 {
				return 1
			}
		}
		else if filter == .artworks {
			if section == 0 {
				if contentLoadedForFilter[.artworks] == true && artworkItems.count == 0 {
					return 1
				}
			}
			else if section == 1 {
				return artworkItems.count
			}
			return 0
		}
		else if filter == .tours {
			if section == 0 {
				if contentLoadedForFilter[.tours] == true && tourItems.count == 0 {
					return 1
				}
			}
			else if section == 1 {
				return tourItems.count
			}
			return 0
		}
		else if filter == .exhibitions {
			if section == 0 {
				if contentLoadedForFilter[.exhibitions] == true && exhibitionItems.count == 0 {
					return 1
				}
			}
			else if section == 1 {
				return exhibitionItems.count
			}
			return 0
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if filter == .empty {
			if indexPath.section == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedSearchCell.reuseIdentifier, for: indexPath) as! SuggestedSearchCell
				cell.suggestedSearchLabel.textColor = .white
				cell.suggestedSearchLabel.text = promotedSearchStringItems[indexPath.row]
				return cell
			}
			else if indexPath.section == 1 {
				// map items cell
				let cell = tableView.dequeueReusableCell(withIdentifier: MapItemsCollectionContainerCell.reuseIdentifier, for: indexPath) as! MapItemsCollectionContainerCell
				cell.delegate = sectionsVC
				cell.innerCollectionView.reloadData()
				return cell
			}
		}
		else if filter == .suggested {
			if indexPath.section == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedSearchCell.reuseIdentifier, for: indexPath) as! SuggestedSearchCell
				cell.suggestedSearchLabel.textColor = .aicCardDarkTextColor
				cell.suggestedSearchLabel.text = autocompleteStringItems[indexPath.row]
				return cell
			}
			else if indexPath.section == 1 {
				let cell = tableView.dequeueReusableCell(withIdentifier: NoResultsCell.reuseIdentifier, for: indexPath) as! NoResultsCell
				return cell
			}
			else if indexPath.section == 2 {
				// artwork cell
				let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
				let artwork = artworkItems[indexPath.row]
				var cropRect: CGRect? = nil
				if let object = artwork.audioObject {
					cropRect = object.imageCropRect
				}
				setupDividerLines(cell, indexPath: indexPath, itemsCount: artworkItems.count)
				cell.setContent(imageUrl: artwork.thumbnailUrl, cropRect: cropRect, title: artwork.title, subtitle: artwork.gallery.title, showAudioIcon: artwork.audioObject != nil)
				return cell
			}
			else if indexPath.section == 3 {
				// tour cell
				let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
				var tour = tourItems[indexPath.row]
				if tour.availableLanguages.contains(Common.currentLanguage) {
					tour.language = Common.currentLanguage
				}
				setupDividerLines(cell, indexPath: indexPath, itemsCount: tourItems.count)
				cell.setContent(imageUrl: tour.imageUrl, cropRect: nil, title: tour.title, subtitle: "") // TODO: add Gallery Name
				return cell
			}
			else if indexPath.section == 4 {
				// exhibition cell
				let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
				let exhibition = exhibitionItems[indexPath.row]
				setupDividerLines(cell, indexPath: indexPath, itemsCount: exhibitionItems.count)
				cell.setContent(imageUrl: exhibition.imageUrl, cropRect: nil, title: exhibition.title, subtitle: "")
				return cell
			}
			else if indexPath.section == 5 {
				// map items cell
				let cell = tableView.dequeueReusableCell(withIdentifier: MapItemsCollectionContainerCell.reuseIdentifier, for: indexPath) as! MapItemsCollectionContainerCell
				cell.delegate = sectionsVC
				cell.innerCollectionView.reloadData()
				return cell
			}
		}
		else if filter == .artworks {
			if indexPath.section == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: NoResultsCell.reuseIdentifier, for: indexPath) as! NoResultsCell
				return cell
			}
			else if indexPath.section == 1 {
				let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
				let artwork = artworkItems[indexPath.row]
				var cropRect: CGRect? = nil
				if let object = artwork.audioObject {
					cropRect = object.imageCropRect
				}
				setupDividerLines(cell, indexPath: indexPath, itemsCount: artworkItems.count)
				cell.setContent(imageUrl: artwork.thumbnailUrl, cropRect: cropRect, title: artwork.title, subtitle: artwork.gallery.title, showAudioIcon: artwork.audioObject != nil)
				return cell
			}
		}
		else if filter == .tours {
			if indexPath.section == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: NoResultsCell.reuseIdentifier, for: indexPath) as! NoResultsCell
				return cell
			}
			else if indexPath.section == 1 {
				let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
				var tour = tourItems[indexPath.row]
				if tour.availableLanguages.contains(Common.currentLanguage) {
					tour.language = Common.currentLanguage
				}
				setupDividerLines(cell, indexPath: indexPath, itemsCount: tourItems.count)
				cell.setContent(imageUrl: tour.imageUrl, cropRect: nil, title: tour.title, subtitle: "") // TODO: add Gallery Name
				return cell
			}
		}
		else if filter == .exhibitions {
			if indexPath.section == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: NoResultsCell.reuseIdentifier, for: indexPath) as! NoResultsCell
				return cell
			}
			else if indexPath.section == 1 {
				let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
				let exhibition = exhibitionItems[indexPath.row]
				setupDividerLines(cell, indexPath: indexPath, itemsCount: exhibitionItems.count)
				cell.setContent(imageUrl: exhibition.imageUrl, cropRect: nil, title: exhibition.title, subtitle: "")
				return cell
			}
		}
		return UITableViewCell()
	}
	
	func setupDividerLines(_ cell: ContentButtonCell, indexPath: IndexPath, itemsCount: Int) {
		if filter == .suggested {
			if itemsCount == 1 {
				cell.dividerLineTop.isHidden = true; cell.dividerLineBottom.isHidden = true
			}
			else if itemsCount == 2 {
				if indexPath.row == 0 { cell.dividerLineTop.isHidden = true; cell.dividerLineBottom.isHidden = false }
				if indexPath.row == 1 { cell.dividerLineTop.isHidden = true; cell.dividerLineBottom.isHidden = true }
			}
			else if itemsCount >= 3 {
				if indexPath.row == 0 { cell.dividerLineTop.isHidden = true; cell.dividerLineBottom.isHidden = false }
				if indexPath.row == 1 { cell.dividerLineTop.isHidden = true; cell.dividerLineBottom.isHidden = false }
				if indexPath.row == 2 { cell.dividerLineTop.isHidden = true; cell.dividerLineBottom.isHidden = true }
			}
		}
		else if filter == .artworks || filter == .tours || filter == .exhibitions {
			if indexPath.row == 0 { cell.dividerLineTop.isHidden = true; cell.dividerLineBottom.isHidden = true }
			else { cell.dividerLineTop.isHidden = false; cell.dividerLineBottom.isHidden = true }
		}
	}
}

// MARK: Layout
extension ResultsTableViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if filter == .empty {
			if section <= 1 {
				let titles = ["Search".localized(using: "Search"), "On the Map".localized(using: "Search")]
				let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsSectionTitleView.reuseIdentifier) as! ResultsSectionTitleView
				titleView.titleLabel.text = titles[section]
				return titleView
			}
		}
		if filter == .suggested {
			if section == 2 && artworkItems.count > 0 {
				// artworks header
				let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsContentTitleView.reuseIdentifier) as! ResultsContentTitleView
				titleView.contentTitleLabel.text = "Artworks".localized(using: "Search")
				titleView.seeAllButton.setTitle("See All".localized(using: "Sections"), for: .normal)
				titleView.seeAllButton.addTarget(self, action: #selector(seeAllArtworksButtonPressed(button:)), for: .touchUpInside)
				return titleView
			}
			else if section == 3 && tourItems.count > 0 {
				// tours header
				let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsContentTitleView.reuseIdentifier) as! ResultsContentTitleView
				titleView.contentTitleLabel.text = "Tours".localized(using: "Search")
				titleView.seeAllButton.setTitle("See All".localized(using: "Sections"), for: .normal)
				titleView.seeAllButton.addTarget(self, action: #selector(seeAllToursButtonPressed(button:)), for: .touchUpInside)
				return titleView
			}
			else if section == 4 && exhibitionItems.count > 0 {
				// exhibitions header
				let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsContentTitleView.reuseIdentifier) as! ResultsContentTitleView
				titleView.contentTitleLabel.text = "Exhibitions".localized(using: "Search")
				titleView.seeAllButton.setTitle("See All".localized(using: "Sections"), for: .normal)
				titleView.seeAllButton.addTarget(self, action: #selector(seeAllExhibitionsButtonPressed(button:)), for: .touchUpInside)
				return titleView
			}
			else if section == 5 {
				let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsSectionTitleView.reuseIdentifier) as! ResultsSectionTitleView
				titleView.titleLabel.text = "On the Map".localized(using: "Search")
				return titleView
			}
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if filter == .empty {
			return ResultsSectionTitleView.titleHeight
		}
		if filter == .suggested {
			if section == 2 && artworkItems.count > 0 {
				return ResultsContentTitleView.titleHeight
			}
			else if section == 3 && tourItems.count > 0 {
				return ResultsContentTitleView.titleHeight
			}
			else if section == 4 && exhibitionItems.count > 0 {
				return ResultsContentTitleView.titleHeight
			}
			else if section == 5 {
				return ResultsSectionTitleView.titleHeight
			}
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if filter == .empty {
			if indexPath.section == 0 {
				return SuggestedSearchCell.cellHeight
			}
			else if indexPath.section == 1 {
				return MapItemsCollectionContainerCell.cellHeight
			}
		}
		else if filter == .suggested {
			if indexPath.section == 0 {
				return SuggestedSearchCell.cellHeight
			}
			else if indexPath.section == 1 {
				return NoResultsCell.cellHeight
			}
			else if indexPath.section == 2 {
				return ContentButtonCell.cellHeight
			}
			else if indexPath.section == 3 {
				return ContentButtonCell.cellHeight
			}
			else if indexPath.section == 4 {
				return ContentButtonCell.cellHeight
			}
			else if indexPath.section == 5 {
				return MapItemsCollectionContainerCell.cellHeight
			}
		}
		else if filter == .artworks {
			if indexPath.section == 0 {
				return NoResultsCell.cellHeight
			}
			else if indexPath.section == 1 {
				if artworkItems.count > 0 {
					return ContentButtonCell.cellHeight
				}
			}
		}
		else if filter == .tours {
			if indexPath.section == 0 {
				return NoResultsCell.cellHeight
			}
			else if indexPath.section == 1 {
				if tourItems.count > 0 {
					return ContentButtonCell.cellHeight
				}
			}
		}
		else if filter == .exhibitions {
			if indexPath.section == 0 {
				return NoResultsCell.cellHeight
			}
			else if indexPath.section == 1 {
				if exhibitionItems.count > 0 {
					return ContentButtonCell.cellHeight
				}
			}
		}
		return 0
	}
}

// MARK: Interaction
extension ResultsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if filter == .empty {
			if indexPath.section == 0 {
				let searchText = promotedSearchStringItems[indexPath.row]
				self.searchDelegate?.resultsTableDidSelect(searchText: searchText)
			}
		}
		else if filter == .suggested {
			if indexPath.section == 0 {
				let searchText = autocompleteStringItems[indexPath.row]
				self.searchDelegate?.resultsTableDidSelect(searchText: searchText)
			}
			else if indexPath.section == 2 {
				let artwork = artworkItems[indexPath.row]
				self.searchDelegate?.resultsTableDidSelect(artwork: artwork)
			}
			else if indexPath.section == 3 {
				let tour = tourItems[indexPath.row]
				self.searchDelegate?.resultsTableDidSelect(tour: tour)
			}
			else if indexPath.section == 4 {
				let exhibition = exhibitionItems[indexPath.row]
				self.searchDelegate?.resultsTableDidSelect(exhibition: exhibition)
			}
		}
		else if filter == .artworks {
			if indexPath.section == 1 {
				let artwork = artworkItems[indexPath.row]
				self.searchDelegate?.resultsTableDidSelect(artwork: artwork)
			}
		}
		else if filter == .tours {
			if indexPath.section == 1 {
				let tour = tourItems[indexPath.row]
				self.searchDelegate?.resultsTableDidSelect(tour: tour)
			}
		}
		else if filter == .exhibitions {
			if indexPath.section == 1 {
				let exhibition = exhibitionItems[indexPath.row]
				self.searchDelegate?.resultsTableDidSelect(exhibition: exhibition)
			}
		}
	}
}

// MARK: Scroll Delegate
extension ResultsTableViewController {
	/// Avoid bouncing at the top of the TableView
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if (scrollView.contentOffset.y <= 0) {
			scrollView.contentOffset = CGPoint.zero
		}
	}
}

// MARK: See All Buttons Events
extension ResultsTableViewController {
	@objc func seeAllArtworksButtonPressed(button: UIButton) {
		self.searchDelegate?.resultsTableDidSelect(filter: .artworks)
	}
	
	@objc func seeAllToursButtonPressed(button: UIButton) {
		self.searchDelegate?.resultsTableDidSelect(filter: .tours)
	}
	
	@objc func seeAllExhibitionsButtonPressed(button: UIButton) {
		self.searchDelegate?.resultsTableDidSelect(filter: .exhibitions)
	}
}
