//
//  URLSessionHTTPClient.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    public init(session: URLSession = .shared) { self.session = session }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidURL
            }
            return (data, http)
        } catch let error as URLError {
            throw NetworkError.map(error)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
