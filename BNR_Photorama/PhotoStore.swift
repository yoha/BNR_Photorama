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
    
    func fetchRecentPhotos(completion completion: (PhotosResult) -> Void) {
        guard let validURL = FlickrAPI.getRecentPhotosURL() else { return }
        let urlRequest = NSURLRequest(URL: validURL)
        // transfer request to the server
        let urlSessionDataTask = self.urlSession.dataTaskWithRequest(urlRequest) { (data, urlResponse, error) -> Void in
            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
        }
        urlSessionDataTask.resume()
    }
    
    func processRecentPhotosRequest(data data: NSData?, error: NSError?) -> PhotosResult {
        guard let validJSONData = data else {
            return PhotosResult.Failure(error!)
        }
        return FlickrAPI.getPhotosFromJSONData(validJSONData)
    }
}