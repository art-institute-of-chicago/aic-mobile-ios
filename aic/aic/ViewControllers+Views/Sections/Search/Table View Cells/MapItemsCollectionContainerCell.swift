//
//  MapItemsCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/10/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol MapItemsCollectionContainerDelegate: class {
	func mapItemDiningSelected()
	func mapItemGiftShopSelected()
	func mapItemRestroomSelected()
	func mapItemObjectSelected(object: AICObjectModel)
}

/// Cell of ResultsTableViewController to show suggested search text
/// Example: 'On the map' section
class MapItemsCollectionContainerCell : UITableViewCell {
	static let reuseIdentifier = "mapItemsCollectionContainerCell"
	
	static let cellHeight: CGFloat = 160.0
	
	var objectModels: [AICObjectModel] = [] {
		didSet {
			innerCollectionView.reloadData()
		}
	}
	@IBOutlet var innerCollectionView:UICollectionView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		layoutMargins = UIEdgeInsets.zero
		
		self.backgroundColor = .aicDarkGrayColor
		
		self.innerCollectionView.backgroundColor = .aicDarkGrayColor
		self.innerCollectionView.contentInset = UIEdgeInsetsMake(0, 16, 0, 16)
		self.innerCollectionView.dataSource = self
		self.innerCollectionView.delegate = self
		self.innerCollectionView.register(UINib.init(nibName: "MapItemCell", bundle: Bundle.main), forCellWithReuseIdentifier: MapItemCell.reuseIdentifier)
		
		self.clipsToBounds = false
		
		self.innerCollectionView.reloadData()
	}
}

extension MapItemsCollectionContainerCell : UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
		return true
	}
}

extension MapItemsCollectionContainerCell : UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if section == 0 {
			return 5
		}
		else {
			return min(objectModels.count, 5)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapItemCell.reuseIdentifier, for: indexPath) as! MapItemCell
		return cell
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}
}
