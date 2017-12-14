//
//  SeeAllViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/30/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SeeAllViewController : UIViewController {
	let collectionView: UICollectionView
	
	enum ContentType {
		case tours
		case exhibitions
		case events
	}
	let content: ContentType
	
	let titles = [ContentType.tours:"Tours", ContentType.exhibitions:"On View", ContentType.events:"Events"]
	
	var tourItems: [AICTourModel] = []
	var exhibitionItems: [AICExhibitionModel] = []
	var eventItems: [AICEventModel] = []
	
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
		collectionView.dataSource = self
		
		self.view.addSubview(collectionView)
	}
	
	private static func createCollectionView(for content: ContentType) -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		
		if content == .exhibitions {
			let sideMargin: CGFloat = 16
			let itemWidth: CGFloat = CGFloat(UIScreen.main.bounds.width - (sideMargin * 2.0))
			
			layout.itemSize = CGSize(width: itemWidth, height: 361)
			layout.sectionInset = UIEdgeInsets(top: 48, left: sideMargin, bottom: 60, right: sideMargin)
		}
		else {
			let sideMargin: CGFloat = 15
			let middleMargin: CGFloat = 7
			let itemWidth: CGFloat = CGFloat(UIScreen.main.bounds.width - (sideMargin * 2.0) - middleMargin) / 2.0
			
			layout.itemSize = CGSize(width: itemWidth, height: 285)
			layout.sectionInset = UIEdgeInsets(top: 48, left: sideMargin, bottom: 60, right: sideMargin)
		}
		
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		layout.scrollDirection = .vertical
		
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.showsVerticalScrollIndicator = false
		collectionView.backgroundColor = .white
		return collectionView
	}
	
	override func updateViewConstraints() {
		collectionView.autoPinEdge(.top, to: .top, of: self.view, withOffset: Common.Layout.navigationBarMinimizedVerticalOffset)
		collectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		collectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		collectionView.autoPinEdge(.bottom, to: .bottom, of: self.view)
		
		super.updateViewConstraints()
	}
}

extension SeeAllViewController : UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if content == .tours {
			return tourItems.count
		}
		else if content == .exhibitions {
			return exhibitionItems.count
		}
		else if content == .events {
			return eventItems.count
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
			cell.eventModel = AppDataManager.sharedInstance.events[indexPath.row]
			return cell
		}
		return UICollectionViewCell()
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
}

extension SeeAllViewController : UIGestureRecognizerDelegate {
	@objc private func swipeRight(recognizer: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
}

