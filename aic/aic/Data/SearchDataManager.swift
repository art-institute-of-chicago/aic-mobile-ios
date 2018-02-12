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
	func searchDataFailure(withMessage: String)
}

class SearchDataManager {
	static let sharedInstance = SearchDataManager()
	
	weak var delegate: SearchDataManagerDelegate? = nil
	
	private let dataParser = AppDataParser()
	
	private var loadFailure: Bool = false
	
	func loadAutocompleteStrings(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.autocompleteEndpoint]!
		url += "?q=" + searchText
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let request = URLRequest(url: URL(string: url)!)
		
		Alamofire.request(request as URLRequestConvertible)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					let autocompleteStrings = self.dataParser.parse(autocompleteData: value)
					self.delegate?.searchDataDidFinishLoading(autocompleteStrings: autocompleteStrings)
				case .failure(let error):
					//self.notifyLoadFailure(withMessage: "Failed to load autocomplete search data.")
					print(error)
				}
		}
	}
	
	func loadArtworks(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.artworksEndpoint]!
		url += "/search?limit=20"
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let urlRequest = URLRequest(url:  URL(string: url)!)
		let urlString = urlRequest.url?.absoluteString
		let parameters: [String: Any] = [
			"_source": true,
			"sort": ["_score"],
			"query": [
				"bool": [
					"must": [
						[
							"match": [
								"title": [
									"query": searchText,
									"operator": "or"
								]
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
		
		Alamofire.request(urlString!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					let searchedArtworks = self.dataParser.parse(searchedArtworksData: value)
					self.delegate?.searchDataDidFinishLoading(searchedArtworks: searchedArtworks)
				case .failure(let error):
					//self.notifyLoadFailure(withMessage: "Failed to load search data.")
					print(error)
				}
		}
	}
	
	func loadTours(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.toursEndpoint]!
		url += "/search?q=" + searchText + "&limit=20"
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let request = URLRequest(url: URL(string: url)!)
		
		Alamofire.request(request as URLRequestConvertible)
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
					//self.notifyLoadFailure(withMessage: "Failed to load search data.")
					print(error)
				}
		}
	}
	
	func loadExhibitions(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.exhibitionsEndpoint]!
		url += "/search?limit=20"
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let urlRequest = URLRequest(url:  URL(string: url)!)
		let urlString = urlRequest.url?.absoluteString
		let parameters: [String: Any] = [
			"_source": true,
			"sort": ["_score"],
			"query": [
				"bool": [
					"must": [
						[
							"range": [
								"aic_start_at": [
									"gte": "now-10y",
									"lte": "now+10y"
								]
							]
						],
						[
							"range": [
								"aic_end_at": [
									"gte": "now-10y",
									"lte": "now+10y"
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
		
		Alamofire.request(urlString!, method: .post, parameters: parameters, encoding: JSONEncoding.default)
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
					//self.notifyLoadFailure(withMessage: "Failed to load search data.")
					print(error)
				}
		}
	}
}
