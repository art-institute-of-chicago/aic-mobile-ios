/*
 Abstract:
 Section View controller for Number Pad section
*/

import UIKit
import Localize_Swift

protocol AudioGuideNavigationControllerDelegate : class {
    func audioGuideDidSelectObject(object:AICObjectModel, audioGuideID: Int)
}

class AudioGuideNavigationController : SectionNavigationController {
	let rootViewController: UIViewController = UIViewController()
	
    static let buttonSizeRatio:CGFloat = 0.1946 // Ratio of preferred button size to screen width
    static let colSpacingRatio:CGFloat = 0.048
	// No top margin on iPhone 5, should define this width somewhere this is gross
	let numberPadTopMargin = UIScreen.main.bounds.width > 320 ? 30 : 0
	
	static let numCols = 3
    static let numRows = 4
    let buttonValueMap = [0:"1", 1:"2", 2:"3",
                          3:"4", 4:"5", 5:"6",
                          6:"7", 7:"8", 8:"9",
                          9:"<", 10:"0", 11:"GO"]
	private let maxInputCharacters = 5
	private(set) var currentInputValue = "";
    
    // Delegate
    weak var sectionDelegate: AudioGuideNavigationControllerDelegate?
    
    // Collection view that holds the buttons
    var collectionView: UICollectionView = createCollectionView()
    
    override init(section:AICSectionModel) {
		super.init(section: section)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = sectionModel.color
		
		sectionNavigationBar.headerView.backgroundColor = .clear
		
		// Setup Collection view
		collectionView.delaysContentTouches = false
		collectionView.register(AudioGuideCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		collectionView.dataSource = self
		
		rootViewController.view.backgroundColor = .clear
		rootViewController.navigationItem.title = sectionModel.title
		rootViewController.view.addSubview(collectionView)
		
		self.pushViewController(rootViewController, animated: false)
		
		createViewConstraints()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if currentInputValue.isEmpty == false {
			sectionNavigationBar.titleLabel.text = String(currentInputValue)
		}
	}
	
	static func createCollectionView() -> UICollectionView {
		let buttonSize = Int(buttonSizeRatio * UIScreen.main.bounds.width)
		let buttonSpacing = Int(colSpacingRatio * UIScreen.main.bounds.width)
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		layout.itemSize = CGSize(width: buttonSize, height: buttonSize)
		layout.minimumInteritemSpacing = CGFloat(buttonSpacing);
		layout.minimumLineSpacing = CGFloat(buttonSpacing);
		
		let width = CGFloat((buttonSize * numCols) + buttonSpacing * (numCols-1))
		let height = CGFloat((buttonSize * numRows) + buttonSpacing * (numRows-1))
		
		let collectionView = UICollectionView(frame: CGRect(x: 0,y: 0, width: width, height: height), collectionViewLayout: layout)
		collectionView.backgroundColor = .clear
		return collectionView
	}
	
	func createViewConstraints() {
		collectionView.autoSetDimensions(to: collectionView.frame.size)
		collectionView.autoAlignAxis(.vertical, toSameAxisOf: rootViewController.view)
		
		var collectionViewTopOffset: CGFloat = -25
		if UIDevice().type == .iPhoneX {
			collectionViewTopOffset = 15
		}
		collectionView.autoPinEdge(.top, to: .top, of: rootViewController.view, withOffset: Common.Layout.navigationBarHeight + collectionViewTopOffset, relation: .greaterThanOrEqual)
	}
    
    func reset() {
        clearInput()
    }
	
	private func clearInput() {
		currentInputValue = ""
		setTitleForCurInputValue()
	}
	
	private func setTitleForCurInputValue() {
		let curNumInputChars = currentInputValue.count
		
		if curNumInputChars == 0 {
			sectionNavigationBar.titleLabel.text = rootViewController.navigationItem.title?.localized(using: "Sections")
		} else {
			sectionNavigationBar.titleLabel.text = currentInputValue
		}
	}
	
	private func addNumberPadInput(value:String) {
		if currentInputValue.count < maxInputCharacters {
			currentInputValue.append(value)
		}
		
		setTitleForCurInputValue()
	}
	
	private func removeLastNumberPadInput() {
		let curNumInputChars = currentInputValue.count
		if curNumInputChars > 0 {
			if curNumInputChars == 1 {
				currentInputValue = ""
			} else {
				let index = currentInputValue.index(currentInputValue.endIndex, offsetBy: -1)
				currentInputValue = String(currentInputValue[..<index])
			}
		}
		
		setTitleForCurInputValue()
	}
	
	// Simple shake animation
	// from http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
	private func shakeForIncorrect() {
		let animation = CABasicAnimation(keyPath: "position")
		animation.duration = 0.07
		animation.repeatCount = 4
		animation.autoreverses = true
		animation.fromValue = NSValue(cgPoint: CGPoint(x: sectionNavigationBar.titleLabel.center.x - 10, y: sectionNavigationBar.titleLabel.center.y))
		animation.toValue = NSValue(cgPoint: CGPoint(x: sectionNavigationBar.titleLabel.center.x + 10, y: sectionNavigationBar.titleLabel.center.y))
		sectionNavigationBar.titleLabel.layer.add(animation, forKey: "position")
	}
}

// MARK: UICollectionViewDataSource
extension AudioGuideNavigationController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AudioGuideCollectionViewCell
        
        //TODO: Not sure that NSIndexPath conversion is necessary, may be auto converted with swift 3
		let titleLabel = buttonValueMap[((indexPath as NSIndexPath).section * AudioGuideNavigationController.numCols) + (indexPath as NSIndexPath).row]
        switch titleLabel! {
        case "<":
            cell.button.setImage(#imageLiteral(resourceName: "deleteButton"), for: UIControlState())
        default:
            cell.button.setTitle(titleLabel, for: UIControlState())
        }
        
        if (indexPath as NSIndexPath).row == 9 {
            cell.hideBorder()
        }
        
        cell.button.tag = (indexPath as NSIndexPath).row
        cell.button.addTarget(self, action: #selector(AudioGuideNavigationController.buttonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        // Configure the cell
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
		return AudioGuideNavigationController.numRows * AudioGuideNavigationController.numCols
    }
}

// MARK: Gesture handlers
extension AudioGuideNavigationController {
    @objc internal func buttonPressed(_ button:UIButton) {
        let strVal = buttonValueMap[button.tag]!
        switch strVal {
        case "GO":
            guard let id:Int = Int(currentInputValue) else {
                shakeForIncorrect()
                return
            }
            
            guard let object = AppDataManager.sharedInstance.getObject(forSelectorNumber: id) else {
                shakeForIncorrect()
                return
            }
                
            sectionDelegate?.audioGuideDidSelectObject(object: object, audioGuideID: id)
            clearInput()
            
        case "<":
            removeLastNumberPadInput()
            
        default:
            addNumberPadInput(value: button.titleLabel!.text!)
        }
    }
}
