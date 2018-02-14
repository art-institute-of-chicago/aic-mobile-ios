//
//  HomeViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/15/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol HomeViewControllerDelegate : class {
	func homeDidSelectAccessMemberCard()
	func homeDidSelectSeeAllTours()
	func homeDidSelectSeeAllExhibitions()
	func homeDidSelectSeeAllEvents()
	func homeDidSelectTour(tour: AICTourModel)
	func homeDidSelectExhibition(exhibition: AICExhibitionModel)
	func homeDidSelectEvent(event: AICEventModel)
}

class HomeViewController : SectionViewController {
	let scrollView: UIScrollView = UIScrollView()
	let memberPromptView: HomeMemberPromptView = HomeMemberPromptView()
	let toursTitleView: HomeContentTitleView = HomeContentTitleView(title: "Tours")
	let toursCollectionView: UICollectionView = createCollectionView(cellSize: HomeViewController.tourCellSize)
	let exhibitionsDividerLine: UIView = createDividerLine()
	let exhibitionsTitleView: HomeContentTitleView = HomeContentTitleView(title: "On View")
	let exhibitionsCollectionView: UICollectionView = createCollectionView(cellSize: HomeViewController.exhibitionCellSize)
	let eventsDividerLine: UIView = createDividerLine()
	let eventsTitleView: HomeContentTitleView = HomeContentTitleView(title: "Events")
	let eventsCollectionView: UICollectionView = createCollectionView(cellSize: HomeViewController.eventCellSize)
	
	var tourItems: [AICTourModel] = []
	var exhibitionItems: [AICExhibitionModel] = []
	var eventItems: [AICEventModel] = []
	
	static let tourCellSize: CGSize = CGSize(width: 285, height: 300)
	static let eventCellSize: CGSize = CGSize(width: 285, height: 320)
	static let exhibitionCellSize: CGSize = CGSize(width: 240, height: 380)
	
	weak var delegate: HomeViewControllerDelegate? = nil
	
	override init(section: AICSectionModel) {
		super.init(section: section)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.delegate = self
		
		memberPromptView.accessMemberCardButton.addTarget(self, action: #selector(accessMemberCardButtonPressed(button:)), for: .touchUpInside)
		
		toursCollectionView.register(UINib(nibName: "HomeTourCell", bundle: Bundle.main), forCellWithReuseIdentifier: HomeTourCell.reuseIdentifier)
		toursCollectionView.delegate = self
		toursCollectionView.dataSource = self
		toursTitleView.seeAllButton.addTarget(self, action: #selector(seeAllToursButtonPressed(button:)), for: .touchUpInside)
		
		exhibitionsCollectionView.register(UINib(nibName: "HomeExhibitionCell", bundle: Bundle.main), forCellWithReuseIdentifier: HomeExhibitionCell.reuseIdentifier)
		exhibitionsCollectionView.delegate = self
		exhibitionsCollectionView.dataSource = self
		exhibitionsTitleView.seeAllButton.addTarget(self, action: #selector(seeAllExhibitionsButtonPressed(button:)), for: .touchUpInside)
		
		eventsCollectionView.register(UINib(nibName: "HomeEventCell", bundle: Bundle.main), forCellWithReuseIdentifier: HomeEventCell.reuseIdentifier)
		eventsCollectionView.delegate = self
		eventsCollectionView.dataSource = self
		eventsTitleView.seeAllButton.addTarget(self, action: #selector(seeAllEventsButtonPressed(button:)), for: .touchUpInside)
		
		self.view.addSubview(scrollView)
		scrollView.addSubview(memberPromptView)
		scrollView.addSubview(toursTitleView)
		scrollView.addSubview(toursCollectionView)
		scrollView.addSubview(exhibitionsDividerLine)
		scrollView.addSubview(exhibitionsTitleView)
		scrollView.addSubview(exhibitionsCollectionView)
		scrollView.addSubview(eventsDividerLine)
		scrollView.addSubview(eventsTitleView)
		scrollView.addSubview(eventsCollectionView)
		
		createViewConstraints()
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// TODO: set max number of items (6) in Common / Settings
		tourItems = AppDataManager.sharedInstance.getToursForHome()
		exhibitionItems = AppDataManager.sharedInstance.getExhibitionsForHome()
		eventItems = AppDataManager.sharedInstance.getEventsForHome()
		
		self.view.layoutIfNeeded()
		self.scrollView.contentSize.width = self.view.frame.width
		self.scrollView.contentSize.height = eventsCollectionView.frame.origin.y + eventsCollectionView.frame.height + Common.Layout.miniAudioPlayerHeight
		
		self.scrollDelegate?.sectionViewControllerWillAppearWithScrollView(scrollView: scrollView)
		
		updateLanguage()
	}
	
	private static func createCollectionView(cellSize: CGSize) -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: cellSize.width, height: cellSize.height)
		layout.minimumLineSpacing = 20
		layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.backgroundColor = .white
		return collectionView
	}
	
	private static func createDividerLine() -> UIView {
		let view = UIView()
		view.backgroundColor = .aicDividerLineColor
		return view
	}
	
	func createViewConstraints() {
		scrollView.autoPinEdge(.top, to: .top, of: self.view)
		scrollView.autoPinEdge(.leading, to: .leading, of: self.view)
		scrollView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		scrollView.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: -Common.Layout.tabBarHeight)
		
		memberPromptView.autoPinEdge(.top, to: .top, of: scrollView, withOffset: Common.Layout.navigationBarVerticalOffset)
		memberPromptView.autoPinEdge(.leading, to: .leading, of: self.view)
		memberPromptView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		toursTitleView.autoPinEdge(.top, to: .bottom, of: memberPromptView)
		toursTitleView.autoPinEdge(.leading, to: .leading, of: self.view)
		toursTitleView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		toursTitleView.autoSetDimension(.height, toSize: 65)
		
		toursCollectionView.autoPinEdge(.top, to: .bottom, of: toursTitleView)
		toursCollectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		toursCollectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		toursCollectionView.autoSetDimension(.height, toSize: HomeViewController.tourCellSize.height)
		
		exhibitionsDividerLine.autoPinEdge(.top, to: .bottom, of: toursCollectionView, withOffset: 20)
		exhibitionsDividerLine.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
		exhibitionsDividerLine.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
		exhibitionsDividerLine.autoSetDimension(.height, toSize: 1)
		
		exhibitionsTitleView.autoPinEdge(.top, to: .bottom, of: exhibitionsDividerLine)
		exhibitionsTitleView.autoPinEdge(.leading, to: .leading, of: self.view)
		exhibitionsTitleView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		exhibitionsTitleView.autoSetDimension(.height, toSize: 65)
		
		exhibitionsCollectionView.autoPinEdge(.top, to: .bottom, of: exhibitionsTitleView)
		exhibitionsCollectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		exhibitionsCollectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		exhibitionsCollectionView.autoSetDimension(.height, toSize: HomeViewController.exhibitionCellSize.height)
		
		eventsDividerLine.autoPinEdge(.top, to: .bottom, of: exhibitionsCollectionView, withOffset: 30)
		eventsDividerLine.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
		eventsDividerLine.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
		eventsDividerLine.autoSetDimension(.height, toSize: 1)
		
		eventsTitleView.autoPinEdge(.top, to: .bottom, of: eventsDividerLine)
		eventsTitleView.autoPinEdge(.leading, to: .leading, of: self.view)
		eventsTitleView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		eventsTitleView.autoSetDimension(.height, toSize: 65)
		
		eventsCollectionView.autoPinEdge(.top, to: .bottom, of: eventsTitleView)
		eventsCollectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		eventsCollectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		eventsCollectionView.autoSetDimension(.height, toSize: HomeViewController.eventCellSize.height)
	}
	
	// MARK: Language
	
	@objc func updateLanguage() {
		let generalInfo = AppDataManager.sharedInstance.app.generalInfo
		var language: Common.Language = .english
		if generalInfo.availableLanguages.contains(Common.currentLanguage) {
			language = Common.currentLanguage
		}
		
		let homeMemberPromptText: String = generalInfo.translations[language]!.homeMemberPrompt
		memberPromptView.promptTextView.text = homeMemberPromptText.stringByDecodingHTMLEntities
		
		memberPromptView.accessMemberCardTextView.text = "Member Card Button Title".localized(using: "Home")
		
		toursTitleView.contentTitleLabel.text = "Tours".localized(using: "Sections")
		toursTitleView.seeAllButton.setTitle("See All".localized(using: "Sections"), for: .normal)
		
		exhibitionsTitleView.contentTitleLabel.text = "On View".localized(using: "Sections")
		exhibitionsTitleView.seeAllButton.setTitle("See All".localized(using: "Sections"), for: .normal)
		
		eventsTitleView.contentTitleLabel.text = "Events".localized(using: "Sections")
		eventsTitleView.seeAllButton.setTitle("See All".localized(using: "Sections"), for: .normal)
	}
	
	// MARK: Buttons
	
	@objc private func accessMemberCardButtonPressed(button: UIButton) {
		self.delegate?.homeDidSelectAccessMemberCard()
	}
	
	@objc private func seeAllToursButtonPressed(button: UIButton) {
		self.delegate?.homeDidSelectSeeAllTours()
	}
	
	@objc private func seeAllExhibitionsButtonPressed(button: UIButton) {
		self.delegate?.homeDidSelectSeeAllExhibitions()
	}
	
	@objc private func seeAllEventsButtonPressed(button: UIButton) {
		self.delegate?.homeDidSelectSeeAllEvents()
	}
}

// MARK: ScrollViewDelegate

extension HomeViewController : UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView == self.scrollView {
			self.scrollDelegate?.sectionViewControllerDidScroll(scrollView: scrollView)
		}
	}
}

// MARK: Collection Views

extension HomeViewController : UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == toursCollectionView {
			return tourItems.count
		}
		else if collectionView == exhibitionsCollectionView {
			return exhibitionItems.count
		}
		else if collectionView == eventsCollectionView {
			return eventItems.count
		}
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == toursCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTourCell.reuseIdentifier, for: indexPath) as! HomeTourCell
			cell.tourModel = tourItems[indexPath.row]
			return cell
		}
		else if collectionView == exhibitionsCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeExhibitionCell.reuseIdentifier, for: indexPath) as! HomeExhibitionCell
			cell.exhibitionModel = exhibitionItems[indexPath.row]
			return cell
		}
		else if collectionView == eventsCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEventCell.reuseIdentifier, for: indexPath) as! HomeEventCell
			cell.eventModel = eventItems[indexPath.row]
			return cell
		}
		return UICollectionViewCell()
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
}

extension HomeViewController : UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == toursCollectionView {
			self.delegate?.homeDidSelectTour(tour: tourItems[indexPath.row])
		}
		else if collectionView == exhibitionsCollectionView {
			self.delegate?.homeDidSelectExhibition(exhibition: exhibitionItems[indexPath.row])
		}
		else if collectionView == eventsCollectionView {
			self.delegate?.homeDidSelectEvent(event: eventItems[indexPath.row])
		}
	}
}
