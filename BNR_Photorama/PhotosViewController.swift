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
        
        self.photoStore.fetchRecentPhotos()
    }
}
