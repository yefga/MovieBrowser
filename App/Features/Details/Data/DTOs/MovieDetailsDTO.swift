//
//  MovieDetailsDTO.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

struct MovieDetailsDTO: Codable {
    var adult: Bool?
    var backdropPath: String?
    var belongsToCollection: BelongsToCollectionDTO?
    var budget: Int?
    var genres: [GenreDTO]?
    var homepage: String?
    var id: Int?
    var imdbID: String?
    var originCountry: [String]?
    var originalLanguage: String?
    var originalTitle: String?
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var productionCompanies: [ProductionCompanyDTO]?
    var productionCountries: [ProductionCountryDTO]?
    var releaseDate: String?
    var revenue: Int?
    var runtime: Int?
    var spokenLanguages: [SpokenLanguageDTO]?
    var status: String?
    var tagline: String?
    var title: String?
    var video: Bool?
    var voteAverage: Double?
    var voteCount: Int?
}

// MARK: - Nested DTOs

struct BelongsToCollectionDTO: Codable {
    var id: Int?
    var name: String?
    var posterPath: String?
    var backdropPath: String?
}

struct GenreDTO: Codable {
    var id: Int?
    var name: String?
}

struct ProductionCompanyDTO: Codable {
    var id: Int?
    var logoPath: String?
    var name: String?
    var originCountry: String?
}

struct ProductionCountryDTO: Codable {
    var iso3166_1: String?
    var name: String?
}

struct SpokenLanguageDTO: Codable {
    var englishName: String?
    var iso639_1: String?
    var name: String?
}
