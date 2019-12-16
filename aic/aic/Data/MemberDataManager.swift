/*
Abstract:
Validates and Retrieves member card information
*/

import Alamofire
import SWXMLHash

protocol MemberDataManagerDelegate: class {
	func memberCardDidLoadForMember(memberCard: AICMemberCardModel)
	func memberCardDataLoadingFailed()
}

class MemberDataManager {
	static let sharedInstance = MemberDataManager()

	private (set) var currentMemberCard: AICMemberCardModel?
	var currentMemberNameIndex: Int = 0

	weak var delegate: MemberDataManagerDelegate?

	private let dataParser = AppDataParser()

	func validateMember(memberID: String, zipCode: String) {
		//		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		//		url += "/api/v1/members"
		//		url += "/" + memberID + "?zip=" + zipCode
		//		let request = URLRequest(url: URL(string: url)!)
		//
		//		Alamofire.request(request as URLRequestConvertible)
		//			.validate()
		//			.responseData { response in
		//				switch response.result {
		//				case .success(let value):
		//					do {
		//						let memberCard = try self.dataParser.parse(memberData: value, zipCode: zipCode)
		//						self.currentMemberCard = memberCard
		//						self.saveCurrentMember()
		//						self.delegate?.memberCardDidLoadForMember(memberCard: memberCard)
		//					}
		//					catch {
		//						if Common.Testing.printDataErrors {
		//							print("Could not parse AIC Member Card Data:\n\(value)\n")
		//						}
		//						self.delegate?.memberCardDataLoadingFailed()
		//					}
		//				case .failure(let error):
		//					self.delegate?.memberCardDataLoadingFailed()
		//					print(error)
		//				}
		//		}

		var SOAPRequest =   "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
		SOAPRequest +=      "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:xmethods-delayed-quotes\">\n"
		SOAPRequest +=      "<soapenv:Header/>\n"
		SOAPRequest +=      "<soapenv:Body>\n"
		SOAPRequest +=          "<urn:member_soap_retrieve>\n"
		SOAPRequest +=              "<pcid>\(memberID)</pcid>\n"
		SOAPRequest +=              "<phone></phone>\n"
		SOAPRequest +=              "<email></email>\n"
		SOAPRequest +=              "<zip>\(zipCode)</zip>\n"
		SOAPRequest +=          "</urn:member_soap_retrieve>\n"
		SOAPRequest +=      "</soapenv:Body>\n"
		SOAPRequest +=      "</soapenv:Envelope>"

		var request = URLRequest(url: URL(string: Common.DataConstants.memberCardSOAPRequestURL)!)
		request.addValue("urn:xmethods-delayed-quotes#member_soap_retrieve", forHTTPHeaderField: "SOAPAction")
		request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.addValue("\(SOAPRequest.count)", forHTTPHeaderField: "Content-Length")
		request.addValue("text/xml", forHTTPHeaderField: "Accept")
		request.addValue("UTF-8", forHTTPHeaderField: "Accept-Charset")
		request.httpMethod = HTTPMethod.post.rawValue
		request.httpBody = SOAPRequest.data(using: String.Encoding.utf8)

		Alamofire.request(request as URLRequestConvertible)
			.responseData { response in
				switch response.result {
				case .success:
					let xml = SWXMLHash.config({ config in
						config.shouldProcessNamespaces = true
					}).parse(response.data!)

					if let memberCard = self.parse(memberXML: xml, zipCode: zipCode) {
						self.currentMemberCard = memberCard
						// Reset memberNameIndex if it's a new member ID
						if let savedMemberInfo = self.getSavedMember() {
							if savedMemberInfo.memberID != memberCard.cardId {
								self.currentMemberNameIndex = 0
							}
						}
						self.saveCurrentMember()
						self.delegate?.memberCardDidLoadForMember(memberCard: memberCard)
					}
				case .failure:
					self.delegate?.memberCardDataLoadingFailed()
				}
		}
	}

	func parse(memberXML response: XMLIndexer, zipCode: String) -> AICMemberCardModel? {
		do {
			let mainXML = try response.byKey("Envelope").byKey("Body").byKey("member_soap_retrieveResponse").byKey("response_object")

			let resultCode = try mainXML.byKey("ResultCode").element?.text

			if Int(resultCode!) == 0 {
				let memberships = try mainXML.byKey("Memberships")

				if memberships.children.count != 0 {
					// Get first member info
					let memberInfo = try memberships.byKey("Member-1")

					let primaryConstituentID = try memberInfo.byKey("PrimaryConstituentID").element?.text
					var memberLevel = try memberInfo.byKey("MemberLevel").element?.text
					let expirationDateString = try memberInfo.byKey("Expiration").element?.text

					let dateFormatter = DateFormatter()
					dateFormatter.locale = Locale(identifier: "en_US")
					dateFormatter.dateFormat = "MM/dd/yyyy"
					dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

					// TODO: fix the timezone

					let expirationDate = dateFormatter.date(from: expirationDateString!)

					var memberNames: [String] = []

					let mainMemberName = try memberInfo.byKey("CardHolder").element?.text
					if mainMemberName != nil {
						memberNames.append(mainMemberName!)
					}

					var isReciprocal = false
					var isLifeMembership = false

					switch memberLevel! {
					case "Life Membership":
						memberLevel = "Life Member"
						isLifeMembership = true
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

					// Try to get second member info
					// some cards have multiple names attached
					do {
						let member2Info: XMLIndexer? = try memberships.byKey("Member-2")

						if member2Info != nil {
							let member2Name = try member2Info!.byKey("CardHolder").element?.text
							if member2Name != nil {
								memberNames.append(member2Name!)
							}
						}
					} catch {}

					if primaryConstituentID != nil && (memberNames.count > 0) && memberLevel != nil && expirationDate != nil {
						return AICMemberCardModel(cardId: primaryConstituentID!,
												  memberNames: memberNames,
												  memberLevel: memberLevel!,
												  memberZip: zipCode,
												  expirationDate: expirationDate!,
												  isReciprocalMember: isReciprocal,
												  isLifeMembership: isLifeMembership
						)
					}
				}
				delegate?.memberCardDataLoadingFailed()
				return nil
			}
			delegate?.memberCardDataLoadingFailed()
			return nil
		} catch {
			delegate?.memberCardDataLoadingFailed()
			return nil
		}
	}

	func saveCurrentMember() {
		guard let memberCard = self.currentMemberCard else {
			return
		}

		let defaults = UserDefaults.standard

		var firstName: String = ""
		if currentMemberNameIndex < memberCard.memberNames.count {
			let fullName: String = memberCard.memberNames[currentMemberNameIndex]
			firstName = String(describing: fullName.split(separator: " ").first!)
		}

		// Store
		defaults.set(memberCard.cardId, forKey: Common.UserDefaults.memberInfoIDUserDefaultsKey)
		defaults.set(memberCard.memberZip, forKey: Common.UserDefaults.memberInfoZipUserDefaultsKey)
		defaults.set(firstName, forKey: Common.UserDefaults.memberFirstNameUserDefaultsKey)
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
