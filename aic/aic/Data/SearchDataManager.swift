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
	func searchDataDidFinishLoading(searchedArtworks: [AICSearchedArtworkModel])
	func searchDataDidFinishLoading(tours: [AICTourModel])
	func searchDataDidFinishLoading(exhibitions: [AICExhibitionModel])
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
		url += "?q=" + searchText + "&resources=artworks,tours,exhibitions"
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
	
	@objc func loadArtworks(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.artworksEndpoint]!
		url += "/search?limit=99"
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let urlRequest = URLRequest(url:  URL(string: url)!)
		let urlString = urlRequest.url?.absoluteString
		let parameters: [String: Any] = [
			"fields": [
				"id",
				"is_on_view",
				"title",
				"artist_display",
				"image_iiif_url",
				"gallery_id",
				"latlon"
			],
			"sort": ["_score"],
			"query": [
				"bool": [
					"must": [
						[
							"multi_match": [
								"query": searchText,
								"fields": ["title", "artist_display"],
								"operator": "or"
							]
						],
						[
							"term": [
								"is_on_view": "true"
							]
						]
					]
				]
			]
		]
		
		if let previousRequest = artworksRequest {
			previousRequest.cancel()
		}
		
		artworksRequest = Alamofire.request(urlString!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					let searchedArtworks = self.dataParser.parse(searchedArtworksData: value)
					self.delegate?.searchDataDidFinishLoading(searchedArtworks: searchedArtworks)
				case .failure(let error):
					self.delegate?.searchDataFailure(filter: .artworks)
					print(error)
				}
		}
	}
	
	@objc func loadTours(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.toursEndpoint]!
		url += "/search?q=" + searchText + "&limit=99&fields=id"
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let request = URLRequest(url: URL(string: url)!)
		
		if let previousRequest = toursRequest {
			previousRequest.cancel()
		}
		
		toursRequest = Alamofire.request(request as URLRequestConvertible)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					var tours = [AICTourModel]()
					let searchedTours = self.dataParser.parse(searchedToursData: value)
					for tourId in searchedTours {
						if let tour = AppDataManager.sharedInstance.getTour(forID: tourId) {
							tours.append(tour)
						}
					}
					self.delegate?.searchDataDidFinishLoading(tours: tours)
				case .failure(let error):
					self.delegate?.searchDataFailure(filter: .tours)
					print(error)
				}
		}
	}
	
	@objc func loadExhibitions(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.exhibitionsEndpoint]!
		url += "/search?limit=99"
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let urlRequest = URLRequest(url:  URL(string: url)!)
		let urlString = urlRequest.url?.absoluteString
		let parameters: [String: Any] = [
			"fields": [
				"id",
				"title",
				"short_description",
				"legacy_image_mobile",
				"legacy_image_desktop",
				"gallery_id",
				"web_url",
				"start_at",
				"end_at"
			],
			"sort": ["_score"],
			"query": [
				"bool": [
					"must": [
						[
							"range": [
								"aic_start_at": [
									"lte": "now+1y"
								]
							]
						],
						[
							"range": [
								"aic_end_at": [
									"gte": "now"
								]
							]
						],
						[
							"match": [
								"title": [
									"query": searchText,
									"operator": "or"
								]
							]
						]
					]
				]
			]
		]
		
		if let previousRequest = exhibitionsRequest {
			previousRequest.cancel()
		}
		
		exhibitionsRequest = Alamofire.request(urlString!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					var exhibitions = [AICExhibitionModel]()
					let searchedExhibitions = self.dataParser.parse(exhibitionsData: value)
					// Assign imageUrl to search exhibition, if it already exists in the current exhibitions
					for searchedExhibition in searchedExhibitions {
						if let currentExhibition = AppDataManager.sharedInstance.exhibitions.filter({ $0.id == searchedExhibition.id }).first {
							exhibitions.append(currentExhibition)
						}
						else {
							exhibitions.append(searchedExhibition)
						}
					}
					self.delegate?.searchDataDidFinishLoading(exhibitions: exhibitions)
				case .failure(let error):
					self.delegate?.searchDataFailure(filter: .exhibitions)
					print(error)
				}
		}
	}
}
