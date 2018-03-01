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
	var map: AICMapModel
	var restaurants: [AICRestaurantModel] = []
	
	var featuredTours: [Int]			= []
	var featuredExhibitions: [Int]		= []
	var exhibitionOptionalImages: [Int : URL] = [:]
	var dataSettings: [Common.DataSetting : String]	= [:]
}
