/*
 Abstract:
 The main app data
 */

struct AICAppDataModel {
	let generalInfo: AICGeneralInfoModel
    var galleries: [AICGalleryModel]	= []
    var objects: [AICObjectModel]		= []
    var audioFiles: [AICAudioFileModel] = []
    var tours: [AICTourModel]			= []
	var featuredTours: [Int]			= []
	var featuredExhibitions: [Int]		= []
	var exhibitionOptionalImages: [Int : URL] = [:]
}
