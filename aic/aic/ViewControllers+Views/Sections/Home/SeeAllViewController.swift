//
//  SeeAllViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/30/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

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
		case exhibitions
		case events
	}
	let content: ContentType
	
	let titles = [ContentType.tours : "Tours", ContentType.exhibitions : "On View", ContentType.events : "Events"]
	
	var tourItems: [AICTourModel] = []
	var exhibitionItems: [AICExhibitionModel] = []
	var eventDates: [Date] = []
	var eventItems: [[AICEventModel]] = []
	
	weak var delegate: SeeAllViewControllerDelegate? = nil
	
	init(contentType: ContentType) {
		self.content = contentType
		collectionView = SeeAllViewController.createCollectionView(for: content)
		super.init(nibName: nil, bundle: nil)
		
		// Set the navigation item content
		self.navigationItem.title = titles[contentType]
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .white
		
		let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(recognizer:)))
		swipeRightGesture.direction = .right
		collectionView.addGestureRecognizer(swipeRightGesture)
		
		collectionView.panGestureRecognizer.require(toFail: swipeRightGesture)
		collectionView.register(UINib(nibName: "SeeAllTourCell", bundle: Bundle.main), forCellWithReuseIdentifier: SeeAllTourCell.reuseIdentifier)
		collectionView.register(UINib(nibName: "SeeAllEventCell", bundle: Bundle.main), forCellWithReuseIdentifier: SeeAllEventCell.reuseIdentifier)
		collectionView.register(UINib(nibName: "SeeAllExhibitionCell", bundle: Bundle.main), forCellWithReuseIdentifier: SeeAllExhibitionCell.reuseIdentifier)
		collectionView.delegate = self
		collectionView.dataSource = self
		
		self.view.addSubview(collectionView)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
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
		if content == .events || content == .tours {
			collectionView.register(SeeAllHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SeeAllHeaderView.reuseIdentifier)
		}
		return collectionView
	}
	
	override func updateViewConstraints() {
		collectionView.autoPinEdge(.top, to: .top, of: self.view, withOffset: Common.Layout.navigationBarMinimizedVerticalOffset)
		collectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		collectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		collectionView.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: -Common.Layout.tabBarHeight)
		
		super.updateViewConstraints()
	}
}

// Layout
extension SeeAllViewController : UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if content == .events {
			return eventItems.count
		}
		else if content == .tours {
			return 1 // TODO: replace with tour categories
		}
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if content == .tours {
			return tourItems.count
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
			cell.tourModel = AppDataManager.sharedInstance.app.tours[indexPath.row]
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
		
		if kind == UICollectionElementKindSectionHeader {
			if content == .events {
				let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SeeAllHeaderView.reuseIdentifier, for: indexPath) as! SeeAllHeaderView
				sectionHeader.titleLabel.text = Common.Info.monthDayString(date: eventDates[indexPath.section])
				return sectionHeader
			}
			else if content == .tours {
				let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SeeAllHeaderView.reuseIdentifier, for: indexPath) as! SeeAllHeaderView
				sectionHeader.titleLabel.text = "" // TODO: replace with tour categories
				return sectionHeader
			}
		}
		
		return UICollectionReusableView()
	}
}

// Interaction
extension SeeAllViewController : UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if content == .tours {
			self.delegate?.seeAllDidSelectTour(tour: tourItems[indexPath.row])
		}
		else if content == .exhibitions {
			self.delegate?.seeAllDidSelectExhibition(exhibition: exhibitionItems[indexPath.row])
		}
		else if content == .events {
			self.delegate?.seeAllDidSelectEvent(event: eventItems[indexPath.section][indexPath.row])
		}
	}
}

extension SeeAllViewController : UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		if content == .events || content == .tours {
			return CGSize(width: UIScreen.main.bounds.width, height: SeeAllHeaderView.headerHeight)
		}
		return CGSize.zero
	}
}

extension SeeAllViewController : UIGestureRecognizerDelegate {
	@objc private func swipeRight(recognizer: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
}

