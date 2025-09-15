//
//  MovieDetailsRepository.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import MovieCore
import MoviePersistence

final class MovieDetailsRepository: MovieDetailsRepositoryInterface {
    private let executor: RequestExecuting

    init(executor: RequestExecuting) {
        self.executor = executor
    }

    func details(id: Int) async -> Result<Movie?, DetailsError> {
        do {
            let endpoint = MovieEndpoint.details(id: id)
            let dto: MovieDetailsDTO = try await executor.call(endpoint)
            let movie = Movie(
                id: dto.id,
                title: dto.title,
                releaseDateText: dto.releaseDate,
                posterPath: dto.posterPath,
                overview: dto.overview
            )
            return .success(movie)
        } catch let error as NetworkError {
            switch error {
            case .noInternet:
                return .failure(.noInternet)
            case .timedOut:
                return .failure(.timeout)
            case .server(_, _, let api):
                return .failure(.server(message: api?.statusMessage ?? "Server error"))
            default:
                return .failure(.unknown)
            }
        } catch {
            return .failure(.unknown)
        }
    }
}
