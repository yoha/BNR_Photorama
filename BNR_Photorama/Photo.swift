//
//  Photo.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/18/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import CoreData


class Photo: NSManagedObject {
    
    // MARK: - Stored Properties
    
    var image: UIImage?
    
    // MARK: - NSManagedObject Methods
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Give the properties their initial values
        self.title = ""
        self.photoID = ""
        self.remoteURL = NSURL()
        self.photoKey = NSUUID().UUIDString
        self.dateTaken = NSDate()
    }
    
    // MARK: - Local Methods
    
    func addTagObject(tag: NSManagedObject) {
        let currentTags = self.mutableSetValueForKey("tags")
        currentTags.addObject(tag)
    }
    
    func removeTagObject(tag: NSManagedObject) {
        let currentTags = self.mutableSetValueForKey("tags")
        currentTags.removeObject(tag)
    }
}
