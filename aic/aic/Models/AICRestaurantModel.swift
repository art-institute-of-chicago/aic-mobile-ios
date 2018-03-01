//
//  AICRestaurantModel.swift
//  aic
//
//  Created by Filippo Vanucci on 3/1/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import Foundation

struct AICRestaurantModel {
	let nid: Int
	let title: String?
	let imageUrl: URL?
	let description: String?
	let location: CoordinateWithFloor
}
