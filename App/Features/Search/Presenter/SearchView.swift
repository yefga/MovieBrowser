//
//  SearchView.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            MainSearchView()
            .navigationTitle("Search")
            .searchable(text: $viewModel.query)
            .onChange(of: viewModel.query) { newValue in
                viewModel.updateQuery(newValue)
            }
        }
    }
    
    @ViewBuilder func MainSearchView() -> some View {
        switch viewModel.state {
        case .idle:
            Text("Start typing to search movies")
                .foregroundColor(.secondary)

        case .loading:
            ProgressView("Loading...")

        case .error(let message):
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .font(.largeTitle)
                Text(message)
                    .multilineTextAlignment(.center)
            }

        case .empty:
            Text("No results found")

        case .loaded:
            List(viewModel.rows, id: \.id) { row in
                VStack(alignment: .leading) {
                    Text(row.title ?? "Untitled").font(.headline)
                    Text(row.releaseDateText ?? "").font(.subheadline).foregroundColor(.secondary)
                }
                .onAppear {
                    if let idx = viewModel.rows.firstIndex(of: row) {
                        viewModel.loadNextPageIfNeeded(appearingRow: idx)
                    }
                }
            }
        }
    }
}
