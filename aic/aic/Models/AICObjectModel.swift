/*
 Abstract:
 Defines a data structure for AIC Objects
 (generally artworks)
*/

import Foundation
import CoreGraphics

struct AICObjectModel {
    // MARK: Properties
    let nid: Int

	// id from museum collection
	let objectId: Int?

    let thumbnailUrl: URL
    let thumbnailCropRect: CGRect?
    let imageUrl: URL
    let imageCropRect: CGRect?
    let title: String

    let audioCommentaries: [AICAudioCommentaryModel]

    let tombstone: String?
    let credits: String?

    let imageCopyright: String?

    let location: CoordinateWithFloor

	let gallery: AICGalleryModel
}
