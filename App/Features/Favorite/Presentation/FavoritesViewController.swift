//
//  FavoritesViewController.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit
import MovieUI
import SnapKit

final class FavoritesViewController: UIViewController, UITableViewDelegate {

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.registerClass(forCellClass: MovieListCell.self)
        $0.delegate = self
    }
    private lazy var emptyBackgroundView = EmptyBackgroundView().then {
        $0.configure(
            imageName: "no_data",
            title: "Your Heart List is Empty",
            message: "Show some ❤️—tap the heart on movies you don’t want to forget.",
            titleButton: "Add Movie"
        )
        $0.onTap = onAdd
    }
    private let cancelBag = CancelBag()
    private lazy var dataSource = makeDataSource()
    private let viewModel: FavoritesViewModel
    
    var onSelect: ((Int) -> Void)?
    var onAdd: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.load()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let row = dataSource.itemIdentifier(for: indexPath), let id = row.id {
            onSelect?(id)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return nil }
        guard let id = movie.id else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            self?.removeItem(withID: id)
            self?.viewModel.toggleFavorite(movie: movie)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

private extension FavoritesViewController {
    func setupUI() {
        title = "Favorites"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func binding() {
        tableView.dataSource = dataSource
        viewModel.$rows.sink { [weak self] in
            guard let self else { return }
            tableView.backgroundView = $0.isEmpty ? emptyBackgroundView : nil
            applySnapshot(rows: $0)
        }.cancel(with: cancelBag)
    }

    func makeDataSource()
    -> UITableViewDiffableDataSource<Int, Movie> {
        UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, movie in
            guard let self else { return UITableViewCell() }
            let cell: MovieListCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(movie)
            cell.onToggleFavorite = { [weak self] in
                guard let self else { return }
                if let movieID = movie.id {
                    viewModel.toggleFavorite(movie: movie)
                    removeItem(withID: movieID)
                }
            }
            return cell
        }
    }

    func applySnapshot(rows: [Movie]) {
        var snap = NSDiffableDataSourceSnapshot<Int, Movie>()
        snap.appendSections([0])
        let uniqueRows: [Movie] = {
            var seen = Set<Int>()
            return rows.filter { row in
                guard let id = row.id else { return false }
                if seen.contains(id) { return false }
                seen.insert(id)
                return true
            }
        }()
        snap.appendItems(uniqueRows)
        dataSource.apply(snap, animatingDifferences: true)
    }

    func removeItem(withID id: Int) {
        var snap = dataSource.snapshot()
        if let item = snap.itemIdentifiers.first(where: { $0.id == id }) {
            snap.deleteItems([item])
            dataSource.apply(snap, animatingDifferences: true)
        }
    }
    
    @objc func backToSearchMovies() {
        onAdd?()
    }
}
