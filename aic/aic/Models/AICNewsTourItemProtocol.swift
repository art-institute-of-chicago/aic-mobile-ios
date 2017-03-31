/*
 Abstract:
 Common values for News Items and Tour Items
 */

import Foundation

enum NewsTourItemType {
    case news
    case tour
}

protocol AICNewsTourItemProtocol {
    var type:NewsTourItemType { get }
    var title:String { get }
    var shortDescription:String { get }
    var longDescription:String { get }
    var additionalInformation:String? { get }
    var imageUrl:URL { get }
    var revealTitle:String { get }
    var bannerString:String? { get }
}
