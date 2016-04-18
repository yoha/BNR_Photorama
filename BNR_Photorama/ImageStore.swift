//
//  ImageStore.swift
//  BNR_Homepwner
//
//  Created by Yohannes Wijaya on 3/29/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class ImageStore {
    
    // MARK: - Stored Properties
    
    let cache = NSCache()
    
    // MARK: - Local Methods
    
    func setImage(image: UIImage, forKey key: String) {
        self.cache.setObject(image, forKey: key)
        
        let imageURL = self.getImageURLForKey(key)
        guard let validImageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        validImageData.writeToURL(imageURL, atomically: true)
    }
    
    func getImageForKey(key: String) -> UIImage? {
        if let validCacheImage = self.cache.objectForKey(key) as? UIImage {
            return validCacheImage
        }
        
        let imageURL = self.getImageURLForKey(key)
        guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) else { return nil }
        self.cache.setObject(imageFromDisk, forKey: key)
        return imageFromDisk
    }
    
    func getImageURLForKey(key: String) -> NSURL {
        let documentDirectory = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        return documentDirectory.URLByAppendingPathComponent(key)
    }
    
    func deleteImageForKey(key: String) {
        self.cache.removeObjectForKey(key)
        
        let imageURL = self.getImageURLForKey(key)
        do {
            try NSFileManager.defaultManager().removeItemAtURL(imageURL)
        }
        catch {
            print("The following error has occured: \(error)")
        }
    }
}


