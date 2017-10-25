/*
 Abstract:
 Data model for info received from member card API
*/

struct AICMemberCardAPIData {
    let primaryConstituentID:String
    let memberNames:[String]
    let memberLevel:String
    let memberZip:String
    let expirationDate:String
}
