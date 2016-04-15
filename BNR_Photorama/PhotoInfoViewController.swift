//
//  PhotoInfoViewController.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/15/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Stored Properties
    
    var photo: Photo! {
        didSet {
            self.navigationItem.title = photo.title
        }
    }
    
    var photoStore: PhotoStore!
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoStore.fetchImageForPhoto(self.photo) { (imageResult) -> Void in
            switch imageResult {
            case let ImageResult.Success(image):
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.imageView.image = image
                })
            case let ImageResult.Failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
}