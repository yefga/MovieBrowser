//
//  AppContainer.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import MovieCore
import MoviePersistence

final class AppContainer {
    let executor: RequestExecuting
    let searchMoviesRepository: SearchMovieRepositoryInterface
    let movieDetailsRepository: MovieDetailsRepositoryInterface
    let favoritesRepository: FavoritesRepositoryInterface

    init?() {
        guard let config = PlistAPIConfig() else {
            assertionFailure("⚠️ APIConfig.plist is missing or invalid.")
            return nil
        }

        let builder = DefaultRequestBuilder(config: config)
        let client  = URLSessionHTTPClient()
        let logger  = DefaultLogger(category: "Networking")
        executor = RequestExecutor(builder: builder, client: client, logger: logger)
        favoritesRepository = FavoritesRepository()

        let cache = CoreDataMovieCache()
        searchMoviesRepository = SearchMovieRepository(executor: executor, cache: cache, favorites: favoritesRepository)
        movieDetailsRepository = MovieDetailsRepository(executor: executor)
    }

    static func make() -> AppContainer {
        guard let container = AppContainer() else {
            fatalError("❌ AppContainer init failed. Check APIConfig.plist bundling and values.")
        }
        return container
    }
}
