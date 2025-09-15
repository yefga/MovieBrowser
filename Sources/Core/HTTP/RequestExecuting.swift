//
//  RequestExecuting.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public protocol RequestExecuting {
    func call<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

public final class RequestExecutor: RequestExecuting {
    private let builder: RequestBuilding
    private let client: HTTPClient
    private let decoder: JSONDecoder
    private let logger: AppLogger?   // ← optional

    public init(
        builder: RequestBuilding,
        client: HTTPClient,
        decoder: JSONDecoder = .tmdb,
        logger: AppLogger? = nil
    ) {
        self.builder = builder
        self.client = client
        self.decoder = decoder
        self.logger = logger
    }

    public func call<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try builder.makeRequest(for: endpoint)

        logger?.debug(
            "➡️ \(request.httpMethod ?? "GET") \(redact(request.url)) headers:\(request.allHTTPHeaderFields ?? [:])"
        )

        do {
            let (data, response) = try await client.send(request)
            logger?.debug("⬅️ \(response.statusCode) for \(redact(request.url)) bytes:\(data.count)")
            try NetworkError.throwIfInvalid(response: response, data: data)

            do {
                return try decoder.decode(T.self, from: data)
            } catch let decodingError as DecodingError {
                logger?.error("❌ DecodingError for \(T.self): \(describe(decodingError))\nBody preview: \(previewBody(data))")
                throw decodingError
            }
        } catch let error as NetworkError {
            logger?.error("❌ NetworkError: \(error.localizedDescription)")
            throw error
        } catch {
            logger?.error("❌ Unknown error: \(error.localizedDescription)")
            throw error
        }
    }

    // Redact `api_key` in logs
    private func redact(_ url: URL?) -> String {
        guard let url else { return "<nil-url>" }
        guard var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url.absoluteString }
        comps.queryItems = comps.queryItems?.map {
            $0.name.lowercased() == "api_key" ? URLQueryItem(name: $0.name, value: "•••redacted•••") : $0
        }
        return comps.string ?? url.absoluteString
    }

    // Pretty-print DecodingError details
    private func describe(_ error: DecodingError) -> String {
        switch error {
        case let .typeMismatch(type, context):
            return "typeMismatch(\(type)) at \(codingPathString(context.codingPath)): \(context.debugDescription)"
        case let .valueNotFound(type, context):
            return "valueNotFound(\(type)) at \(codingPathString(context.codingPath)): \(context.debugDescription)"
        case let .keyNotFound(key, context):
            return "keyNotFound(\(key.stringValue)) at \(codingPathString(context.codingPath)): \(context.debugDescription)"
        case let .dataCorrupted(context):
            return "dataCorrupted at \(codingPathString(context.codingPath)): \(context.debugDescription)"
        @unknown default:
            return String(describing: error)
        }
    }

    private func codingPathString(_ path: [CodingKey]) -> String {
        guard !path.isEmpty else { return "<root>" }
        return path.map { key in
            if let intValue = key.intValue { return "[\(intValue)]" } else { return key.stringValue }
        }.joined(separator: ".")
    }

    // Produce a safe, truncated preview of the response body
    private func previewBody(_ data: Data, limit: Int = 2000) -> String {
        guard !data.isEmpty else { return "<empty>" }
        if let string = String(data: data, encoding: .utf8) {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > limit {
                let idx = trimmed.index(trimmed.startIndex, offsetBy: limit)
                return String(trimmed[..<idx]) + "…(truncated)"
            }
            return trimmed
        } else {
            return "<non-UTF8 payload: \(data.count) bytes>"
        }
    }
}
