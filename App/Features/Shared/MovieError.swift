//
//  SearchError.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

enum MovieError: Error, Equatable {
    case notFound
    case noInternet
    case timeout
    case server(message: String)
    case unknown
}
