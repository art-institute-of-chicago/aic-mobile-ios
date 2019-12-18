//
//  HomeViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/15/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol HomeViewControllerDelegate: class {
	func homeDidSelectAccessMemberCard()
	func homeDidSelectSeeAllTours()
	func homeDidSelectSeeAllExhibitions()
	func homeDidSelectSeeAllEvents()
	func homeDidSelectTour(tour: AICTourModel)
	func homeDidSelectExhibition(exhibition: AICExhibitionModel)
	func homeDidSelectEvent(event: AICEventModel)
}

class ClickThroughView: UIView {
	//	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
	//		for view in subviews {
	//			if view.point(inside: point, with: event) {
	//				return view
	//			}
	//		}
	//		return nil
	//	}
}

class HomeViewController: SectionViewController {
	let scrollView: UIScrollView = UIScrollView()
	let contentView: ClickThroughView = ClickThroughView()
	let homeIntroView: HomeIntroView = HomeIntroView()
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

	static let tourCellSize: CGSize = CGSize(width: 285, height: 306)
	static let eventCellSize: CGSize = CGSize(width: 285, height: 320)
	static let exhibitionCellSize: CGSize = CGSize(width: 240, height: 380)

	weak var delegate: HomeViewControllerDelegate?

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

		contentView.backgroundColor = .white

		homeIntroView.accessMemberCardButton.addTarget(self, action: #selector(accessMemberCardButtonPressed(button:)), for: .touchUpInside)

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

		if #available(iOS 11.0, *) {
			scrollView.contentInsetAdjustmentBehavior = .never
		} else {
			automaticallyAdjustsScrollViewInsets = false
		}

		contentView.addSubview(homeIntroView)
		contentView.addSubview(toursTitleView)
		contentView.addSubview(toursCollectionView)
		contentView.addSubview(exhibitionsDividerLine)
		contentView.addSubview(exhibitionsTitleView)
		contentView.addSubview(exhibitionsCollectionView)
		contentView.addSubview(eventsDividerLine)
		contentView.addSubview(eventsTitleView)
		contentView.addSubview(eventsCollectionView)
		scrollView.addSubview(contentView)
		self.view.addSubview(scrollView)

		createViewConstraints()

		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		tourItems = AppDataManager.sharedInstance.getToursForHome()
		exhibitionItems = AppDataManager.sharedInstance.getExhibitionsForHome()
		eventItems = AppDataManager.sharedInstance.getEventsForHome()

		self.view.layoutIfNeeded()
		self.scrollView.contentSize.width = self.view.frame.width
		self.scrollView.contentSize.height = eventsCollectionView.frame.origin.y + eventsCollectionView.frame.height + Common.Layout.miniAudioPlayerHeight

		updateLanguage()

		// Log analytics
		AICAnalytics.trackScreenView("Home", screenClass: "HomeViewController")
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
		scrollView.autoSetDimension(.height, toSize: UIScreen.main.bounds.height - Common.Layout.tabBarHeight)

		contentView.autoPinEdge(.top, to: .top, of: scrollView)
		contentView.autoPinEdge(.leading, to: .leading, of: self.view)
		contentView.autoPinEdge(.trailing, to: .trailing, of: self.view)

		homeIntroView.autoPinEdge(.top, to: .top, of: contentView, withOffset: Common.Layout.navigationBarHeight)
		homeIntroView.autoPinEdge(.leading, to: .leading, of: contentView)
		homeIntroView.autoPinEdge(.trailing, to: .trailing, of: contentView)

		toursTitleView.autoPinEdge(.top, to: .bottom, of: homeIntroView)
		toursTitleView.autoPinEdge(.leading, to: .leading, of: contentView)
		toursTitleView.autoPinEdge(.trailing, to: .trailing, of: contentView)
		toursTitleView.autoSetDimension(.height, toSize: 65)

		toursCollectionView.autoPinEdge(.top, to: .bottom, of: toursTitleView)
		toursCollectionView.autoPinEdge(.leading, to: .leading, of: contentView)
		toursCollectionView.autoPinEdge(.trailing, to: .trailing, of: contentView)
		toursCollectionView.autoSetDimension(.height, toSize: HomeViewController.tourCellSize.height)

		exhibitionsDividerLine.autoPinEdge(.top, to: .bottom, of: toursCollectionView, withOffset: 20)
		exhibitionsDividerLine.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
		exhibitionsDividerLine.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
		exhibitionsDividerLine.autoSetDimension(.height, toSize: 1)

		exhibitionsTitleView.autoPinEdge(.top, to: .bottom, of: exhibitionsDividerLine)
		exhibitionsTitleView.autoPinEdge(.leading, to: .leading, of: contentView)
		exhibitionsTitleView.autoPinEdge(.trailing, to: .trailing, of: contentView)
		exhibitionsTitleView.autoSetDimension(.height, toSize: 65)

		exhibitionsCollectionView.autoPinEdge(.top, to: .bottom, of: exhibitionsTitleView)
		exhibitionsCollectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		exhibitionsCollectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		exhibitionsCollectionView.autoSetDimension(.height, toSize: HomeViewController.exhibitionCellSize.height)

		eventsDividerLine.autoPinEdge(.top, to: .bottom, of: exhibitionsCollectionView, withOffset: 30)
		eventsDividerLine.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
		eventsDividerLine.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
		eventsDividerLine.autoSetDimension(.height, toSize: 1)

		eventsTitleView.autoPinEdge(.top, to: .bottom, of: eventsDividerLine)
		eventsTitleView.autoPinEdge(.leading, to: .leading, of: contentView)
		eventsTitleView.autoPinEdge(.trailing, to: .trailing, of: contentView)
		eventsTitleView.autoSetDimension(.height, toSize: 65)

		eventsCollectionView.autoPinEdge(.top, to: .bottom, of: eventsTitleView)
		eventsCollectionView.autoPinEdge(.leading, to: .leading, of: contentView)
		eventsCollectionView.autoPinEdge(.trailing, to: .trailing, of: contentView)
		eventsCollectionView.autoSetDimension(.height, toSize: HomeViewController.eventCellSize.height)

		contentView.autoPinEdge(.bottom, to: .bottom, of: eventsCollectionView, withOffset: Common.Layout.miniAudioPlayerHeight)
	}

	// MARK: Animation

	func animateToursScrolling() {
		UIView.animate(withDuration: 0.8, delay: 0.5, options: .curveEaseInOut, animations: {
			self.toursCollectionView.contentOffset = CGPoint(x: UIScreen.main.bounds.width/2.0, y: 0)
		}) { (completed) in
			if completed {
				UIView.animate(withDuration: 0.4, animations: {
					self.toursCollectionView.contentOffset = CGPoint(x: 0, y: 0)
				})
			}
		}
	}

	// MARK: Language

	@objc private func updateLanguage() {
		let homeMemberPromptText: String = AppDataManager.sharedInstance.app.generalInfo.homeMemberPrompt
		homeIntroView.promptTextView.text = homeMemberPromptText

		homeIntroView.accessMemberCardButton.setTitle("Member Card Button Title".localized(using: "Home"), for: .normal)

		toursTitleView.contentTitleLabel.text = "Tours".localized(using: "Sections")
		toursTitleView.seeAllButton.setTitle("See All".localized(using: "Sections"), for: .normal)

		exhibitionsTitleView.contentTitleLabel.text = "On View".localized(using: "Sections")
		exhibitionsTitleView.seeAllButton.setTitle("See All".localized(using: "Sections"), for: .normal)

		eventsTitleView.contentTitleLabel.text = "Events".localized(using: "Sections")
		eventsTitleView.seeAllButton.setTitle("See All".localized(using: "Sections"), for: .normal)

		toursCollectionView.reloadData()
		exhibitionsCollectionView.reloadData()
		eventsCollectionView.reloadData()
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

extension HomeViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView == self.scrollView {
			self.scrollDelegate?.sectionViewControllerDidScroll(scrollView: scrollView)
		}
	}
}

// MARK: Collection Views

extension HomeViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == toursCollectionView {
			return tourItems.count
		} else if collectionView == exhibitionsCollectionView {
			return exhibitionItems.count
		} else if collectionView == eventsCollectionView {
			return eventItems.count
		}
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == toursCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTourCell.reuseIdentifier, for: indexPath) as! HomeTourCell
			cell.tourModel = tourItems[indexPath.row]
			return cell
		} else if collectionView == exhibitionsCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeExhibitionCell.reuseIdentifier, for: indexPath) as! HomeExhibitionCell
			cell.exhibitionModel = exhibitionItems[indexPath.row]
			return cell
		} else if collectionView == eventsCollectionView {
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

extension HomeViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == toursCollectionView {
			self.delegate?.homeDidSelectTour(tour: tourItems[indexPath.row])
		} else if collectionView == exhibitionsCollectionView {
			self.delegate?.homeDidSelectExhibition(exhibition: exhibitionItems[indexPath.row])
		} else if collectionView == eventsCollectionView {
			self.delegate?.homeDidSelectEvent(event: eventItems[indexPath.row])
		}
	}
}
