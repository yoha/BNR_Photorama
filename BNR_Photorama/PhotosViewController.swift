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
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Stored Properties
    
    var photoStore: PhotoStore!
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoStore.fetchRecentPhotos { (photosResult) -> Void in
//            switch photosResult {
//            case let PhotosResult.Success(photos):
//                print("Successfully found \(photos.count) recent photos.")
//            case let PhotosResult.Failure(error):
//                print("Error fetching recent photos: \(error)")
//            }
            if case let PhotosResult.Success(photos) = photosResult {
                print("Successfully found \(photos.count) recent photos.")
                
                if let firstPhoto = photos.first {
                    self.photoStore.fetchImageForPhoto(firstPhoto, completion: { (imageResult) -> Void in
                        if case let ImageResult.Success(image) = imageResult {
                            self.imageView.image = image
                        }
                        else if case let .Failure(error) = imageResult {
                            print("Error donwnloading image: \(error)")
                        }
                    })
                }
            }
            else if case let .Failure(error) = photosResult {
                print("Error fetching recent photos: \(error)")
            }
        }
    }
}
