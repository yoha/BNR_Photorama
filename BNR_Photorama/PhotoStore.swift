//
//  PhotoStore.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/12/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import CoreData

enum ImageResult {
    case Success(UIImage)
    case Failure(ErrorType)
}

enum PhotoError: ErrorType {
    case ImageCreationError
}

class PhotoStore {
    
    // MARK: - Stored Properties
    
    let coreDataStack = CoreDataStack(modelName: "Photorama")
    
    let urlSession: NSURLSession = {
        let defaultSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: defaultSessionConfiguration)
    }()
    
    let imageStore = ImageStore()
    
    // MARK: - local Methods
    
    func fetchRecentPhotos(completion completion: (PhotosResult) -> Void) {
        guard let validURL = FlickrAPI.getRecentPhotosURL() else { return }
        let urlRequest = NSURLRequest(URL: validURL)
        // transfer request to the server
        let URlSessionDataTask = self.urlSession.dataTaskWithRequest(urlRequest) { (data, urlResponse, error) -> Void in
            if let responseHeader = urlResponse as? NSHTTPURLResponse {
                print("HTTP URL Response Status Code: \(responseHeader.statusCode)")
                for (key, value) in responseHeader.allHeaderFields {
                    print("\(key): \(value)")
                }
            }
            var result = self.processRecentPhotosRequest(data: data, error: error)
            if case let .Success(photos) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performBlockAndWait({
                    do {
                        try privateQueueContext.obtainPermanentIDsForObjects(photos)
                    }
                    catch let error {
                        print("Something went sount: \(error)")
                    }
                })
                let objectIDs = photos.map { $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
                
                do {
                    try self.coreDataStack.saveChanges()
                    let mainQueuePhotos = try self.fetchMainQueuePhotos(predicate: predicate, sortDescriptors: [sortByDateTaken])
                    result = .Success(mainQueuePhotos)
                }
                catch let error { result = .Failure(error) }
            }
            completion(result)
        }
        URlSessionDataTask.resume()
    }
    
    func fetchImageForPhoto(photo: Photo, completion: (ImageResult) -> Void) {
        let photoKey = photo.photoKey
        if let image = imageStore.getImageForKey(photoKey) {
            photo.image = image
            completion(.Success(image))
            return
        }
        
        let photoURL = photo.remoteURL
        let URLRequest = NSURLRequest(URL: photoURL)
        
        let URLSessionDataTask = self.urlSession.dataTaskWithRequest(URLRequest) { (data, urlResponse, error) -> Void in
            let result = self.processImageRequest(data: data, error: error)
            if case let .Success(image) = result {
                photo.image = image
                self.imageStore.setImage(image, forKey: photoKey)
            }
            completion(result)
        }
        URLSessionDataTask.resume()
    }
    
    func processRecentPhotosRequest(data data: NSData?, error: NSError?) -> PhotosResult {
        guard let validJSONData = data else {
            return PhotosResult.Failure(error!)
        }
        return FlickrAPI.getPhotosFromJSONData(validJSONData, inContext: self.coreDataStack.privateQueueContext)
    }
    
    func processImageRequest(data data: NSData?, error: NSError?) -> ImageResult {
        guard let
            imageData = data,
            image = UIImage(data: imageData) else {
                return data == nil ? ImageResult.Failure(error!) : .Failure(PhotoError.ImageCreationError)
        }
        return .Success(image)
    }
    
    func fetchMainQueuePhotos(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Photo] {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueuePhotos: [Photo]?
        var fetchRequestError: ErrorType?
        mainQueueContext.performBlockAndWait { 
            do {
                mainQueuePhotos = try mainQueueContext.executeFetchRequest(fetchRequest) as? [Photo]
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        guard let validPhotos = mainQueuePhotos else {
            throw fetchRequestError!
        }
        
        return validPhotos
    }
    
    func fetchMainQueueTags(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueTags: [NSManagedObject]?
        var fetchRequestError: ErrorType?
        mainQueueContext.performBlockAndWait {
            do {
                mainQueueTags = try mainQueueContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        guard let validTags = mainQueueTags else {
            throw fetchRequestError!
        }
        
        return validTags
    }
}