//
//  TourCategoryModel.swift
//  aic
//
//  Created by Filippo Vanucci on 3/14/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import Foundation

class AICTourCategoryModel: NSObject {
	let id: String
	let title: [Common.Language: String]

	init(id: String, title: [Common.Language: String]) {
		self.id = id
		self.title = title
	}
}
