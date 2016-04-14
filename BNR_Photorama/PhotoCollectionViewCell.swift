//
//  PhotoCollectionViewCell.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/14/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - NSObject Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateWithImage(nil)
    }
    
    // MARK:- UICollectionReusableView Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.updateWithImage(nil)
    }
    
    // Helper Methods
    
    func updateWithImage(image: UIImage?) {
        guard let validImageToDisplay = image else {
            self.activityIndicatorView.startAnimating()
            self.imageView.image = nil
            return
        }
        self.activityIndicatorView.stopAnimating()
        self.imageView.image = validImageToDisplay
    }
}