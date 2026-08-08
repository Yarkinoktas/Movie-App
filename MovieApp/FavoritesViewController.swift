//
//  FavoritesViewController.swift
//  MovieApp
//
//  Created by Yarkın Oktaş on 8.08.2026.
//

import UIKit
import SDWebImage

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var favorites: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFavorites()
    }
    
    func loadFavorites() {
        
        guard let data = UserDefaults.standard.data(forKey: "FavoriteMovies") else {
            favorites = []
            tableView.reloadData()
            return
        }
        
        do {
            favorites = try JSONDecoder().decode(
                [Movie].self,
                from: data
            )
            
            tableView.reloadData()
            
        } catch {
            print("Favoriler yüklenemedi:", error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FavoriteToDetail",
           let detailVC = segue.destination as? MovieDetailViewController,
           let selectedMovie = sender as? Movie {
            
            detailVC.movie = selectedMovie
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        return favorites.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteCell",
            for: indexPath
        ) as! FavoriteTableViewCell
        
        let movie = favorites[indexPath.row]
        
        cell.titleImageLabel.text = movie.title
        
        cell.ratingLabel.text = String(
            format: "⭐ %.1f / 10",
            movie.voteAverage
        )
        
        cell.releaseDateLabel.text = "📅 \(movie.releaseDate)"
        
        if let posterPath = movie.posterPath {
            
            let url = URL(
                string: "https://image.tmdb.org/t/p/w185\(posterPath)"
            )
            
            cell.posterImageView.sd_setImage(with: url)
            
        } else {
            
            cell.posterImageView.image = UIImage(
                systemName: "film"
            )
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedMovie = favorites[indexPath.row]
        
        performSegue(withIdentifier: "FavoriteToDetail", sender: selectedMovie)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            favorites.remove(at: indexPath.row)
            
            do {
                let data = try JSONEncoder().encode(favorites)
                UserDefaults.standard.set(data, forKey: "FavoriteMovies")
            } catch {
                print("Favoriler kaydedilemedi:", error)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}

