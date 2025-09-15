//
//  PlistAPIConfig.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public struct PlistAPIConfig: APIConfig {
    public let baseURL: URL
    public let apiKey: String
    public let apiToken: String

    public init?() {
        guard
            let dict = Bundle.main.infoDictionary,
            let base = dict["TMDB_API_BASE"] as? String,
            let url = URL(string: base),
            let key = dict["TMDB_API_KEY"] as? String,
            let token = dict["TMDB_API_TOKEN"] as? String
        else { return nil }
        self.baseURL = url
        self.apiKey = key
        self.apiToken = token
    }
}
