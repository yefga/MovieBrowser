//
//  Endpoint.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var query: [String: String]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}
