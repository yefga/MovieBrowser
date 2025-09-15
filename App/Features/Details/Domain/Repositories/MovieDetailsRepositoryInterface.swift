//
//  MovieDetailsRepositoryInterface.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

protocol MovieDetailsRepositoryInterface {
    func details(id: Int) async -> Result<Movie?, DetailsError>
}
