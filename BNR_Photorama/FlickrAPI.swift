//
//  FlickrAPI.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/12/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import Foundation
import CoreData

enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

enum PhotosResult {
    case Success([Photo])
    case Failure(ErrorType)
}

enum FlickrError: ErrorType {
    case InvalidJSONData
}

struct FlickrAPI {
    
    // MARK: - Stored Properties
    
    private static let baseURLString = "https://api.flickr.com/services/rest/?"
    private static let APIKey = "ac4c9d25dce464b5e775829d9f5ceec9"
    private static let dateFormatter: NSDateFormatter = {
       let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
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
    
    private static func getPhotosFromJSONObject(json: [String: AnyObject], inContext context: NSManagedObjectContext) -> Photo? {
        guard let
            title = json["title"] as? String,
            photoID = json["id"] as? String,
            date = json["datetaken"] as? String,
            photoURL = json["url_h"] as? String,
            url = NSURL(string: photoURL),
            dateTaken = self.dateFormatter.dateFromString(date) else {
                
                // Don't have enough info to construct a photo
                return nil
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        let predicate = NSPredicate(format: "photoID == \(photoID)")
        fetchRequest.predicate = predicate
        
        var fetchedPhotos: [Photo]!
        context.performBlockAndWait { 
            fetchedPhotos = try! context.executeFetchRequest(fetchRequest) as! [Photo]
        }
        if fetchedPhotos.count > 0 {
            return fetchedPhotos.first
        }
        
        var photo: Photo!
        context.performBlockAndWait {
            photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as! Photo
            photo.title = title
            photo.photoID = photoID
            photo.remoteURL = url
            photo.dateTaken = dateTaken
        }
        return photo
    }
    
    static func getRecentPhotosURL() -> NSURL? {
        guard let validFlickrURL = self.getFlickrURL(method: Method.RecentPhotos, additionalParameters: ["extras": "url_h,date_taken"]) else { return nil }
        return validFlickrURL
    }
    
    static func getPhotosFromJSONData(data: NSData, inContext context: NSManagedObjectContext) -> PhotosResult {
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let
                validJSONDictionary = jsonObject as? [NSObject: AnyObject],
                validPhotosDictionary = validJSONDictionary["photos"] as? [String: AnyObject],
                validPhotosArray = validPhotosDictionary["photo"] as? [[String: AnyObject]] else {
                    
                    // The JSON struct doesn't match our expectations
                    return PhotosResult.Failure(FlickrError.InvalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            for photoJSON in validPhotosArray {
                if let validPhoto = self.getPhotosFromJSONObject(photoJSON, inContext: context) {
                    finalPhotos.append(validPhoto)
                }
            }
            
            if finalPhotos.count == 0 && validPhotosArray.count > 0 {
                
                // We weren't able to parse any of the photos. Maybe the JSON format for photos has changed
                return .Failure(FlickrError.InvalidJSONData)
            }
            
            return PhotosResult.Success(finalPhotos)
        }
        catch let error {
            return .Failure(error)
        }
    }
    
}
