/*
 Abstract:
 Validates and Retrieves member card information
 */

import Alamofire
import SWXMLHash

protocol MemberCardDataValidatorDelegate : class {
    func memberCardDataValidatorDidValidateMember(_ data:AICMemberCardAPIData)
    func memberCardDataValidatorValidationError(_ error:String)
    func memberCardDataValidatorParseError()
}

class MemberCardDataValidator {
    
    weak var delegate:MemberCardDataValidatorDelegate?
    
    // Execute SOAP request to validate member
    func validateMember(forMemberID memberID:String, withZipCode zip:String) {
        var SOAPRequest =   "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        SOAPRequest +=      "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:xmethods-delayed-quotes\">\n"
        SOAPRequest +=      "<soapenv:Header/>\n"
        SOAPRequest +=      "<soapenv:Body>\n"
        SOAPRequest +=          "<urn:member_soap_retrieve>\n"
        SOAPRequest +=              "<pcid>\(memberID)</pcid>\n"
        SOAPRequest +=              "<phone></phone>\n"
        SOAPRequest +=              "<email></email>\n"
        SOAPRequest +=              "<zip>\(zip)</zip>\n"
        SOAPRequest +=          "</urn:member_soap_retrieve>\n"
        SOAPRequest +=      "</soapenv:Body>\n"
        SOAPRequest +=      "</soapenv:Envelope>"

        var request = URLRequest(url: URL(string: Common.DataConstants.memberCardSOAPRequestURL)!)
        request.addValue("urn:xmethods-delayed-quotes#member_soap_retrieve", forHTTPHeaderField: "SOAPAction")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
        request.addValue("\(SOAPRequest.characters.count)", forHTTPHeaderField: "Content-Length")
        request.addValue("text/xml", forHTTPHeaderField: "Accept")
        request.addValue("UTF-8", forHTTPHeaderField: "Accept-Charset")
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = SOAPRequest.data(using: String.Encoding.utf8)
        
        Alamofire.request(request).responseData { response in
                let xml = SWXMLHash.config({ config in
                    config.shouldProcessNamespaces = true
                }).parse(response.data!)

                self.parse(response:xml, zip: zip)
            }
    }
    
    // Parse the Response from SOAP request
    private func parse(response:XMLIndexer, zip:String) {
        
        // See if we had an error
        do {
            let faultCode = try response.byKey("Envelope").byKey("Body").byKey("Fault").byKey("faultcode").element?.text
            
            if faultCode != nil {
                delegate?.memberCardDataValidatorValidationError(faultCode!)
            } else {
                delegate?.memberCardDataValidatorValidationError("Unknown Error")
            }
        }
            
            // Error doees not exist, try to parse out the member info
        catch {
            do {
                let mainXML = try response.byKey("Envelope").byKey("Body").byKey("member_soap_retrieveResponse").byKey("response_object")
                
                let resultCode = try mainXML.byKey("ResultCode").element?.text
                
                if Int(resultCode!) == 0 {
                    let memberships = try mainXML.byKey("Memberships")
                    
                    if memberships.children.count != 0 {
                        // Get first member info
                        let memberInfo = try memberships.byKey("Member-1")
                        
                        let primaryConstituentID = try memberInfo.byKey("PrimaryConstituentID").element?.text
                        let memberLevel = try memberInfo.byKey("MemberLevel").element?.text
                        let expirationDate = try memberInfo.byKey("Expiration").element?.text
                        
                        
                        var memberNames:[String] = []
                        
                        let mainMemberName = try memberInfo.byKey("CardHolder").element?.text
                        if mainMemberName != nil {
                            memberNames.append(mainMemberName!)
                        }
                        
                        // Try to get second member info
                        // some cards have multiple names attached
                        do {
                            let member2Info:XMLIndexer? = try memberships.byKey("Member-2")
                            
                            if member2Info != nil {
                                let member2Name = try member2Info!.byKey("CardHolder").element?.text
                                if member2Name != nil {
                                    memberNames.append(member2Name!)
                                }
                            }
                        } catch {}
                        
                        if (primaryConstituentID != nil && (memberNames.count > 0) && memberLevel != nil) {
                            self.delegate?.memberCardDataValidatorDidValidateMember(AICMemberCardAPIData(primaryConstituentID: primaryConstituentID!,
                                                                                                      memberNames: memberNames,
                                                                                                      memberLevel: memberLevel!,
                                                                                                      memberZip: zip,
                                                                                                      expirationDate: expirationDate!)
                            )
                        }
                    } else {
                        // Error: No memberships
                        print("Could not find memberships: \(memberships)")
                    }
                    
                    return
                }
            } catch {
                delegate?.memberCardDataValidatorParseError()
            }
        }
    }
}

