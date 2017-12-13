//
//  AICEventModel.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import CoreLocation

struct AICEventModel {
	let title:String
	let shortDescription:String
	let longDescription:String
	
	let imageUrl:URL
	
	let startDate: Date
	let endDate: Date
}
