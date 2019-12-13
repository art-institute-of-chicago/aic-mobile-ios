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
	var tourCategories: [AICTourCategoryModel]	= []
	var map: AICMapModel
	var restaurants: [AICRestaurantModel] = []
	var dataSettings: [Common.DataSetting: String]	= [:]
	var searchStrings: [String]			= []
	var searchArtworks: [AICObjectModel] = []
}
