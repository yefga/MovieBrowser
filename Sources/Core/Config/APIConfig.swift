//
//  APIConfig.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public protocol APIConfig {
    var baseURL: URL { get }
    var apiKey: String { get }
    var apiToken: String { get }
}
