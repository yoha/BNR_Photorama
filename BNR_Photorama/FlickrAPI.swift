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
    
    private static let baseURLString = "https://api.flickr.com/services/rest/?"
    private static let APIKey = "ac4c9d25dce464b5e775829d9f5ceec9"
    
    // MARK: - Local Methods
    
    private static func getFlickrURL(method method: Method, additionalParameters: [String: String]?) -> NSURL? {
        guard let validURLComponents = NSURLComponents(string: baseURLString) else { return nil }
        var queryItems = [NSURLQueryItem]()
        
        let baseParameters = [
            "method": method.rawValue,
            "api_key": APIKey,
            "format": "json",
            "nojsoncallback": "1"
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
