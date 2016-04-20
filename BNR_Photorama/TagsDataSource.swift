//
//  TagsDataSource.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/20/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import CoreData

class TagsDataSource: NSObject, UITableViewDataSource {
    
    // MARK: - Stored Properties
    
    var tags: [NSManagedObject] = []
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        let tag = self.tags[indexPath.row]
        let name = tag.valueForKey("name") as! String
        cell.textLabel!.text = name
        return cell
    }
}
