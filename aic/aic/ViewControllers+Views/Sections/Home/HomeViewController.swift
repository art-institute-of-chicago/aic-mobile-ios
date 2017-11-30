//
//  HomeViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/15/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol HomeViewControllerDelegate : class {
	func buttonPressed()
}

class HomeViewController : SectionViewController {
	let scrollView: UIScrollView = UIScrollView()
	let memberPromptView: HomeMemberPromptView = HomeMemberPromptView()
	let toursCollectionView: UICollectionView = createToursCollectionView()
	let exhibitionsCollectionView: UICollectionView = createExhibitionsCollectionView()
	let eventsCollectionView: UICollectionView = createToursCollectionView()
	
	weak var delegate: HomeViewControllerDelegate? = nil
	
	override init(section: AICSectionModel) {
		super.init(section: section)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrollView.delegate = self
		
		toursCollectionView.register(UINib(nibName: "HomeTourCell", bundle: Bundle.main), forCellWithReuseIdentifier: HomeTourCell.reuseIdentifier)
		toursCollectionView.dataSource = self
		toursCollectionView.backgroundColor = .white
		
		exhibitionsCollectionView.register(UINib(nibName: "HomeExhibitionCell", bundle: Bundle.main), forCellWithReuseIdentifier: HomeExhibitionCell.reuseIdentifier)
		exhibitionsCollectionView.dataSource = self
		exhibitionsCollectionView.backgroundColor = .white
		
		eventsCollectionView.register(UINib(nibName: "HomeEventCell", bundle: Bundle.main), forCellWithReuseIdentifier: HomeEventCell.reuseIdentifier)
		eventsCollectionView.dataSource = self
		eventsCollectionView.backgroundColor = .white
		
		self.view.addSubview(scrollView)
		scrollView.addSubview(memberPromptView)
		scrollView.addSubview(toursCollectionView)
		scrollView.addSubview(exhibitionsCollectionView)
		scrollView.addSubview(eventsCollectionView)
		
		self.updateViewConstraints()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.view.layoutIfNeeded()
		self.scrollView.contentSize.width = self.view.frame.width
		self.scrollView.contentSize.height = eventsCollectionView.frame.origin.y + eventsCollectionView.frame.height
		
		self.scrollDelegate?.sectionViewControllerWillAppearWithScrollView(scrollView: scrollView)
	}
	
	static func createToursCollectionView() -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 285, height: 300)
		layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: 300), collectionViewLayout: layout)
		collectionView.showsHorizontalScrollIndicator = false
		return collectionView
	}
	
	static func createExhibitionsCollectionView() -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 240, height: 373)
		layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: 373), collectionViewLayout: layout)
		collectionView.showsHorizontalScrollIndicator = false
		return collectionView
	}
	
	override func updateViewConstraints() {
		scrollView.autoPinEdge(.top, to: .top, of: self.view)
		scrollView.autoPinEdge(.leading, to: .leading, of: self.view)
		scrollView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		scrollView.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: -Common.Layout.tabBarHeightWithMiniAudioPlayerHeight)
		
		memberPromptView.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 240.0 - 44)
		memberPromptView.autoPinEdge(.leading, to: .leading, of: self.view)
		memberPromptView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		toursCollectionView.autoPinEdge(.top, to: .bottom, of: memberPromptView, withOffset: 50)
		toursCollectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		toursCollectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		toursCollectionView.autoSetDimension(.height, toSize: 300)
		
		exhibitionsCollectionView.autoPinEdge(.top, to: .bottom, of: toursCollectionView)
		exhibitionsCollectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		exhibitionsCollectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		exhibitionsCollectionView.autoSetDimension(.height, toSize: 373)
		
		eventsCollectionView.autoPinEdge(.top, to: .bottom, of: exhibitionsCollectionView)
		eventsCollectionView.autoPinEdge(.leading, to: .leading, of: self.view)
		eventsCollectionView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		eventsCollectionView.autoSetDimension(.height, toSize: 300)
		
		super.updateViewConstraints()
	}
}

extension HomeViewController : UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.scrollDelegate?.sectionViewControllerDidScroll(scrollView: scrollView)
	}
}

extension HomeViewController : UICollectionViewDelegate {
//	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//		if kind == UICollectionElementKindSectionHeader {
//			let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HCollectionReusableView", for: indexPath) as! HomeSectionHeaderView
//
//			reusableview.frame = CGRect(0 , 0, self.view.frame.width, 60)
//			//do other header related calls or settups
//			return reusableview
//		}
//	}
}

extension HomeViewController : UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == toursCollectionView {
			return AppDataManager.sharedInstance.app.tours.count
		}
		else if collectionView == exhibitionsCollectionView {
			return AppDataManager.sharedInstance.app.tours.count
		}
		else if collectionView == eventsCollectionView {
			return AppDataManager.sharedInstance.app.tours.count
		}
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == toursCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTourCell.reuseIdentifier, for: indexPath) as! HomeTourCell
			cell.tourModel = AppDataManager.sharedInstance.app.tours[indexPath.row]
			return cell
		}
		else if collectionView == exhibitionsCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeExhibitionCell.reuseIdentifier, for: indexPath) as! HomeExhibitionCell
			cell.exhibitionModel = AppDataManager.sharedInstance.app.tours[indexPath.row]
			return cell
		}
		else if collectionView == eventsCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEventCell.reuseIdentifier, for: indexPath) as! HomeEventCell
			cell.eventModel = AppDataManager.sharedInstance.app.tours[indexPath.row]
			return cell
		}
		return UICollectionViewCell()
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForHeaderInSection section: Int) -> UIView {
		return UIView()
	}
}

