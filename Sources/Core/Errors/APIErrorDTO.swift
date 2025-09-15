//
//  APIErrorDTO.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public struct APIErrorDTO: Decodable, Equatable {
    public let statusMessage: String
    public let statusCode: Int
    public let success: Bool?

    enum CodingKeys: String, CodingKey {
        case statusMessage = "status_message"
        case statusCode    = "status_code"
        case success
    }
}
