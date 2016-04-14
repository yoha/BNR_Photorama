//
//  PhotoDataSource.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/14/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    // MARK: - Stored Properties
    
    var photos = [Photo]()
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = "UICollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        let photoToBeDisplayedOnCell = photos[indexPath.row]
        cell.updateWithImage(photoToBeDisplayedOnCell.image)
        return cell
    }
}
