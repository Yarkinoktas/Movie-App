//
//  APIManager.swift
//  MovieApp
//
//  Created by Yarkın Oktaş on 31.07.2026.
//

import Foundation

class APIManager {
    
    let apiKey = "4038b05848db752fea739929675ded36"
    
    func fetchMovies(completion: @escaping ([Movie]) -> Void) {
        
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else { return }
            
            do {
                
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                
                DispatchQueue.main.async {
                    
                    completion(movieResponse.results)
                }
                
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    func fetchMovieDetails(movieID: Int, completion: @escaping (MovieDetailResponse?) -> Void) {
        
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)?api_key=\(apiKey)&language=en-US"
        
        guard let url = URL(string: urlString) else {
            print("URL oluşturulamadı")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print("API Hatası:", error)
                return
            }
            
            guard let data = data else {
                print("Data gelmedi")
                return
            }
            
            do {
                
                let details = try JSONDecoder().decode(
                    MovieDetailResponse.self,
                    from: data
                )
                
                DispatchQueue.main.async {
                    completion(details)
                }
                
            } catch {
                
                print("Decode hatası:", error)
                
                if let responseText = String(data: data, encoding: .utf8) {
                    print("TMDB cevabı:", responseText)
                }
            }
            
        }.resume()
    }
    
    func searchMovies(query: String, completion: @escaping ([Movie]) -> Void) {

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in

            guard let data = data else { return }

            do {

                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)

                DispatchQueue.main.async {
                    completion(movieResponse.results)
                }

            } catch {

                print(error)

            }

        }.resume()
    }
    
    func fetchCast(movieID: Int, completion: @escaping ([CastMember]) -> Void) {
        
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/credits?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            do {
                let credits = try JSONDecoder().decode(
                    CreditsResponse.self,
                    from: data
                )
                
                DispatchQueue.main.async {
                    completion(credits.cast)
                }
                
            } catch {
                print("Cast alınamadı:", error)
                
                DispatchQueue.main.async {
                    completion([])
                }
            }
            
        }.resume()
    }
    
    struct MovieDetailResponse: Codable {
        
        let genres: [Genre]
        let runtime: Int?
    }

    struct Genre: Codable {
        
        let id: Int
        let name: String
    }
    
    struct CreditsResponse: Codable {
        let cast: [CastMember]
    }

    struct CastMember: Codable {
        let name: String
        let character: String
        let profilePath: String?
        
        enum CodingKeys: String, CodingKey {
            case name
            case character
            case profilePath = "profile_path"
        }
    }
    
}
