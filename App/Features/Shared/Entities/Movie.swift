//
//  Movie.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public struct Movie: Equatable, Hashable, Sendable {
    public var id: Int?
    public var title: String?
    public var releaseDateText: String?
    public var posterPath: String?
    public var adult: Bool?
    public var originalLanguage: String?
    public var voteAverage: Double?
    public var overview: String?
    public var isFavorite: Bool?

    public func posterURL(base: URL?) -> URL? {
        guard let path = posterPath else { return nil }
        return base?.appendingPathComponent(
            path.trimmingCharacters(in: CharacterSet(charactersIn: "/")),
            isDirectory: false
        )
    }
    
    public init(
        id: Int? = nil,
        title: String? = nil,
        releaseDateText: String? = nil,
        posterPath: String? = nil,
        adult: Bool? = nil,
        originalLanguage: String? = nil,
        voteAverage: Double? = nil,
        overview: String? = nil,
        isFavorite: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.releaseDateText = releaseDateText
        self.posterPath = posterPath
        self.adult = adult
        self.originalLanguage = originalLanguage
        self.voteAverage = voteAverage
        self.overview = overview
        self.isFavorite = isFavorite
    }

    public init(dict: [String: Any]) {
        self.id = dict["id"] as? Int
        self.title = dict["title"] as? String
        self.releaseDateText = dict["releaseDateText"] as? String
        self.posterPath = dict["posterPath"] as? String
        self.overview = dict["overview"] as? String
        self.isFavorite = dict["isFavorite"] as? Bool
        self.originalLanguage = dict["originalLanguage"] as? String
        self.voteAverage = dict["voteAverage"] as? Double
    }

    public func asDictionary() -> [String: Any] {
        [
            "id": id as Any,
            "title": title as Any,
            "releaseDateText": releaseDateText as Any,
            "posterPath": posterPath as Any,
            "overview": overview as Any,
            "isFavorite": isFavorite as Any,
            "voteAverage": voteAverage as Any,
            "originalLanguage": originalLanguage as Any
        ]
    }
}
