//
//  HTTPClient.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public protocol HTTPClient {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
