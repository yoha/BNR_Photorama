//
//  TagsViewController.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/20/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import CoreData

class TagsViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
    var photoStore: PhotoStore!
    var photo: Photo!
    var selectedIndexPaths: [NSIndexPath]!
    var tagDataSource: TagsDataSource!
    
    // MARK: - IBAction Methods
    
    @IBAction func doneButtonDidTouch(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addTagButtonDidTouch(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Tag", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "tag name"
            textField.autocapitalizationType = .Words
        }
        let okAction = UIAlertAction(title: "OK", style: .Default) { (alertAction) in
            if let validTagName = alertController.textFields?.first!.text {
                let context = self.photoStore.coreDataStack.mainQueueContext
                let newTag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: context)
                newTag.setValue(validTagName, forKey: "name")
                do {
                    try self.photoStore.coreDataStack.saveChanges()
                }
                catch let error {
                    print("Core Data save failed: \(error)")
                }
                self.updateTags()
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            }
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndexPaths = [NSIndexPath]()
        self.tagDataSource = TagsDataSource()
    
        self.tableView.dataSource = self.tagDataSource
        self.tableView.delegate = self
        
        self.updateTags()
    }
    
    // MARK: - UITableView Delegate Methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tag = self.tagDataSource.tags[indexPath.row]
        if let validIndex = self.selectedIndexPaths.indexOf(indexPath) {
            self.selectedIndexPaths.removeAtIndex(validIndex)
            self.photo.removeTagObject(tag)
        }
        else {
            self.selectedIndexPaths.append(indexPath)
            self.photo.addTagObject(tag)
        }
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
        do {
            try self.photoStore.coreDataStack.saveChanges()
        }
        catch let error {
            print("Core data save failed: \(error)")
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.accessoryType = self.selectedIndexPaths.indexOf(indexPath) != nil ? .Checkmark : .None
    }
    
    // MARK: - Local Methods
    
    private func updateTags() {
        do {
            let tags = try self.photoStore.fetchMainQueueTags(predicate: nil, sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
            self.tagDataSource.tags = tags
        }
        catch let error {
            print("Something went shit: \(error)")
        }
        
        for tag in self.photo.tags {
            if let validIndex = self.tagDataSource.tags.indexOf(tag) {
                let indexPath = NSIndexPath(forRow: validIndex, inSection: 0)
                selectedIndexPaths.append(indexPath)
            }
        }
    }
    
}
