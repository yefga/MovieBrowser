//
//  ImageError.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

public enum ImageError: Error, Sendable {
    case badURL
    case cancelled
    case network(Error)
    case decode
}
