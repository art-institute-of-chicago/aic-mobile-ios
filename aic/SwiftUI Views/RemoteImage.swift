//
//  RemoteImage.swift
//  aic
//
//  Created by David Bireta on 2/20/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import SwiftUI

/// An alternative to `AsyncImage` that allows control over the caching mechanism.
struct RemoteImage: View {
    private enum LoadingState {
        case loading, success, failure
    }
    
    private let loadingImage = Image(systemName: "picture")
    
    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadingState.loading
        
        private let logoCacheURL = URL.documentsDirectory.appending(path: "images")
        
        init(id: String, url: String) {
            try? FileManager.default.createDirectory(at: logoCacheURL, withIntermediateDirectories: true)
            
            guard let urlString = URL(string: url) else {
                return
            }
            
            let docURL = logoCacheURL.appending(path: id+".jpg")
            
            if let cachedData = try? Data(contentsOf: docURL) {
                self.data = cachedData
                self.state = .success
                return
            }
            
            URLSession.shared.dataTask(with: urlString) { data, response, error in
                DispatchQueue.main.async {
                    if let data, data.count > 0, error == nil {
                        self.data = data
                        self.state = .success
                        
                        try? data.write(to: docURL)
                    } else {
                        self.state = .failure
                    }
                    
                    self.objectWillChange.send()
                }
            }
            .resume()
        }
    }
    
    @StateObject private var loader: Loader
    
    let imageID: String
    let imageURL: URL?
    let height: Double
    
    init(imageID: String, imageURL: URL?, height: Double = 240.0) {
        _loader = StateObject(wrappedValue: Loader(id: imageID, url: imageURL?.absoluteString ?? ""))
        self.imageID = imageID
        self.imageURL = imageURL
        self.height = height
    }
    
    var body: some View {
        Rectangle()
            .fill(.background)
            .frame(height: height)
            .overlay {
                switch loader.state {
                    case .loading:
                        Rectangle()
                            .fill(.gray.gradient)
                            .frame(height: height)
                    case .success:
                        image()
                            .resizable()
                            .scaledToFill()
                            .border(.gray.opacity(0.25))
                    case .failure:
                        Rectangle()
                            .fill(.red.gradient)
                            .frame(height: height)
                        
                }
            }
            .clipped()
    }
    
    private func image() -> Image {
        if let image = UIImage(data: loader.data) {
            return Image(uiImage: image)
        } else {
            return Image(systemName: "x.circle")
        }
    }
}
