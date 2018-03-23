/*
 Abstract:
 Defines a data structure for AIC News Items
 */

import Foundation

struct AICTourModel {
    let nid: Int
	
	// Translated content
	var title: String { return self.translations[self.language]!.title }
	var shortDescription: String { return self.translations[self.language]!.shortDescription }
	var longDescription: String { return self.translations[self.language]!.longDescription }
	var durationInMinutes: String? { return self.translations[self.language]!.durationInMinutes }
	var overview: AICTourOverviewModel { return self.translations[self.language]!.overview }
	
	let isFeatured: Bool
	let category: AICTourCategoryModel?
    
    let additionalInformation: String? = nil
    let imageUrl: URL
	
	let location: CoordinateWithFloor
	
	var stops: [AICTourStopModel] {
		var result = [AICTourStopModel]()
		for stop in allStops {
			if stop.audio.availableLanguages.contains(self.language) {
				result.append(stop)
			}
		}
		return result
	}
	
	let allStops: [AICTourStopModel]
	
	var translations: [Common.Language : AICTourTranslationModel]
	
	var language: Common.Language = .english {
		didSet {
			if availableLanguages.contains(language) == false {
				self.language = oldValue
			}
		}
	}
	
	var availableLanguages: [Common.Language] {
		var languages: [Common.Language] = []
		for (key, _) in translations {
			languages.append(key)
		}
		return languages
	}
	
    func getObjectsForStops() -> [AICObjectModel] {
        var objects:[AICObjectModel] = []
        for stop in stops {
            objects.append(stop.object)
        }
        return objects
    }
    
    func getIndex(forStopObject stopObject: AICObjectModel) -> Int? {
        for (index, stop) in stops.enumerated() {
            if stop.object.nid == stopObject.nid {
                return index
            }
        }
        return nil
    }
	
	func getIndex(forStopAudio audio: AICAudioFileModel) -> Int? {
		for (index, stop) in stops.enumerated() {
			if stop.audio.nid == audio.nid {
				return index
			}
		}
		return nil
	}
}

struct AICTourTranslationModel {
	let title: String
	let shortDescription: String
	let longDescription: String
	let durationInMinutes: String?
	let overview: AICTourOverviewModel
}
