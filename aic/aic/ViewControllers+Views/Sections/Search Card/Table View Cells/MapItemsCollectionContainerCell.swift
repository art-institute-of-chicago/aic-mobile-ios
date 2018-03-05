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
	func mapItemArtworkSelected(artwork: AICObjectModel)
}

/// Cell of ResultsTableViewController to show suggested search text
/// Example: 'On the map' section
class MapItemsCollectionContainerCell : UITableViewCell {
	static let reuseIdentifier = "mapItemsCollectionContainerCell"
	
	@IBOutlet var innerCollectionView: UICollectionView!
	
	weak var delegate: MapItemsCollectionContainerDelegate? = nil
	
	static let sectionInset: CGFloat = 24.0
	
	static var cellHeight: CGFloat {
		let sectionsNumber = CGFloat(MapItemsCollectionContainerCell.totalSections)
		return sectionsNumber * MapItemCell.cellHeight + (sectionsNumber-1) * MapItemsCollectionContainerCell.sectionInset + 15
	}
	
	static var artworkModels: [AICObjectModel] {
		return AppDataManager.sharedInstance.app.searchArtworks
	}
	
	static var totalSections: Int {
		return 1 + Int(ceil(Float(MapItemsCollectionContainerCell.artworkModels.count) / 5.0))
	}
	
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
		if indexPath.section == 0 {
			if indexPath.row == 0 {
				self.delegate?.mapItemDiningSelected()
			}
			else if indexPath.row == 1 {
				self.delegate?.mapItemGiftShopSelected()
			}
			else if indexPath.row == 2 {
				self.delegate?.mapItemRestroomSelected()
			}
		}
		else {
			let index = (indexPath.section-1) * 5 + indexPath.row
			if index < MapItemsCollectionContainerCell.artworkModels.count {
				self.delegate?.mapItemArtworkSelected(artwork: MapItemsCollectionContainerCell.artworkModels[index])
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
		return true
	}
}

extension MapItemsCollectionContainerCell : UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return MapItemsCollectionContainerCell.totalSections
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if section == 0 {
			return 3
		}
		else {
			let lastItemIndex = section * 5 - 1
			if lastItemIndex < MapItemsCollectionContainerCell.artworkModels.count {
				return 5
			}
			return (MapItemsCollectionContainerCell.artworkModels.count % 5)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapItemCell.reuseIdentifier, for: indexPath) as! MapItemCell
		if indexPath.section == 0 {
			if indexPath.row == 0 { cell.setItemIcon(image: #imageLiteral(resourceName: "searchRestaurantIcon")) }
			if indexPath.row == 1 { cell.setItemIcon(image: #imageLiteral(resourceName: "searchShopIcon")) }
			if indexPath.row == 2 { cell.setItemIcon(image: #imageLiteral(resourceName: "searchRestroomIcon")) }
		}
		else {
			let index = (indexPath.section-1) * 5 + indexPath.row
			if index < MapItemsCollectionContainerCell.artworkModels.count {
				cell.artworkModel = MapItemsCollectionContainerCell.artworkModels[index]
			}
		}
		return cell
	}
}
