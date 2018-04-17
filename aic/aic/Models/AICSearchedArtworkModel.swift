//
//  AICSearchedArtworkModel.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import Foundation

struct AICSearchedArtworkModel {
	let artworkId: Int
	let audioObject: AICObjectModel?
	let title: String
	let thumbnailUrl: URL
	let imageUrl: URL
	let artistDisplay: String
	let location: CoordinateWithFloor
	let gallery: AICGalleryModel
}
