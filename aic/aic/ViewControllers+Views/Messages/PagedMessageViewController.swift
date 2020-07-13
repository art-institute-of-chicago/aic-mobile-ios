//
//  PagedMessageViewController.swift
//  aic
//
//  Created by Christopher Luu on 5/21/20.
//  Copyright © 2020 Art Institute of Chicago. All rights reserved.
//

import UIKit

final class PagedMessageViewController: UIViewController {
	// MARK: - Properties -
	private let messages: [AICMessageModel]

	// MARK: - UI Properties -
	private let backgroundView = getBlurEffectView(frame: .zero)
	private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

	// MARK: - Initializers -
	init(messages: [AICMessageModel]) {
		self.messages = messages

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("This init method shouldn't ever be used")
	}

	// MARK: - Lifecycle -
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .clear

		collectionView.backgroundColor = .clear
		collectionView.register(
			PagedMessageCollectionViewCell.self,
			forCellWithReuseIdentifier: PagedMessageCollectionViewCell.reuseIdentifier
		)
		collectionView.isPagingEnabled = true
		collectionView.dataSource = self
		collectionView.showsHorizontalScrollIndicator = false

		if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.itemSize = collectionView.bounds.size
			layout.scrollDirection = .horizontal
			layout.minimumLineSpacing = 0
			layout.minimumInteritemSpacing = 0
		}

		view.addSubview(backgroundView)
		backgroundView.contentView.addSubview(collectionView)

		createViewConstraints()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.itemSize = view.bounds.size
		}
	}

	private func createViewConstraints() {
		backgroundView.autoPinEdgesToSuperviewEdges()

		collectionView.autoPinEdgesToSuperviewEdges()
	}
}

// MARK: - `UICollectionViewDataSource` -
extension PagedMessageViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
	}

	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: PagedMessageCollectionViewCell.reuseIdentifier,
				for: indexPath
			) as? PagedMessageCollectionViewCell
			else { fatalError("Could not dequeue PagedMessageCollectionViewCell") }
		cell.message = messages[indexPath.item]
		cell.isFirstPage = (indexPath.item == 0)
		cell.isLastPage = (indexPath.item == messages.count - 1)
		cell.delegate = self
		return cell
	}
}

// MARK: - `PagedMessageCollectionViewCellDelegate` -
extension PagedMessageViewController: PagedMessageCollectionViewCellDelegate {
	func pagedMessageCollectionViewCellDidSelectPreviousPage(_ cell: PagedMessageCollectionViewCell) {
		guard var indexPath = collectionView.indexPath(for: cell) else { return }
		indexPath.item -= 1
		collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
	}

	func pagedMessageCollectionViewCellDidSelectNextPage(_ cell: PagedMessageCollectionViewCell) {
		guard var indexPath = collectionView.indexPath(for: cell) else { return }
		indexPath.item += 1
		collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
	}

	func pagedMessageCollectionViewCell(_ cell: PagedMessageCollectionViewCell, didSelectAction action: URL) {
		UIApplication.shared.open(action, options: [:], completionHandler: nil)
	}

	func pagedMessageCollectionViewCellDidSelectClose(_ cell: PagedMessageCollectionViewCell) {
		AppDataManager.sharedInstance.markMessagesAsSeen(messages: messages)
		dismiss(animated: true, completion: nil)
	}
}
