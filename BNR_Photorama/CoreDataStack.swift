//
//  CoreDataStack.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/18/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // MARK: - Stored Properties
    
    let managedObjectModelName: String
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.managedObjectModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private var applicationDocumentsDirectory: NSURL = {
        let URLs = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        return URLs.first!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let pathComponent = "\(self.managedObjectModelName).sqlite"
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(pathComponent)
        do {
            let store = try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        }
        catch let error {
            print("Something went awry: \(error)")
        }
        return coordinator
    }()
    
    lazy var mainQueueContext: NSManagedObjectContext = {
       let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        managedObjectContext.name = "Main Queue Context (UI Context)"
        return managedObjectContext
    }()
    
    // MARK: - Designated Initializer
    
    required init(modelName: String) {
        self.managedObjectModelName = modelName
    }
    
    // MARK: - Local Methods
    
    func saveChanges() throws {
        var error: ErrorType?
        mainQueueContext.performBlockAndWait {
            if self.mainQueueContext.hasChanges {
                do { try self.mainQueueContext.save() }
                catch let saveError { error = saveError }
            }
        }
        if let error = error {
            throw error
        }
    }
}
