//
//  NetworkError.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noInternet
    case timedOut
    case cancelled
    case transport(URLError)
    case server(code: Int, message: String?, apiError: APIErrorDTO?)
    case decoding(Error)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request URL."
        case .noInternet: return "No internet connection."
        case .timedOut: return "The request timed out."
        case .cancelled: return "The request was cancelled."
        case .transport(let error): return "Transport error: \(error.localizedDescription)"
        case .server(_, let msg, let apiError):
            return apiError?.statusMessage ?? msg ?? "Server error"
        case .decoding(let error): return "Decoding failed: \(error.localizedDescription)"
        case .unknown(let error): return "Unexpected error: \(error.localizedDescription)"
        }
    }

    static func throwIfInvalid(response: HTTPURLResponse, data: Data) throws {
        guard (200...299).contains(response.statusCode) else {
            let apiError = try? JSONDecoder().decode(APIErrorDTO.self, from: data)
            let msg = String(data: data, encoding: .utf8)
            throw NetworkError.server(code: response.statusCode, message: msg, apiError: apiError)
        }
    }

    static func map(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet: return .noInternet
        case .timedOut: return .timedOut
        case .cancelled: return .cancelled
        default: return .transport(error)
        }
    }
}
