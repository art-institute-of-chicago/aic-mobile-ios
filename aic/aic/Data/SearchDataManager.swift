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
	func searchDataDidFinishLoading(artworks: [AICObjectModel])
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
		url += "/search?q=" + searchText + "&limit=99"
		url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		let request = URLRequest(url: URL(string: url)!)
		
		Alamofire.request(request as URLRequestConvertible)
			.validate()
			.responseData { response in
				switch response.result {
				case .success(let value):
					var artworks = [AICObjectModel]()
					let searchedArtworks = self.dataParser.parse(searchedArtworksData: value)
					for searchedArtwork in searchedArtworks {
						if let object = AppDataManager.sharedInstance.getObject(forObjectID: searchedArtwork.objectId) {
							artworks.append(object)
						}
					}
					self.delegate?.searchDataDidFinishLoading(artworks: artworks)
				case .failure(let error):
					//self.notifyLoadFailure(withMessage: "Failed to load search data.")
					print(error)
				}
		}
	}
	
	func loadTours(searchText: String) {
		var url = AppDataManager.sharedInstance.app.dataSettings[.dataApiUrl]!
		url += AppDataManager.sharedInstance.app.dataSettings[.toursEndpoint]!
		url += "/search?q=" + searchText + "&limit=99"
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
}
