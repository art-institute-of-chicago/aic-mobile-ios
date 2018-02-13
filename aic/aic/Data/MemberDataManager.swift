/*
 Abstract:
 Validates and Retrieves member card information
 */

import Alamofire

protocol MemberDataManagerDelegate : class {
	func memberCardDidLoadForMember(memberCard: AICMemberCardModel)
	func memberCardDataLoadingFailed()
}

class MemberDataManager {
	private (set) var currentMemberCard: AICMemberCardModel? = nil
	var currentMemberNameIndex: Int = 0
	
    weak var delegate: MemberDataManagerDelegate?
	
	private let dataParser = AppDataParser()
	
	func validateMember(memberID: String, zipCode: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += "/api/v1/members"
		url += "/" + memberID + "?zip=" + zipCode
		let request = URLRequest(url: URL(string: url)!)
		
		Alamofire.request(request as URLRequestConvertible)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					do {
						let memberCard = try self.dataParser.parse(memberData: value, zipCode: zipCode)
						self.currentMemberCard = memberCard
						self.saveCurrentMember()
						self.delegate?.memberCardDidLoadForMember(memberCard: memberCard)
					}
					catch {
						if Common.Testing.printDataErrors {
							print("Could not parse AIC Member Card Data:\n\(value)\n")
						}
						self.delegate?.memberCardDataLoadingFailed()
					}
				case .failure(let error):
					self.delegate?.memberCardDataLoadingFailed()
					print(error)
				}
		}
	}
	
	func saveCurrentMember() {
		guard let memberCard = self.currentMemberCard else {
			return
		}
		
		let defaults = UserDefaults.standard
		
		// Store
		defaults.set(memberCard.cardId, forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey)
		defaults.set(memberCard.memberZip, forKey: Common.UserDefaults.memberInfoZipUserDefaultsKey)
		defaults.set(currentMemberNameIndex, forKey: Common.UserDefaults.memberInfoSelectedMemberDefaultsKey)
		
		defaults.synchronize()
	}
	
	func getSavedMember() -> AICMemberInfoModel? {
		let defaults = UserDefaults.standard
		
		let storedID = defaults.object(forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey) as? String
		let storedZip = defaults.object(forKey: Common.UserDefaults.memberInfoZipUserDefaultsKey) as? String
		let storedMemberNameIndex = defaults.object(forKey: Common.UserDefaults.memberInfoSelectedMemberDefaultsKey) as? Int
		
		if storedID != nil && storedZip != nil && storedMemberNameIndex != nil {
			currentMemberNameIndex = storedMemberNameIndex!
			return AICMemberInfoModel(memberID: storedID!, memberZip: storedZip!)
		}
		
		return nil
	}
}

