//
//  FlickrAPI.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/12/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import Foundation

enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

struct FlickrAPI {
    
    // MARK: - Stored Properties
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let APIKey = "a​6​d​8​1​9​4​9​9​1​3​1​0​7​1​f​1​5​8​f​d​7​4​0​8​6​0​a​5​a​8​8"
    
    // MARK: - Local Methods
    
    private static func getFlickrURL(method method: Method, additionalParameters: [String: String]?) -> NSURL? {
        guard let validURLComponents = NSURLComponents(string: baseURLString) else { return nil }
        var queryItems = [NSURLQueryItem]()
        
        let baseParameters = [
            "method": method.rawValue,
            "api_key": APIKey,
            "format": "json",
            "nojsoncallback": "1",
        ]
        for (key, value) in baseParameters {
            let baseParameterItem = NSURLQueryItem(name: key, value: value)
            queryItems.append(baseParameterItem)
        }
        
        guard let validAdditionalParameters = additionalParameters else { return nil }
        for (key, value) in validAdditionalParameters {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        validURLComponents.queryItems = queryItems
        return validURLComponents.URL ?? nil
    }
    
    static func getRecentPhotosURL() -> NSURL? {
        guard let validFlickrURL = self.getFlickrURL(method: Method.RecentPhotos, additionalParameters: ["extras": "url_h,date_taken"]) else { return nil }
        return validFlickrURL
    }
    
}
