//
//  AICEventModel.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import CoreLocation

struct AICEventModel {
	let eventId: String
	let title: String
	var shortDescription: String
	var longDescription: String

	let imageUrl: URL

	let locationText: String
	let startDate: Date
	let endDate: Date

	let eventUrl: URL?
	let buttonText: String
    var buttonCaption: String?
    let isTicketed: Bool
    let isSalesButtonHidden: Bool
    let onSaleDate: Date?
    let offSaleDate: Date?
}

extension AICEventModel: Hashable, Identifiable {
    var id: String { eventId }
}
