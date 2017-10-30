/*
 Abstract:
 The main app data
 */

struct AICAppDataModel {
	var museumInfo:AICMuseumInfoModel
    var galleries:[AICGalleryModel]     = []
    var objects:[AICObjectModel]        = []
    var audioFiles:[AICAudioFileModel]  = []
    var tours:[AICTourModel]            = []
}
