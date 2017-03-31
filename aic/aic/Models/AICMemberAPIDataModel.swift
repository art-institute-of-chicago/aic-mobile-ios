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
    
    //    init(primaryConstituentID:Int64, memberName:String, memberName2:String = "nil", memberLevel:String, memberZip:Int, expirationDate:String){
    //        self.primaryConstituentID = primaryConstituentID
    //        self.memberName = memberName
    //        self.memberName2 = memberName2
    //        self.memberLevel = memberLevel
    //        self.memberZip = memberZip
    //        self.expirationDate = expirationDate
    //    }
}
