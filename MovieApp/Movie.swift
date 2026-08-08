//
//  Movie.swift
//  MovieApp
//
//  Created by Yarkın Oktaş on 31.07.2026.
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    
    let id : Int
    let title: String
    let voteAverage: Double
    let releaseDate: String
    let posterPath: String?
    let overview: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case overview
    }
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
