/*
 Abstract:
 Section View controller for Number Pad section
*/

import UIKit
protocol AudioGuideSectionViewControllerDelegate : class {
    func audioGuideDidSelectObject(object:AICObjectModel, audioGuideID: Int)
}

class AudioGuideSectionViewController : SectionViewController {
    private let buttonSizeRatio:CGFloat = 0.1725 // Ratio of preferred button size to screen width
    private let colSpacingRatio:CGFloat = 0.04
    
    let numCols = 3
    let numRows = 4
    
    let buttonValueMap = [0:"1", 1:"2", 2:"3",
                          3:"4", 4:"5", 5:"6",
                          6:"7", 7:"8", 8:"9",
                          9:"<", 10:"0", 11:"GO"
    ]
    
    let audioGuideView:AudioGuideSectionView
    
    // Delegate
    weak var delegate:AudioGuideSectionViewControllerDelegate?
    
    // Collection view that holds the buttons
    var collectionView:UICollectionView
    
    override init(section:AICSectionModel) {
        // Create collection view
        let buttonSize = Int(buttonSizeRatio * UIScreen.main.bounds.width)
        let buttonSpacing = Int(colSpacingRatio * UIScreen.main.bounds.width)
        
        // Create collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: buttonSize, height: buttonSize)
        layout.minimumInteritemSpacing = CGFloat(buttonSpacing);
        layout.minimumLineSpacing = CGFloat(buttonSpacing);
        
        let width = CGFloat((buttonSize * numCols) + buttonSpacing * (numCols-1))
        let height = CGFloat((buttonSize * numRows) + buttonSpacing * (numRows-1))
        
        collectionView = UICollectionView(frame: CGRect(x: 0,y: 0, width: width, height: height), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        // Create our view
        audioGuideView = AudioGuideSectionView(section: section, numberPadView: collectionView)
        
        // Register cell classes
        collectionView.register(AudioGuideCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        // Init SectionViewController
        super.init(section: section)
		self.view = audioGuideView
        
        // Set delegate for Collection view
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reset() {
        audioGuideView.clearInput()
    }
}

// MARK: UICollectionViewDataSource
extension AudioGuideSectionViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AudioGuideCollectionViewCell
        
        //TODO: Not sure that NSIndexPath conversion is necessary, may be auto converted with swift 3
        let titleLabel = buttonValueMap[((indexPath as NSIndexPath).section * numCols) + (indexPath as NSIndexPath).row]
        switch titleLabel! {
        case "<":
            cell.button.setImage(#imageLiteral(resourceName: "deleteButton"), for: UIControlState())
        default:
            cell.button.setTitle(titleLabel, for: UIControlState())
        }
        
        if (indexPath as NSIndexPath).row == 9 || (indexPath as NSIndexPath).row == 11 {
            cell.hideBorder()
        }
        
        cell.button.tag = (indexPath as NSIndexPath).row
        cell.button.addTarget(self, action: #selector(AudioGuideSectionViewController.buttonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        // Configure the cell
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return numRows * numCols
    }
}

// MARK: Gesture handlers
extension AudioGuideSectionViewController {
    @objc internal func buttonPressed(_ button:UIButton) {
        let view = self.view as! AudioGuideSectionView
        
        let strVal = buttonValueMap[button.tag]!
        switch strVal {
        case "GO":
            guard let id:Int = Int(view.curInputValue) else {
                view.shakeForIncorrect()
                return
            }
            
            guard let object = AppDataManager.sharedInstance.getObject(forAudioGuideID: id) else {
                view.shakeForIncorrect()
                return
            }
                
            delegate?.audioGuideDidSelectObject(object: object, audioGuideID: id)
            audioGuideView.clearInput()
            
        case "<":
            view.removeLastNumberPadInput()
            
        default:
            view.addNumberPadInput(value: button.titleLabel!.text!)
        }
        
        
    }
}

extension AudioGuideSectionViewController : UICollectionViewDelegateFlowLayout {
    
}
