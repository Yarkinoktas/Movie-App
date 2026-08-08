//
//  CastCollectionViewCell.swift
//  MovieApp
//
//  Created by Yarkın Oktaş on 8.08.2026.
//

import UIKit
import SDWebImage

class CastCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var characterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 12
        profileImageView.clipsToBounds = true
        
        nameLabel.numberOfLines = 2
        characterLabel.numberOfLines = 2
        
        characterLabel.textColor = .secondaryLabel
    }
}
