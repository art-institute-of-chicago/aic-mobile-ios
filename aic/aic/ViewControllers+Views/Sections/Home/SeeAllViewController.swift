//
//  SeeAllViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/30/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SeeAllViewController : UIViewController {
	let collectionView: UICollectionView = createCollectionView()
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		// Set the navigation item content
		self.navigationItem.title = "Tours"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.register(UINib(nibName: "SeeAllTourCell", bundle: Bundle.main), forCellWithReuseIdentifier: SeeAllTourCell.reuseIdentifier)
		collectionView.dataSource = self
		
		self.view.addSubview(collectionView)
	}
	
	private static func createCollectionView() -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 168, height: 257)
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		layout.sectionInset = UIEdgeInsets(top: 65, left: 0, bottom: 0, right: 0)
		layout.scrollDirection = .vertical
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.showsVerticalScrollIndicator = false
		collectionView.backgroundColor = .white
		return collectionView
	}
	
	var contentItems: [AICTourModel]? {
		didSet {
			collectionView.reloadData()
		}
	}
	
	override func updateViewConstraints() {
		collectionView.autoPinEdge(.top, to: .top, of: self.view, withOffset: Common.Layout.navigationBarMinimizedVerticalOffset)
		collectionView.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 15)
		collectionView.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -15)
		collectionView.autoPinEdge(.bottom, to: .bottom, of: self.view)
		
		super.updateViewConstraints()
	}
}

extension SeeAllViewController : UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let _: [AICTourModel] = contentItems else {
			return 0
		}
		return contentItems!.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllTourCell.reuseIdentifier, for: indexPath) as! SeeAllTourCell
		cell.tourModel = AppDataManager.sharedInstance.app.tours[indexPath.row]
		return cell
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
}

