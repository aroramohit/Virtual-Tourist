//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Mohit Arora on 15/02/18.
//  Copyright © 2018 soprateria. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var placeImage: UIImageView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func reloadCellWithImage(imageFetched:UIImage){
        
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        placeImage.contentMode = .scaleToFill
        placeImage.image = imageFetched
    }
    
    func reloadCellWithPlaceHolder() {
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        placeImage.contentMode = .scaleToFill
        placeImage.image = UIImage.init(named: "placeholder.png")

    }

}
