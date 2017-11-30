/*
 Abstract:
 Defines a data structure for AIC News Items
 */

import Foundation

struct AICTourModel : AICNewsTourItemProtocol {
    let type:NewsTourItemType = .tour
    
    let nid:Int
    
    let title:String
    let shortDescription:String
    let longDescription:String
    
    let additionalInformation: String? = nil
    let imageUrl:URL
    
    let revealTitle: String = "Start Tour"
    
    let overview:AICTourOverviewModel
    let stops:[AICTourStopModel]
    
    let bannerString: String?
	
	let durationInMinutes: String?
    
    func getObjectsForStops() -> [AICObjectModel] {
        var objects:[AICObjectModel] = []
        for stop in stops {
            objects.append(stop.object)
        }
        
        return objects
    }
    
    func getIndex(forStopObject stopObject:AICObjectModel) -> Int? {
        for (index, stop) in stops.enumerated() {
            if stop.object.nid == stopObject.nid {
                return index
            }
        }
        
        return nil
    }
}
