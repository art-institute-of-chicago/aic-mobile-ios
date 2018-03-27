/*
 Abstract:
 Handles log in and display of member cards
 */

import UIKit

class InfoSectionMemberCardViewController: UIViewController {
    
    let memberCardView = InfoSectionMemberCardView()
    let memberCardValidator = MemberDataManager()
    
    var isShowingBarcode = false
    
    var currentMemberAPIData:AICMemberCardModel? = nil
    var currentlySelectedMember:Int = 0
    
    override func loadView() {
        self.view = memberCardView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memberCardValidator.delegate = self
        
//        // Restrict member card input to integer values only
//        memberCardView.memberIDTextField.delegate = self
//        memberCardView.memberZipCodeTextField.delegate = self
        
        // Gestures
        let dismissKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(InfoSectionMemberCardViewController.hideKeyboard))
        self.view.addGestureRecognizer(dismissKeyboardTapGesture)
        
        let signInUpdateButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(InfoSectionMemberCardViewController.signInUpdateButtonTapped(_:)))
        memberCardView.signInUpdateButton.addGestureRecognizer(signInUpdateButtonTapGesture)
        
        let switchMemberCardHolderButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(InfoSectionMemberCardViewController.switchMemberCardHolderButtonTapped(_:)))
        memberCardView.switchMemberCardHolderButton.addGestureRecognizer(switchMemberCardHolderButtonTapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMemberFromUserDefaults()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    fileprivate func loadMember(fromMemberInfoModel infoModel:AICMemberInfoModel) {
        // Hide the input + barcode, showing loading indicator
        memberCardView.memberInputContentView.isHidden = true
        memberCardView.barcodeContentView.isHidden = true
        memberCardView.switchMemberCardHolderButton.isHidden = true
        memberCardView.signInUpdateButton.isHidden = true
        memberCardView.loadingIndicator.startAnimating()
        
        // Load the member
        memberCardValidator.validateMember(memberID: infoModel.memberID, zipCode: infoModel.memberZip)
    }
    
    fileprivate func loadMemberFromInputFields() {
        let id = memberCardView.memberIDTextField.text
        let zip = memberCardView.memberZipCodeTextField.text
		
        if id != nil && zip != nil {
			loadMember(fromMemberInfoModel: AICMemberInfoModel(memberID: id!, memberZip: zip!))
        }
    }
    
    fileprivate func loadMemberFromUserDefaults() {
        // Try to show the member info if it was previosuly set
        let memberInfo = getSavedMember()
        if memberInfo != nil {
            loadMember(fromMemberInfoModel: memberInfo!)
        } else {
            showInput()
        }
    }
    
    fileprivate func showInput() {
        let memberInfo = getSavedMember()
        if memberInfo != nil {
            memberCardView.memberIDTextField.text = String(memberInfo!.memberID)
            memberCardView.memberZipCodeTextField.text = String(memberInfo!.memberZip)
        }
        
        // Hide/Show content views
        memberCardView.loadingIndicator.stopAnimating()
        memberCardView.barcodeContentView.isHidden = true
        memberCardView.memberInputContentView.isHidden = false
        
        // Set the button
        memberCardView.signInUpdateButton.isHidden = false
        memberCardView.signInUpdateButton.setTitle("Sign In", for: UIControlState())
        
        
        memberCardView.switchMemberCardHolderButton.setTitle(Common.Info.memberSwitchCardHolder, for: UIControlState())
        memberCardView.switchMemberCardHolderButton.isHidden = true
        
        
        isShowingBarcode = false
    }
    
    fileprivate func showMemberInfo() {
        guard let apiData = currentMemberAPIData else {
            return
        }
        
        // Create barcode
        let data = String(apiData.cardId).data(using: String.Encoding.ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter!.setValue(data, forKey: "inputMessage")
        
        let barcodeCIImage = filter!.outputImage!
        
        let barcodeImage = UIImage(ciImage: barcodeCIImage.transformed(by: CGAffineTransform(scaleX: 5,y: 3)))
        
        // Set barcode view
        memberCardView.barcodeMemberName.text = apiData.memberNames[currentlySelectedMember]
        
        
        var isReciprocal = false
        
        switch apiData.memberLevel {
        case "Life Membership":
            memberCardView.barcodeMemberLevel.text = "Life Member"
            memberCardView.barcodeExpirationDate.text = "Expires: Life"
        case "Premium Member":
            isReciprocal = true
        case "Lionhearted Council":
            isReciprocal = true
        case "Lionhearted Roundtable":
            isReciprocal = true
        case "Lionhearted Circle":
            isReciprocal = true
        case "Sustaining Fellow Young":
            isReciprocal = true
        case "Sustaining Fellow":
            isReciprocal = true
        case "Sustaining Fellow Bronze":
            isReciprocal = true
        case "Sustaining Fellow Silver":
            isReciprocal = true
        case "Sustaining Fellow Sterling":
            isReciprocal = true
        case "Sustaining Fellow Gold":
            isReciprocal = true
        case "Sustaining Fellow Platinum":
            isReciprocal = true
        default:
            isReciprocal = false
        }
        
        memberCardView.isReciprocalMember = isReciprocal
        memberCardView.barcodeMemberLevel.text = apiData.memberLevel
        memberCardView.barcodeExpirationDate.text = "Expires: \(apiData.expirationDate)"
        
        memberCardView.barcodeImageView.image = barcodeImage
        
        // Hide/show content views
        memberCardView.loadingIndicator.stopAnimating()
        memberCardView.memberInputContentView.isHidden = true
        memberCardView.barcodeContentView.isHidden = false
        
        // Set the button
        memberCardView.signInUpdateButton.isHidden = false
        memberCardView.signInUpdateButton.setTitle(Common.Info.memberUpdateTitle, for: UIControlState())
        
        memberCardView.switchMemberCardHolderButton.isHidden = apiData.memberNames.count == 1
        
        isShowingBarcode = true
        
        // Log analytics
//        AICAnalytics.memberDidShowMemberCard(memberID: apiData.cardId)
    }
    
    fileprivate func saveCurrentMember() {
        guard let apiData = currentMemberAPIData else {
            return
        }
        
        let defaults = UserDefaults.standard
        
        // Store
        defaults.set(apiData.cardId, forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey)
        defaults.set(apiData.memberZip, forKey: Common.UserDefaults.memberInfoZipUserDefaultsKey)
        
        // Reset selected member if we are switching to another ID
        let curSavedMemberID = defaults.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) as? String
        if curSavedMemberID != apiData.cardId {
            defaults.set(0, forKey: Common.UserDefaults.memberInfoSelectedMemberDefaultsKey)
            currentlySelectedMember = 0
        } else {
            defaults.set(currentlySelectedMember, forKey: Common.UserDefaults.memberInfoSelectedMemberDefaultsKey)
        }
        
        defaults.synchronize()
    }
    
    fileprivate func getSavedMember() -> AICMemberInfoModel? {
        let defaults = UserDefaults.standard
        
        let storedID = defaults.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) as? String
        let storedZip = defaults.object(forKey: Common.UserDefaults.memberInfoZipUserDefaultsKey) as? String
        let storedSelectedMember = defaults.object(forKey: Common.UserDefaults.memberInfoSelectedMemberDefaultsKey) as? Int
        
        if storedID != nil && storedZip != nil && storedSelectedMember != nil {
            currentlySelectedMember = storedSelectedMember!
            return AICMemberInfoModel(memberID: storedID!, memberZip: storedZip!)
        }
        
        return nil
    }
}

extension InfoSectionMemberCardViewController {
    @objc func signInUpdateButtonTapped(_ gesture:UITapGestureRecognizer) {
        view.endEditing(true)
        
        if isShowingBarcode {
            showInput()
        } else {
            loadMemberFromInputFields()
        }
    }
    
    @objc func switchMemberCardHolderButtonTapped(_ gesture:UITapGestureRecognizer) {
        view.endEditing(true)
        
        if let apiData = self.currentMemberAPIData {
            currentlySelectedMember = currentlySelectedMember < apiData.memberNames.count - 1 ? currentlySelectedMember + 1 : 0
            memberCardView.barcodeMemberName.text = apiData.memberNames[currentlySelectedMember]
            
            saveCurrentMember()
        }
    }
}

extension InfoSectionMemberCardViewController : UITextFieldDelegate {
    // Textbox content restrictions
    // from http://www.globalnerdy.com/2015/04/27/how-to-program-an-ios-text-field-that-takes-only-numeric-input-or-specific-characters-with-a-maximum-length/
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // We ignore any change that doesn't add characters to the text field.
        // These changes are things like character deletions and cuts, as well
        // as moving the insertion point.
        //
        // We still return true to allow the change to take place.
        if string.count == 0 {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case memberCardView.memberIDTextField:
            return true
        case memberCardView.memberZipCodeTextField:
            return prospectiveText.containsOnlyCharactersIn("0123456789") &&
                prospectiveText.count <= 5
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension InfoSectionMemberCardViewController : MemberDataManagerDelegate {
	func memberCardDidLoadForMember(memberCard: AICMemberCardModel) {
		currentMemberAPIData = memberCard
		saveCurrentMember()
		showMemberInfo()
	}
	
	func memberCardDataLoadingFailed() {
		self.currentMemberAPIData = nil
		self.currentlySelectedMember = 0
		
		let alert = UIAlertController(title: Common.Info.alertMessageParseError, message: "", preferredStyle: UIAlertControllerStyle.alert)
		let action = UIAlertAction(title: Common.Info.alertMessageCancelButtonTitle, style: UIAlertActionStyle.default, handler: { (action) in
			self.loadMemberFromUserDefaults()
		}
		)
		alert.addAction(action)
		present(alert, animated:true)
	}
	
	func memberCardDataLoadingFailedWithError(error: String) {
		self.currentMemberAPIData = nil
		self.currentlySelectedMember = 0
		
		let alert = UIAlertController(title: Common.Info.alertMessageParseError, message: "", preferredStyle: UIAlertControllerStyle.alert)
		let action = UIAlertAction(title: Common.Info.alertMessageCancelButtonTitle, style: UIAlertActionStyle.default, handler: { (action) in
			self.loadMemberFromUserDefaults()
		}
		)
		alert.addAction(action)
		present(alert, animated:true)
	}
}

// Alert Events
extension InfoSectionMemberCardViewController {
    func alertViewCancel(_ action: UIAlertAction) {
        print("Cancelled")
        loadMemberFromUserDefaults()
    }
}
