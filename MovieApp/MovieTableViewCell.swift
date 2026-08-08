//
//  MovieTableViewCell.swift
//  MovieApp
//
//  Created by Yarkın Oktaş on 31.07.2026.
//

import UIKit
import SDWebImage

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        posterImageView.layer.cornerRadius = 8
        posterImageView.clipsToBounds = true
    }
    
}
