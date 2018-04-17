/*
 Abstract:
 Represents a museum gallery
*/

struct AICGalleryModel {
    let id: Int
	let galleryId: Int
    let title: String
    let displayTitle: String
    let location: CoordinateWithFloor
    let isOpen: Bool
}
