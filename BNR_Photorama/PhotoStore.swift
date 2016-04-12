//
//  PhotoStore.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/12/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import Foundation

class PhotoStore {
    
    // MARK: - Stored Properties
    
    let urlSession: NSURLSession = {
        let defaultSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: defaultSessionConfiguration)
    }()
    
    // MARK: - local Methods
    
    func fetchRecentPhotos() {
        guard let validURL = FlickrAPI.getRecentPhotosURL() else { return }
        print(validURL)
        let urlRequest = NSURLRequest(URL: validURL)
        // transfer request to the server
        let urlSessionDataTask = self.urlSession.dataTaskWithRequest(urlRequest) { (data, urlResponse, error) -> Void in
            guard let jsonData = data else {
                guard let requestError = error else {
                    return print("Unexpected error with the request")
                }
                return print("Error fetching recent photos: \(requestError)")
            }
            guard let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) else { return }
            print(jsonString)
        }
        urlSessionDataTask.resume()
    }
}