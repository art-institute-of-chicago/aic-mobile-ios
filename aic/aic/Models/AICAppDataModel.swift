/*
Abstract:
The main app data
*/

import Foundation

struct AICAppDataModel {
	let generalInfo: AICGeneralInfoModel
	var galleries: [AICGalleryModel] = []
	var objects: [AICObjectModel] = []
	var audioFiles: [AICAudioFileModel] = []
	var tours: [AICTourModel] = []
	var tourCategories: [AICTourCategoryModel] = []
	var map: AICMapModel
	var restaurants: [AICRestaurantModel] = []
	var dataSettings: [Common.DataSetting: String] = [:]
	var searchStrings: [String] = []
	var searchArtworks: [AICObjectModel] = []
	var messages: [AICMessageModel] = []
}

struct CMSData: Decodable {
    let objects: [Int:CMSObject]
    let data: CMSURLs
    let tours: [CMSTour]
    let audio_files: [Int:CMSAudio]
}

struct CMSObject: Decodable {
    let title: String
    let nid: Int
    let id: Int
    let location: String    // lat,lon
    let gallery_location: String
}

struct CMSURLs: Decodable {
    let artworks_endpoint: String
    let data_api_url: String
    let events_endpoint_v2: String
    let exhibitions_endpoint: String
}

struct CMSTour: Decodable {
    let nid: String
    let title: String
    let description: String
    let intro: String
    let weight: Int
    let category: String?
    let image_url: URL
    let latitude: Double
    let longitude: Double
    let floor: String
    let tour_stops: [CMSTourStop]
    
    struct CMSTourStop: Decodable {
        let object: Int
        let audio_id: String
        let audio_bumper: String?
        let sort: Int
    }
}

struct CMSAudio: Decodable {
    let title: String
    let nid: String
    let audio_file_url: URL
    let audio_transcript: String
}
