//
//  SearchViewModel.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Combine
import Foundation
import MoviePersistence

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
    @Published var query: String = ""
    @Published var title: String = "Search Movies"
    var onReload: (() -> Void)?
    var onStateChange: ((State) -> Void)?
    
    private var page: Int = 1
    private var hasMore: Bool = false
    private var searchTask: Task<Void, Never>?
    private let limitCharacter: Int = 3
    
    @Published private(set) var movies: [Movie] = []
    
    func toggleFavorite(movie: Movie) {
        var item = movie
        item.isFavorite?.toggle()
        favoritesUseCase.setFavorite(item: item)
    }

    func viewDidLoad() {
        onStateChange?(.initial)
    }
    
    func updateQuery(_ text: String) {
        query = text
        resetPaging()
        onReload?()
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            title = "Search Movies"
            state = .idle
            onStateChange?(state)
            searchTask?.cancel()
            searchTask = nil
            return
        }
        
        if trimmed.count >= limitCharacter {
            searchTask?.cancel()
            searchTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 300_000_000)
                await self?.performSearch(reset: true)
            }
        } else {
            if rows.isEmpty {
                onStateChange?(.initial)
            }
        }
    }
    
    func loadNextPageIfNeeded(appearingRow index: Int) {
        guard index >= rows.count - 4, hasMore, searchTask == nil else { return }
        page += 1
        searchTask = Task { [weak self] in
            await self?.performSearch(reset: false)
        }
    }
    
    
    private func resetPaging() {
        page = 1
        hasMore = false
        rows = []
    }
    
    private func performSearch(reset: Bool) async {
        searchTask = nil
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            state = .idle
            title = "Search Movies"
            onStateChange?(state)
            return
        }
        
        if reset {
            state = .loading
            onStateChange?(state)
        }
        
        let result = await useCase.execute(query: trimmed, page: page)
        
        switch result {
        case .success(let paged):
            guard let paged else {
                state = .error(message: "Couldn’t load results. Please try again.")
                title = "Search Movies"
                onStateChange?(state)
                return
            }
            
            let newRows: [Movie] = (paged.items ?? []).map { movie in
                var newMovie = movie
                if let id = movie.id { newMovie.isFavorite = favoritesUseCase.isFavorite(id: id) }
                return newMovie
            }
            if reset { rows = newRows } else { rows.append(contentsOf: newRows) }
            
            hasMore = paged.hasMore ?? false
            state = rows.isEmpty ? .empty : .loaded(hasMore: hasMore)
            
            let total = rows.count
            if total == 0 {
                title = "No movie for \(query)"
            } else {
                title = "Found \(total) " + (total == 1 ? "movie" : "movies")
            }
            
            onReload?()
            onStateChange?(state)
            
        case .failure(let error):
            state = .error(message: message(for: error))
            title = "Search Movies"
            onStateChange?(state)
        }
    }
    
    private func message(for error: MovieError) -> String {
        switch error {
        case .noInternet:
            return "No internet connection. Showing offline data if available."
        case .timeout:
            return "The request timed out. Please try again."
        case .server(let message):
            return message
        case .unknown:
            return "Something went wrong."
        case .notFound:
            return "Result not found"
        }
    }
}
