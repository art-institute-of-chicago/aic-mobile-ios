//
//  MapItemsCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/10/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol MapItemsCollectionContainerDelegate: AnyObject {
	func mapItemDiningSelected()
	func mapItemMemberLoungeSelected()
	func mapItemGiftShopSelected()
	func mapItemRestroomSelected()
	func mapItemArtworkSelected(artwork: AICObjectModel)
}

/// Cell of ResultsTableViewController to show suggested search text
/// Example: 'On the map' section
class MapItemsCollectionContainerCell: UITableViewCell {
	static let reuseIdentifier = "mapItemsCollectionContainerCell"

	@IBOutlet var innerCollectionView: UICollectionView!

	weak var delegate: MapItemsCollectionContainerDelegate?

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

		selectionStyle = .none
		layoutMargins = UIEdgeInsets.zero

		self.backgroundColor = .aicDarkGrayColor

		self.innerCollectionView.backgroundColor = .aicDarkGrayColor
		self.innerCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		self.innerCollectionView.dataSource = self
		self.innerCollectionView.delegate = self
		self.innerCollectionView.register(UINib.init(nibName: "MapItemCell", bundle: Bundle.main), forCellWithReuseIdentifier: MapItemCell.reuseIdentifier)

		self.clipsToBounds = false

		self.innerCollectionView.reloadData()

		// Accessibility
		self.accessibilityLabel = "Search locations on the map"
	}
}

extension MapItemsCollectionContainerCell: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return true
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			if indexPath.row == 0 {
				self.delegate?.mapItemDiningSelected()
			} else if indexPath.row == 1 {
				self.delegate?.mapItemMemberLoungeSelected()
			} else if indexPath.row == 2 {
				self.delegate?.mapItemGiftShopSelected()
			} else if indexPath.row == 3 {
				self.delegate?.mapItemRestroomSelected()
			}
		} else {
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

extension MapItemsCollectionContainerCell: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return MapItemsCollectionContainerCell.totalSections
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if section == 0 {
			return 4
		} else {
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
			if indexPath.row == 0 {
				cell.setItemIcon(image: #imageLiteral(resourceName: "searchRestaurantButton"), highlightImage: #imageLiteral(resourceName: "searchRestaurantButtonDown"))

				// Accessibility
				cell.accessibilityValue = "dining locations"
			}
			if indexPath.row == 1 {
				cell.setItemIcon(image: #imageLiteral(resourceName: "searchMembersButton"), highlightImage: #imageLiteral(resourceName: "searchMembersButtonDown"))

				// Accessibility
				cell.accessibilityValue = "member lounge"
			}
			if indexPath.row == 2 {
				cell.setItemIcon(image: #imageLiteral(resourceName: "searchGiftshopButton"), highlightImage: #imageLiteral(resourceName: "searchGiftshopButtonDown"))

				// Accessibility
				cell.accessibilityValue = "gift shops"
			}
			if indexPath.row == 3 {
				cell.setItemIcon(image: #imageLiteral(resourceName: "searchRestroomButton"), highlightImage: #imageLiteral(resourceName: "searchRestroomButtonDown"))

				// Accessibility
				cell.accessibilityValue = "restrooms"
			}
		} else {
			let index = (indexPath.section-1) * 5 + indexPath.row
			if index < MapItemsCollectionContainerCell.artworkModels.count {
				cell.artworkModel = MapItemsCollectionContainerCell.artworkModels[index]

				// Accessibility
				cell.accessibilityValue = cell.artworkModel!.title
			}
		}
		return cell
	}
}
