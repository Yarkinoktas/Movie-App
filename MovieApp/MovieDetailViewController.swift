//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by Yarkın Oktaş on 31.07.2026.
//

import UIKit
import SDWebImage

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var castCollectionView: UICollectionView!
    
    var movie: Movie?
    var cast: [APIManager.CastMember] = []
    var userRating: Int = 0
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            castCollectionView.delegate = self
            castCollectionView.dataSource = self
            
            if let layout = castCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.itemSize = CGSize(width: 115, height: 180)
                layout.minimumLineSpacing = 12
                layout.minimumInteritemSpacing = 0
            }
            
            guard let movie = movie else { return }
            
            userRating = UserDefaults.standard.integer(
                forKey: "UserRating_\(movie.id)"
            )

            updateRatingButtons()
            
            titleLabel.text = movie.title
            
            ratingLabel.text = String(format: "⭐ %.1f / 10", movie.voteAverage)
            
            releaseDateLabel.text = movie.releaseDate
            
            overviewTextView.text = movie.overview
            
            if let posterPath = movie.posterPath {
                
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
                
                posterImageView.sd_setImage(with: url)
            }
            
            APIManager().fetchMovieDetails(movieID: movie.id) { details in
                
                guard let details = details else { return }
                
                let genres = details.genres
                    .map { $0.name }
                    .joined(separator: " • ")
                
                self.genreLabel.text = "🎬 \(genres)"
                
                if let runtime = details.runtime {
                    
                    let hours = runtime / 60
                    let minutes = runtime % 60
                    
                    if hours > 0 {
                        self.runtimeLabel.text = "⏱️ \(hours)s \(minutes)dk"
                    } else {
                        self.runtimeLabel.text = "⏱️ \(minutes)dk"
                    }
                    
                } else {
                    self.runtimeLabel.text = "⏱️ Süre bilinmiyor"
                }
            }
            
            APIManager().fetchCast(movieID: movie.id) { cast in
                
                print("CAST SAYISI:", cast.count)
                
                self.cast = Array(cast.prefix(10))
                
                print("KAYDEDİLEN CAST:", self.cast.count)
                
                self.castCollectionView.reloadData()
            }
            
            updateFavoriteButton()
        }
        
        func updateFavoriteButton() {
            
            if isFavorite() {
                favoriteButton.setTitle("❤️ Remove", for: .normal)
            } else {
                favoriteButton.setTitle("♡ Favorite", for: .normal)
            }
        }
        
        @IBAction func favoriteButtonTapped(_ sender: UIButton) {
            
            guard let movie = movie else { return }
            
            userRating = UserDefaults.standard.integer(
                forKey: "UserRating_\(movie.id)"
            )

            updateRatingButtons()
            
            var favorites = getFavorites()
            
            if let index = favorites.firstIndex(where: { $0.title == movie.title }) {
                
                favorites.remove(at: index)
                
            } else {
                
                favorites.append(movie)
            }
            
            saveFavorites(favorites)
            
            updateFavoriteButton()
        }
    
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        
        guard let movie = movie else { return }
        
        userRating = sender.tag
        
        UserDefaults.standard.set(
            userRating,
            forKey: "UserRating_\(movie.id)"
        )
        
        print("Kaydedilen puan: \(userRating)")
        
        updateRatingButtons()
    }
    
    func updateRatingButtons() {
        
        for tag in 1...10 {
            
            if let button = view.viewWithTag(tag) as? UIButton {
                
                if tag <= userRating {
                    button.setTitle("★", for: .normal)
                } else {
                    button.setTitle("☆", for: .normal)
                }
            }
        }
    }
    
        func getFavorites() -> [Movie] {
            
            guard let data = UserDefaults.standard.data(forKey: "FavoriteMovies") else {
                return []
            }
            
            do {
                return try JSONDecoder().decode([Movie].self, from: data)
            } catch {
                print("Favoriler okunamadı:", error)
                return []
            }
        }
        
        func saveFavorites(_ favorites: [Movie]) {
            
            do {
                
                let data = try JSONEncoder().encode(favorites)
                
                UserDefaults.standard.set(data, forKey: "FavoriteMovies")
                
            } catch {
                
                print("Favoriler kaydedilemedi:", error)
            }
        }
        
        func isFavorite() -> Bool {
            
            guard let movie = movie else {
                return false
            }
            
            let favorites = getFavorites()
            
            return favorites.contains {
                $0.title == movie.title
            }
        }
    }

extension MovieDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        return cast.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CastCell",
            for: indexPath
        ) as! CastCollectionViewCell
        
        let actor = cast[indexPath.item]
        
        cell.nameLabel.text = actor.name
        cell.characterLabel.text = actor.character
        
        if let profilePath = actor.profilePath {
            
            let url = URL(
                string: "https://image.tmdb.org/t/p/w185\(profilePath)"
            )
            
            cell.profileImageView.sd_setImage(with: url)
            
        } else {
            
            cell.profileImageView.image = UIImage(
                systemName: "person.circle"
            )
        }
        
        return cell
    }
}
