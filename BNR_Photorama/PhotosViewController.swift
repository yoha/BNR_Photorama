//
//  PhotosViewController.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/12/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Stored Properties
    
    var photoStore: PhotoStore!
    var photoDataSource: PhotoDataSource!
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoDataSource = PhotoDataSource()
        
        self.photoStore.fetchRecentPhotos { (photosResult) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if case let PhotosResult.Success(photos) = photosResult {
                    print("Successfully found \(photos.count) recent photos")
                    self.photoDataSource.photos = photos
                }
                else if case let .Failure(error) = photosResult {
                    self.photoDataSource.photos.removeAll()
                    print("Error fetching recent photos: \(error)")
                }
                self.collectionView.reloadSections(NSIndexSet(index: 0))
            })
        }
        self.collectionView.dataSource = self.photoDataSource
    }
}
