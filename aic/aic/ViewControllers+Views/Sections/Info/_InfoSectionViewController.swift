/*
 Abstract:
 Section View controller for Info section
*/

import UIKit

class InfoSectionViewController : SectionViewController {
    let infoView:InfoSectionView
    let memberCardVC = InfoSectionMemberCardViewController()
    
    override init(section: AICSectionModel) {
        infoView = InfoSectionView(section: section, memberCardView:  memberCardVC.view as! InfoSectionMemberCardView)
        super.init(section:section)
		self.view = infoView
        
        // Add gestures
        let accessButtonTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(InfoSectionViewController.accessButtonPressed(_:)))
        infoView.becomeMemberView.accessButton.addGestureRecognizer(accessButtonTapGesture)
        
        let memberCardCloseButtonTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(InfoSectionViewController.memberCardCloseButtonPressed(_:)))
        memberCardVC.memberCardView.closeButton.addGestureRecognizer(memberCardCloseButtonTapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Configure the become member view appropriately if a member is already signed in
        infoView.becomeMemberView.savedMember = self.getSavedMember()
    }
    
    //MARK: Saved membership checking
    
    fileprivate func getSavedMember() -> AICMemberInfoModel? {
        let defaults = UserDefaults.standard
        
        let storedID = defaults.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) as? String
        let storedZip = defaults.object(forKey: Common.UserDefaults.memberInfoZipUserDefaultsKey) as? String
        let storedSelectedMember = defaults.object(forKey: Common.UserDefaults.memberInfoSelectedMemberDefaultsKey) as? Int
        
        if storedID != nil && storedZip != nil && storedSelectedMember != nil {
            return AICMemberInfoModel(memberID: storedID!, memberZip: storedZip!)
        }
        
        return nil
    }
}



// Gesture Handlers
extension InfoSectionViewController {
    @objc func accessButtonPressed(_ gesture:UITapGestureRecognizer) {
        view.addSubview(infoView.memberCardView)
    }
    
    @objc func memberCardCloseButtonPressed(_ gesture:UITapGestureRecognizer) {
        infoView.memberCardView.removeFromSuperview()
        //Check again to see if a member just signed in, and update the BecomeMemberView
        infoView.becomeMemberView.savedMember = self.getSavedMember()
        infoView.becomeMemberView.setNeedsUpdateConstraints()
    }
}
