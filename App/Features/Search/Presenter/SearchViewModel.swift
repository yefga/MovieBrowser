//
//  SearchViewModel.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Combine
import Foundation
import MoviePersistence

@MainActor
final class SearchViewModel: ObservableObject {

    init(
        useCase: SearchMoviesUseCaseInterface,
        favoritesUseCase: FavoritesRepositoryInterface
    ) {
        self.useCase = useCase
        self.favoritesUseCase = favoritesUseCase
    }
    private let useCase: SearchMoviesUseCaseInterface
    private let favoritesUseCase: FavoritesRepositoryInterface

    @Published private(set) var rows: [Movie] = []
    @Published private(set) var state: State = .idle
    @Published private(set) var title: String = ScreenTitle.initial.text
    
    private var query: String = ""
    private var page: Int = 1
    private var searchTask: Task<Void, Never>?
    private let limitCharacter: Int = 3
    private(set) var totalPage: Int = 0
    private(set) var totalResults: Int = 0
    
    func toggleFavorite(movie: Movie) {
        var item = movie
        item.isFavorite?.toggle()
        favoritesUseCase.setFavorite(item: item)
    }

    func viewDidLoad() {
        state = .initial
    }

    func updateQuery(_ text: String) {
        query = text
        resetPaging()

        if text.isEmpty {
            title = ScreenTitle.initial.text
            state = .idle
            searchTask?.cancel()
            searchTask = nil
            return
        }

        if text.count >= limitCharacter {
            performTask()
        } else {
            state = .initial
        }
    }

    func loadNextPageIfNeeded(appearingRow index: Int) {
        if index == rows.count - 1 && totalResults <= rows.count && totalPage < page {
            page += 1
            state = .hasMore
            performTask()
        }
    }
    
    private func performTask() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            await self?.performSearch()
        }
    }

    private func resetPaging() {
        page = 1
        state = .initial
        rows = []
    }

    private func performSearch() async {
        searchTask = nil
    
        guard query.isEmpty == false else {
            state = .idle
            title = ScreenTitle.initial.text
            return
        }

        let result = await useCase.execute(query: query, page: page)

        switch result {
        case .success(let paged):
    
            guard let paged else {
                state = .error(message: "Couldn’t load results. Please try again.")
                title = ScreenTitle.initial.text
                return
            }
            totalPage = paged.totalPages ?? .zero
            totalResults = paged.totalResults ?? .zero
            
            let newRows = (paged.items ?? []).compactMap {
                var movie = $0
                if let id = movie.id {
                    movie.isFavorite = favoritesUseCase.isFavorite(id: id)
                }
                return movie
            }
            if state == .hasMore {
                rows.append(contentsOf: newRows)
            } else {
                self.rows = newRows
            }
            
            state = .success

            let total = rows.count
            title = total == .zero ? ScreenTitle.notFound.text : ScreenTitle.found(total).text

        case .failure(let error):
            state = .error(message: message(for: error))
            title = ScreenTitle.initial.text
        }
    }
}

private extension SearchViewModel {
    func message(for error: MovieError) -> String {
        switch error {
        case .noInternet: return "No internet connection. Showing offline data if available."
        case .timeout: return "The request timed out. Please try again."
        case .server(let message): return message
        case .unknown: return "Something went wrong."
        case .notFound: return "Result not found"
        }
    }

    enum ScreenTitle {
        case initial
        case notFound
        case found(Int)

        var text: String {
            switch self {
            case .initial:
                return "Search Movies"
            case .notFound:
                return "No results found"
            case .found(let total):
                return "Found \(total) movie\(total > 1 ? "s" : "")"
            }
        }
    }
}
