//
//  MovieEndpoint.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation
import MovieCore

enum MovieEndpoint: Endpoint {
    case search(query: String, page: Int)
    case details(id: Int)

    var path: String {
        switch self {
        case .search: return "/search/movie"
        case .details(let id): return "/movie/\(id)"

        }
    }

    var method: HTTPMethod { .get }

    var query: [String: String]? {
        switch self {
        case let .search(query, page):
            return [
                "query": query,
                "page": String(page),
                "include_adult": "false",
                "language": "en-US"
            ]
        case .details:
            return nil
        }
    }

    var headers: [String: String]? { [:] }
    var body: Data? { nil }
}
