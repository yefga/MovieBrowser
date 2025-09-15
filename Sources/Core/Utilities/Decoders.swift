//
//  Decoders.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public extension JSONDecoder {
    static var tmdb: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
        return decoder
    }
}

private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = .init(identifier: "en_US_POSIX")
        return formatter
    }()
}
