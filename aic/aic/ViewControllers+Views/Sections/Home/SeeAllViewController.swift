//
//  SeeAllViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/30/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol SeeAllViewControllerDelegate : class {
	func seeAllDidSelectTour(tour: AICTourModel)
	func seeAllDidSelectExhibition(exhibition: AICExhibitionModel)
	func seeAllDidSelectEvent(event: AICEventModel)
}

// TODO: change this to a collectionviewcontroller or subclass SectionViewController if needed for language inheritance
class SeeAllViewController : UIViewController {
	let collectionView: UICollectionView
	
	enum ContentType {
		case tours
		case toursByCategory
		case exhibitions
		case events
	}
	let content: ContentType
	
	let titles = [ContentType.tours : "Tours",
				  ContentType.toursByCategory : "Tours",
				  ContentType.exhibitions : "On View",
				  ContentType.events : "Events"]
	
	private var tourItems: [AICTourModel] = []
	private var tourCategories: [AICTourCategoryModel] = []
	private var tourItemsByCategory: [[AICTourModel]] = []
	private var exhibitionItems: [AICExhibitionModel] = []
	private var eventDates: [Date] = []
	private var eventItems: [[AICEventModel]] = []
	
	weak var delegate: SeeAllViewControllerDelegate? = nil
	
	let seeAllToursIntroText: String
	
	init(contentType: ContentType) {
		content = contentType
		collectionView = SeeAllViewController.createCollectionView(for: content)
		
		// Data
		if content == .tours {
			tourItems = AppDataManager.sharedInstance.getToursForSeeAll()
		}
		else if content == .toursByCategory {
			let categoryTours = AppDataManager.sharedInstance.getToursByCategoryForSeeAll()
			for item in categoryTours {
				tourCategories.append(item.key)
				tourItemsByCategory.append(item.value)
			}
		}
		else if content == .exhibitions {
			exhibitionItems = AppDataManager.sharedInstance.getExhibitionsForSeeAll()
		}
		
		seeAllToursIntroText = AppDataManager.sharedInstance.app.generalInfo.seeAllToursIntro
		
		super.init(nibName: nil, bundle: nil)
		
		// Set the navigation item content
		self.navigationItem.title = titles[contentType]
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.automaticallyAdjustsScrollViewInsets = false
		self.view.backgroundColor = .white
		
		let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(recognizer:)))
		swipeRightGesture.direction = .right
		collectionView.addGestureRecognizer(swipeRightGesture)
		
		collectionView.panGestureRecognizer.require(toFail: swipeRightGesture)
		collectionView.register(UINib(nibName: "SeeAllTourCell", bundle: Bundle.main), forCellWithReuseIdentifier: SeeAllTourCell.reuseIdentifier)
		collectionView.register(UINib(nibName: "SeeAllEventCell", bundle: Bundle.main), forCellWithReuseIdentifier: SeeAllEventCell.reuseIdentifier)
		collectionView.register(UINib(nibName: "SeeAllExhibitionCell", bundle: Bundle.main), forCellWithReuseIdentifier: SeeAllExhibitionCell.reuseIdentifier)
		collectionView.register(SeeAllHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeeAllHeaderView.reuseIdentifier)
		collectionView.register(SeeAllIntroView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeeAllIntroView.reuseIdentifier)
		collectionView.delegate = self
		collectionView.dataSource = self
		
		self.view.addSubview(collectionView)
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if self.content == .events {
			eventDates.removeAll()
			eventItems.removeAll()
			for event in AppDataManager.sharedInstance.events {
				var foundDate: Bool = false
				for index in 0..<eventDates.count {
					if Calendar.current.compare(eventDates[index], to: event.startDate, toGranularity: .day) == .orderedSame {
						foundDate = true
						eventItems[index].append(event)
					}
				}
				if foundDate == false {
					eventDates.append(event.startDate)
					eventItems.append([event])
				}
			}
		}
		
		// Log analytics
		AICAnalytics.trackScreenView(titles[self.content]!, screenClass: "SeeAllViewController")
	}
	
	private static func createCollectionView(for content: ContentType) -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		
		if content == .exhibitions {
			let sideMargin: CGFloat = 16
			let itemWidth: CGFloat = CGFloat(UIScreen.main.bounds.width - (sideMargin * 2.0))
			
			layout.itemSize = CGSize(width: itemWidth, height: 361)
			layout.sectionInset = UIEdgeInsets(top: 16, left: sideMargin, bottom: 60, right: sideMargin)
		}
		else {
			let sideMargin: CGFloat = 15
			let middleMargin: CGFloat = 7
			let itemWidth: CGFloat = CGFloat(UIScreen.main.bounds.width - (sideMargin * 2.0) - middleMargin) / 2.0
			
			layout.itemSize = CGSize(width: itemWidth, height: 285)
			layout.sectionInset = UIEdgeInsets(top: 0, left: sideMargin, bottom: 0, right: sideMargin)
		}
		
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		layout.scrollDirection = .vertical
		
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Common.Layout.miniAudioPlayerHeight, right: 0)
		collectionView.showsVerticalScrollIndicator = false
		collectionView.backgroundColor = .white
		return collectionView
	}
	
	override func updateViewConstraints() {
		collectionView.autoPinEdge(.top, to: .top, of: self.view, withOffset: Common.Layout.navigationBarMinimizedHeight)
		collectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		collectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		collectionView.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: -Common.Layout.tabBarHeight)
		
		super.updateViewConstraints()
	}
	
	@objc private func updateLanguage() {
		collectionView.reloadData()
	}
}

// Layout
extension SeeAllViewController : UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if content == .tours {
			return 2
		}
		else if content == .toursByCategory {
			return tourCategories.count + 1
		}
		else if content == .events {
			return eventItems.count
		}
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if content == .tours {
			if section == 0 {
				return 0
			}
			return tourItems.count
		}
		else if content == .toursByCategory {
			if section == 0 {
				return 0
			}
			let toursSectionIndex = section-1 // first section is the intro text
			return tourItemsByCategory[toursSectionIndex].count
		}
		else if content == .exhibitions {
			return exhibitionItems.count
		}
		else if content == .events {
			return eventItems[section].count
		}
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if content == .tours {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllTourCell.reuseIdentifier, for: indexPath) as! SeeAllTourCell
			cell.tourModel = tourItems[indexPath.row]
			return cell
		}
		else if content == .toursByCategory {
			let toursSectionIndex = indexPath.section-1 // first section is the intro text
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllTourCell.reuseIdentifier, for: indexPath) as! SeeAllTourCell
			cell.tourModel = tourItemsByCategory[toursSectionIndex][indexPath.row]
			return cell
		}
		else if content == .exhibitions {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllExhibitionCell.reuseIdentifier, for: indexPath) as! SeeAllExhibitionCell
			cell.exhibitionModel = AppDataManager.sharedInstance.exhibitions[indexPath.row]
			return cell
		}
		else if content == .events {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllEventCell.reuseIdentifier, for: indexPath) as! SeeAllEventCell
			cell.eventModel = eventItems[indexPath.section][indexPath.row]
			return cell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		if kind == UICollectionView.elementKindSectionHeader {
			if content == .events {
				let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeeAllHeaderView.reuseIdentifier, for: indexPath) as! SeeAllHeaderView
				sectionHeader.titleLabel.text = Common.Info.monthDayString(date: eventDates[indexPath.section])
				return sectionHeader
			}
			else if content == .tours {
				if indexPath.section == 0 {
					let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeeAllIntroView.reuseIdentifier, for: indexPath) as! SeeAllIntroView
					sectionHeader.setText(text: seeAllToursIntroText)
					return sectionHeader
				}
				
				let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeeAllHeaderView.reuseIdentifier, for: indexPath) as! SeeAllHeaderView
				sectionHeader.titleLabel.text = ""
				return sectionHeader
			}
			else if content == .toursByCategory {
				if indexPath.section == 0 {
					let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeeAllIntroView.reuseIdentifier, for: indexPath) as! SeeAllIntroView
					sectionHeader.setText(text: seeAllToursIntroText)
					return sectionHeader
				}
				
				let toursSectionIndex = indexPath.section-1 // first section is the intro text
				let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeeAllHeaderView.reuseIdentifier, for: indexPath) as! SeeAllHeaderView
				sectionHeader.titleLabel.text = tourCategories[toursSectionIndex].title[Common.currentLanguage]
				return sectionHeader
			}
		}
		
		return UICollectionReusableView()
	}
}

extension SeeAllViewController : UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		if content == .events {
			return CGSize(width: UIScreen.main.bounds.width, height: SeeAllHeaderView.headerHeight)
		}
		else if content == .tours || content == .toursByCategory {
			if section == 0 {
				return SeeAllIntroView.sizeForText(text: seeAllToursIntroText)
			}
			else if content == .tours {
				return CGSize(width: UIScreen.main.bounds.width, height: 16.0)
			}
			return CGSize(width: UIScreen.main.bounds.width, height: SeeAllHeaderView.headerHeight)
		}
		return CGSize.zero
	}
}

// Interaction
extension SeeAllViewController : UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if content == .tours {
			self.delegate?.seeAllDidSelectTour(tour: tourItems[indexPath.row])
		}
		else if content == .toursByCategory {
			let toursSectionIndex = indexPath.section-1 // first section is the intro text
			self.delegate?.seeAllDidSelectTour(tour: tourItemsByCategory[toursSectionIndex][indexPath.row])
		}
		else if content == .exhibitions {
			self.delegate?.seeAllDidSelectExhibition(exhibition: exhibitionItems[indexPath.row])
		}
		else if content == .events {
			self.delegate?.seeAllDidSelectEvent(event: eventItems[indexPath.section][indexPath.row])
		}
	}
}

extension SeeAllViewController : UIGestureRecognizerDelegate {
	@objc private func swipeRight(recognizer: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
}

