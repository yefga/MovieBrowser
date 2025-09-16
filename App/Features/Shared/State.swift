//
//  State.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

enum State: Equatable {
    case success
    case initial
    case idle
    case loading
    case hasMore
    case empty
    case error(message: String)
}
