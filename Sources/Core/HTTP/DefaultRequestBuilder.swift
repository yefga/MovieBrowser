//
//  DefaultRequestBuilder.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public final class DefaultRequestBuilder: RequestBuilding {
    private let config: APIConfig
    public init(config: APIConfig) { self.config = config }

    public func makeRequest(for endpoint: Endpoint) throws -> URLRequest {
        var comps = URLComponents(url: config.baseURL, resolvingAgainstBaseURL: false)
        comps?.path += endpoint.path

        var query = endpoint.query
//        query["api_key"] = config.apiKey
        comps?.queryItems = query?.compactMap { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = comps?.url else { throw NetworkError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method.rawValue
        req.httpBody = endpoint.body
        var headers = endpoint.headers
        headers?["Authorization"] = "Bearer \(config.apiToken)"
        headers?["Content-Type"] = "application/json"
        req.allHTTPHeaderFields = headers
        endpoint.headers?.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        return req
    }
}
