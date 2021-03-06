//
//  PhotosViewController.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/12/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Stored Properties
    
    var photoStore: PhotoStore!
    var photoDataSource: PhotoDataSource!
    
    // MARK: - UICollectionView Data Source Methods
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let photoToBeDisplayed = self.photoDataSource.photos[indexPath.row]
        
        // Download the image data, which could take some time
        self.photoStore.fetchImageForPhoto(photoToBeDisplayed) { (imageResult) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                // The index path for the photo might have changed between the time the
                // request started and finished, so find the most recent index path
                let photoIndex = self.photoDataSource.photos.indexOf { $0 == photoToBeDisplayed }
                let photoIndexPath = NSIndexPath(forRow: photoIndex!, inSection: 0)
                
                // When the request finishes, only update the cell if it's still visible
                guard let validCell = self.collectionView.cellForItemAtIndexPath(photoIndexPath) as? PhotoCollectionViewCell else { return }
                validCell.updateWithImage(photoToBeDisplayed.image)
            })
        }
    }
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoDataSource = PhotoDataSource()
        
        self.photoStore.fetchRecentPhotos { (photosResult) -> Void in
            let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
            let allPhotos = try! self.photoStore.fetchMainQueuePhotos(predicate: nil, sortDescriptors: [sortByDateTaken])
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.photoDataSource.photos = allPhotos
                self.collectionView.reloadSections(NSIndexSet(index: 0))
            })
        }
        self.collectionView.dataSource = self.photoDataSource
        
        self.collectionView.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "ShowPhotoSegue" else { return }
        guard let validSelectedIndexPath = self.collectionView.indexPathsForSelectedItems()?.first else { return }
        guard let validDestinationViewController = segue.destinationViewController as? PhotoInfoViewController else { return }
        let selectedPhoto = self.photoDataSource.photos[validSelectedIndexPath.row]
        validDestinationViewController.photo = selectedPhoto
        validDestinationViewController.photoStore = self.photoStore
    }
}
