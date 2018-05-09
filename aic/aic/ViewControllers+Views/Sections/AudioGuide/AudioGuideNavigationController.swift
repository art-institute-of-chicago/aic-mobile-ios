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
	let rootVC: AudioGuideViewController = AudioGuideViewController()
	
    static var buttonSizeRatio: CGFloat = 0.1946 // Ratio of preferred button size to screen width
    static let colSpacingRatio: CGFloat = 0.048
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
		self.automaticallyAdjustsScrollViewInsets = false
		
		sectionNavigationBar.headerView.backgroundColor = .clear
		
		// Setup Collection view
		collectionView.delaysContentTouches = false
		collectionView.register(AudioGuideCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		collectionView.dataSource = self
		collectionView.delegate = self
		
		rootVC.automaticallyAdjustsScrollViewInsets = false
		rootVC.view.backgroundColor = .clear
		rootVC.navigationItem.title = sectionModel.title
		rootVC.view.addSubview(collectionView)
		
		self.pushViewController(rootVC, animated: false)
		
		createViewConstraints()
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if currentInputValue.isEmpty == false {
			sectionNavigationBar.titleLabel.text = String(currentInputValue)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Accessibility
		tabBarController!.tabBar.isAccessibilityElement = true
		sectionNavigationBar.titleLabel.becomeFirstResponder()
		self.perform(#selector(accessibilityReEnableTabBar), with: nil, afterDelay: 2.0)
	}
	
	@objc private func accessibilityReEnableTabBar() {
		tabBarController!.tabBar.isAccessibilityElement = false
	}
	
	static func createCollectionView() -> UICollectionView {
		// Adjust size for iPhone 5 screen size
		if UIScreen.main.bounds.height < 600 {
			buttonSizeRatio = buttonSizeRatio * 0.9
		}
		
		let buttonSize = Int(buttonSizeRatio * UIScreen.main.bounds.width)
		let buttonSpacing = Int(colSpacingRatio * UIScreen.main.bounds.width)
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets.zero
		layout.itemSize = CGSize(width: buttonSize, height: buttonSize)
		layout.minimumInteritemSpacing = CGFloat(buttonSpacing)
		layout.minimumLineSpacing = CGFloat(buttonSpacing)
		layout.headerReferenceSize = CGSize.zero
		layout.sectionHeadersPinToVisibleBounds = true
		layout.footerReferenceSize = CGSize.zero
		
		let width = CGFloat((buttonSize * numCols) + buttonSpacing * (numCols-1))
		let height = CGFloat((buttonSize * numRows) + buttonSpacing * (numRows-1))
		
		let collectionView = UICollectionView(frame: CGRect(x: 0,y: 0, width: width, height: height), collectionViewLayout: layout)
		collectionView.contentInset = UIEdgeInsets.zero
		collectionView.isScrollEnabled = false
		collectionView.backgroundColor = .clear
		return collectionView
	}
	
	func createViewConstraints() {
		collectionView.autoSetDimensions(to: collectionView.frame.size)
		collectionView.autoAlignAxis(.vertical, toSameAxisOf: rootVC.view)

		var collectionViewTopOffset: CGFloat = -25
		if UIDevice().type == .iPhoneX {
			collectionViewTopOffset = 15
		}
		else if UIScreen.main.bounds.height < 600 {
			// Adjust size for iPhone 5 screen size
			collectionViewTopOffset = -40
		}
		
		collectionView.autoPinEdge(.top, to: .top, of: rootVC.view, withOffset: Common.Layout.navigationBarHeight + collectionViewTopOffset, relation: .greaterThanOrEqual)
	}
	
	// MARK: Language
	
	override func updateLanguage() {
		super.updateLanguage()
		
		collectionView.reloadData()
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
			updateLanguage() // resets to title for current language
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
		
		// reset reused cell
		cell.reset()
		
		let titleLabel = buttonValueMap[(indexPath.section * AudioGuideNavigationController.numCols) + indexPath.row]
        switch titleLabel! {
        case "<":
			cell.button.setImage(#imageLiteral(resourceName: "deleteButton"), for: .normal)
            cell.button.setImage(#imageLiteral(resourceName: "deleteButton").colorized(.white), for: .highlighted)
			
			// Accessibility
			cell.button.accessibilityLabel = "Delete"
		case "GO":
			cell.button.setTitle("Go".localized(using: "AudioGuide"), for: .normal)
        default:
            cell.button.setTitle(titleLabel, for: .normal)
        }
        
        if indexPath.row == 9 {
            cell.hideBorder()
        }
        
        cell.button.tag = (indexPath as NSIndexPath).row
        cell.button.addTarget(self, action: #selector(AudioGuideNavigationController.buttonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        // Configure the cell
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return AudioGuideNavigationController.numRows * AudioGuideNavigationController.numCols
    }
}

extension AudioGuideNavigationController : UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize.zero
	}
	
	func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
		return CGPoint.zero
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
