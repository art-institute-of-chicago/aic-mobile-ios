//
//  HomeViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/15/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol HomeViewControllerDelegate : class {
	func showSeeAllTours()
	func showSeeAllExhibitions()
	func showSeeAllEvents()
}

class HomeViewController : SectionViewController {
	let scrollView: UIScrollView = UIScrollView()
	let memberPromptView: HomeMemberPromptView = HomeMemberPromptView()
	let toursTitleView: HomeContentTitleView = HomeContentTitleView(title: "Tours")
	let toursCollectionView: UICollectionView = createToursEventsCollectionView()
	let exhibitionsDividerLine: UIView = createDividerLine()
	let exhibitionsTitleView: HomeContentTitleView = HomeContentTitleView(title: "On View")
	let exhibitionsCollectionView: UICollectionView = createExhibitionsCollectionView()
	let eventsDividerLine: UIView = createDividerLine()
	let eventsTitleView: HomeContentTitleView = HomeContentTitleView(title: "Events")
	let eventsCollectionView: UICollectionView = createToursEventsCollectionView()
	
	var tourItems: [AICTourModel] = []
	var exhibitionItems: [AICExhibitionModel] = []
	var eventItems: [AICEventModel] = []
	
	let bottomMargin: CGFloat = 60
	static let toursAndEventsCollectionHeight: CGFloat = 340
	static let exhibitionsCollectionHeight: CGFloat = 380
	
	weak var delegate: HomeViewControllerDelegate? = nil
	
	override init(section: AICSectionModel) {
		super.init(section: section)
		
		// TODO: set max number of items in Common / Settings
		for tour in AppDataManager.sharedInstance.app.tours {
			tourItems.append(tour)
			if tourItems.count == 6 {
				break
			}
		}
		
		for exhibition in AppDataManager.sharedInstance.exhibitions {
			exhibitionItems.append(exhibition)
			if exhibitionItems.count == 6 {
				break
			}
		}
		
		let earliestDayEvents = AppDataManager.sharedInstance.getEventsForEarliestDay()
		for event in earliestDayEvents {
			let now = Date()
			if event.startDate > now {
				eventItems.append(event)
			}
			if eventItems.count == 6 {
				break
			}
		}
		
		if eventItems.isEmpty {
			if let lastEventOfEarliestDay = earliestDayEvents.last {
				eventItems.append(lastEventOfEarliestDay)
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrollView.delegate = self
		
		toursCollectionView.register(UINib(nibName: "HomeTourCell", bundle: Bundle.main), forCellWithReuseIdentifier: HomeTourCell.reuseIdentifier)
		toursCollectionView.dataSource = self
		toursTitleView.seeAllButton.addTarget(self, action: #selector(seeAllToursButtonPressed(button:)), for: .touchUpInside)
		
		exhibitionsCollectionView.register(UINib(nibName: "HomeExhibitionCell", bundle: Bundle.main), forCellWithReuseIdentifier: HomeExhibitionCell.reuseIdentifier)
		exhibitionsCollectionView.dataSource = self
		exhibitionsTitleView.seeAllButton.addTarget(self, action: #selector(seeAllExhibitionsButtonPressed(button:)), for: .touchUpInside)
		
		eventsCollectionView.register(UINib(nibName: "HomeEventCell", bundle: Bundle.main), forCellWithReuseIdentifier: HomeEventCell.reuseIdentifier)
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
		
		self.updateViewConstraints()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.view.layoutIfNeeded()
		self.scrollView.contentSize.width = self.view.frame.width
		self.scrollView.contentSize.height = eventsCollectionView.frame.origin.y + eventsCollectionView.frame.height + bottomMargin
		
		self.scrollDelegate?.sectionViewControllerWillAppearWithScrollView(scrollView: scrollView)
	}
	
	private static func createToursEventsCollectionView() -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 285, height: HomeViewController.toursAndEventsCollectionHeight)
		layout.minimumLineSpacing = 20
		layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // TODO: change 74 to calculation based on screen width
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.backgroundColor = .white
		return collectionView
	}
	
	private static func createExhibitionsCollectionView() -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 240, height: HomeViewController.exhibitionsCollectionHeight)
		layout.minimumLineSpacing = 20
		layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // TODO: change 119 to calculation based on screen width
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
	
	override func updateViewConstraints() {
		scrollView.autoPinEdge(.top, to: .top, of: self.view)
		scrollView.autoPinEdge(.leading, to: .leading, of: self.view)
		scrollView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		scrollView.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: -Common.Layout.tabBarHeightWithMiniAudioPlayerHeight)
		
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
		toursCollectionView.autoSetDimension(.height, toSize: HomeViewController.toursAndEventsCollectionHeight)
		
		exhibitionsDividerLine.autoPinEdge(.top, to: .bottom, of: toursCollectionView, withOffset: 30)
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
		exhibitionsCollectionView.autoSetDimension(.height, toSize: HomeViewController.exhibitionsCollectionHeight)
		
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
		eventsCollectionView.autoSetDimension(.height, toSize: HomeViewController.toursAndEventsCollectionHeight)
		
		super.updateViewConstraints()
	}
	
	@objc private func seeAllToursButtonPressed(button: UIButton) {
		self.delegate?.showSeeAllTours()
	}
	
	@objc private func seeAllExhibitionsButtonPressed(button: UIButton) {
		self.delegate?.showSeeAllExhibitions()
	}
	
	@objc private func seeAllEventsButtonPressed(button: UIButton) {
		self.delegate?.showSeeAllEvents()
	}
}

extension HomeViewController : UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView == self.scrollView {
			self.scrollDelegate?.sectionViewControllerDidScroll(scrollView: scrollView)
		}
	}
}

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
