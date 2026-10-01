//
//  URL+AIC.swift
//  aic
//
//  Created by David Bireta on 4/30/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import Foundation

extension URL {
    
    /// Replaces the value of query parameters.
    /// - Parameters:
    ///   - key: The name of the query paramter to update
    ///   - value: The new value of the query paramter
    /// - Returns: A `URL` with the query parameter updated, if it exists. Else it returns the original URL.
    func updatingQueryItem(key: String, value: String) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        
        if let index = components.queryItems?.firstIndex(where: { $0.name == key }) {
            components.queryItems?[index] = URLQueryItem(name: key, value: value)
        }
        
        return components.url ?? self
    }
}
