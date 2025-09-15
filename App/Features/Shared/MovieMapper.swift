//
//  MovieMapper.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

enum MovieMapper {

    // MARK: - Search

    static func fromSearch(_ dto: SearchMovieDTO) -> Movie {
        return Movie(
            id: dto.id,
            title: dto.title,
            releaseDateText: dto.releaseDate,
            posterPath: dto.posterPath,
            originalLanguage: dto.originalLanguage,
            voteAverage: dto.voteAverage,
            overview: dto.overview
        )
    }

    static func fromSearchResponse(_ dto: SearchResponseDTO) -> Paged<Movie> {
        let items = (dto.results ?? []).compactMap { fromSearch($0)
        }
        let page = dto.page
        let hasMore: Bool? = {
            guard let page = dto.page, let total = dto.totalPages else { return nil }
            return page < total
        }()
        return Paged(
            items: items,
            page: page,
            hasMore: hasMore
        )
    }

    // MARK: - Details

    static func fromDetails(_ dto: MovieDetailsDTO) -> Movie {
        Movie(
            id: dto.id,
            title: dto.title,
            releaseDateText: dto.releaseDate,
            posterPath: dto.posterPath,
            originalLanguage: dto.originalLanguage,
            voteAverage: dto.voteAverage,
            overview: dto.overview
        )
    }
}
