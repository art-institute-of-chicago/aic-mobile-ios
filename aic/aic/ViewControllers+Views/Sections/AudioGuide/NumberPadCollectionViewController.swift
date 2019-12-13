//
//  NumberPadViewControllerCollectionViewController.swift
//  aic
//
//  Created by Stephen Varga on 3/27/16.
//  Copyright © 2016 Potion Design. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class NumberPadCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    let buttonSize = 75
    let numCols = 3
    let numRows = 4

    var collectionView: UICollectionView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: buttonSize, height: buttonSize)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CGFloat(buttonSize * numCols), height: CGFloat(buttonSize * numRows)), collectionViewLayout: layout)

        collectionView.delegate = self
        collectionView.dataSource = self

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)

        // Configure the cell
        cell.backgroundColor = UIColor.greenColor()
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 1

        return cell
    }

}

// MARK: UICollectionViewDataSource

extension NumberPadCollectionViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 3
    }
}
