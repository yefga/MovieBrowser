//
//  SearchResponseDTO.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

struct SearchResponseDTO: Codable {
    var page: Int?
    var results: [SearchMovieDTO]?
    var totalPages: Int?
    var totalResults: Int?
}

struct SearchMovieDTO: Codable {
    var adult: Bool?
    var backdropPath: String?
    var genreIDs: [Int]?
    var id: Int?
    var originalLanguage: String?
    var originalTitle: String?
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var releaseDate: String?
    var title: String?
    var video: Bool?
    var voteAverage: Double?
    var voteCount: Int?

}
