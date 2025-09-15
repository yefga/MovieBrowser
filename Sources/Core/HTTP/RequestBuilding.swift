//
//  RequestBuilding.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public protocol RequestBuilding {
    func makeRequest(for endpoint: Endpoint) throws -> URLRequest
}
