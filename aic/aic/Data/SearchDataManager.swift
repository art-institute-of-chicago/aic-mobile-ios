//
//  SearchDataManager.swift
//  aic
//
//  Created by Filippo Vanucci on 12/9/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Alamofire

protocol SearchDataManagerDelegate : class {
	func searchDataDidFinishLoading(autocompleteStrings: [String])
	func searchDataDidFinishLoading(artworks: [AICSearchedArtworkModel], tours: [AICTourModel], exhibitions: [AICExhibitionModel])
	func searchDataFailure(filter: Common.Search.Filter)
}

class SearchDataManager : NSObject {
	static let sharedInstance = SearchDataManager()
	
	weak var delegate: SearchDataManagerDelegate? = nil
	
	private let dataParser = AppDataParser()
	
	private var loadFailure: Bool = false
	
	private var autocompleteRequest: DataRequest? = nil
	private var toursRequest: DataRequest? = nil
	private var artworksRequest: DataRequest? = nil
	private var exhibitionsRequest: DataRequest? = nil
	
	@objc func loadAutocompleteStrings(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.autocompleteEndpoint]!
		url += "?q=" + searchText + "&resources=artworks,tours,exhibitions,artists"
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let request = URLRequest(url: URL(string: url)!)
		
		if let previousRequest = autocompleteRequest {
			previousRequest.cancel()
		}
		
		autocompleteRequest = Alamofire.request(request as URLRequestConvertible)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					let autocompleteStrings = self.dataParser.parse(autocompleteData: value)
					self.delegate?.searchDataDidFinishLoading(autocompleteStrings: autocompleteStrings)
				case .failure(let error):
					print(error)
				}
		}
	}
	
	@objc func loadAllContent(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.multiSearchEndpoint]!
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		var urlRequest = URLRequest(url:  URL(string: url)!)
		
		let artworksQuery: [String: Any] = [
			"resources": "artworks",
			"from": 0,
			"size": 99,
			"fields": [
				"id",
				"is_on_view",
				"title",
				"artist_display",
				"image_id",
				"gallery_id",
				"latlon"
			],
			"q": searchText,
			"query": [
				"term": [
					"is_on_view": "true"
				]
			]
		]
		
		let toursQuery: [String: Any] = [
			"resources": "tours",
			"from": 0,
			"size": 99,
			"fields": [
				"id"
			],
			"q": searchText
		]
		
		let exhibitionsQuery: [String: Any] = [
			"resources": "exhibitions",
			"from": 0,
			"size": 99,
			"fields": [
				"id",
				"title",
				"short_description",
				"legacy_image_mobile_url",
				"legacy_image_desktop_url",
				"gallery_id",
				"web_url",
				"aic_start_at",
				"aic_end_at"
			],
			"q": searchText,
			"query": [
				"bool": [
					"must": [
						[
							"range": [
								"aic_start_at": [
									"lte": "now"
								]
							]
						],
						[
							"range": [
								"aic_end_at": [
									"gte": "now"
								]
							]
						]
					]
				]
			]
		]
		
		let parameters: [[String : Any]] = [
			artworksQuery,
			toursQuery,
			exhibitionsQuery
		]
		
		if let previousRequest = artworksRequest {
			previousRequest.cancel()
		}
		
		urlRequest.httpMethod = "POST"
		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
		
		artworksRequest = Alamofire.request(urlRequest)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					
					// get results as dictionary of [contentType : Any]
					let results = self.dataParser.parse(searchContent: value)
					
					// type cast results into the correspondent AIC data model
					var artworks: [AICSearchedArtworkModel] = []
					if let items = results[.artworks] {
						for item in items {
							if let artwork = item as? AICSearchedArtworkModel {
								artworks.append(artwork)
							}
						}
					}
					var tours: [AICTourModel] = []
					if let items = results[.tours] {
						for item in items {
							if let tour = item as? AICTourModel {
								tours.append(tour)
							}
						}
					}
					var exhibitions: [AICExhibitionModel] = []
					if let items = results[.exhibitions] {
						for item in items {
							if let exhibition = item as? AICExhibitionModel {
								exhibitions.append(exhibition)
							}
						}
					}
					
					self.delegate?.searchDataDidFinishLoading(artworks: artworks, tours: tours, exhibitions: exhibitions)
					
				case .failure(let error):
					self.delegate?.searchDataFailure(filter: .artworks)
					print(error)
				}
		}
	}
}
