//
//  ViewController.swift
//  MovieApp
//
//  Created by Yarkın Oktaş on 31.07.2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [Movie] = []
    var filteredMovies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        APIManager().fetchMovies { movies in
            self.movies = movies
            self.filteredMovies = movies
            self.tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieDetail"{
            if let destination = segue.destination as? MovieDetailViewController,
               let movie = sender as? Movie {
                destination.movie = movie
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let movie = filteredMovies[indexPath.row]

        performSegue(withIdentifier: "showMovieDetail", sender: movie)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }

        let movie = filteredMovies[indexPath.row]

        cell.titleLabel.text = movie.title
        cell.ratingLabel.text = String(format: "⭐ %.1f", movie.voteAverage)
        cell.releaseDateLabel.text = "📅 \(movie.releaseDate)"
        
        if let posterPath = movie.posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500/\(posterPath)")!
            cell.posterImageView.sd_setImage(with: url)
        }

        return cell
    }
}

extension ViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {

            filteredMovies = movies

            tableView.reloadData()

            return
        }

        APIManager().searchMovies(query: searchText) { movies in

            self.filteredMovies = movies

            self.tableView.reloadData()

        }
    }
}
