/*
 Abstract:
 Represents an Stop on a tour,
 which is an audio file associated with an ObjectModel
*/

struct AICTourStopModel {
    let order:Int
    let object:AICObjectModel
    let audio:AICAudioFileModel
}
