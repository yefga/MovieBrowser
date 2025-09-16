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
    private lazy var emptyTableBackgroundView = UIView().then {
        let imageView = UIImageView().then {
            $0.image = .init(named: "no_data")
        }
        let titleLabel = UILabel().then {
            $0.text = "Your Heart List is Empty"
            $0.font = .boldSystemFont(ofSize: 18)
            $0.font = .boldSystemFont(ofSize: 18)
        }
        let messageLabel = UILabel().then {
            $0.text = "Show some ❤️—tap the heart on movies you don’t want to forget."
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 16)
            $0.numberOfLines = 0
        }
        let addButton = UIButton(type: .system).then {
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.filled()
                // Title
                var titleAttr = AttributedString("Add a movie")
                titleAttr.font = .boldSystemFont(ofSize: 16)
                config.attributedTitle = titleAttr
                config.baseForegroundColor = .white
                // Glassy background via blur + stroke
                var background = UIBackgroundConfiguration.clear()
                background.visualEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                background.cornerRadius = 12
                background.strokeColor = UIColor.white.withAlphaComponent(0.5)
                background.strokeWidth = 1
                background.backgroundColor = .red
                config.background = background
                // Padding
                config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                $0.configuration = config
                $0.clipsToBounds = true
            } else {
                // Fallback (older than iOS 15) – kept for completeness
                $0.setTitle("Add a movie", for: .normal)
                $0.setTitleColor(.label, for: .normal)
                $0.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                $0.layer.cornerRadius = 12
                $0.layer.borderWidth = 1
                $0.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
                $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
                $0.clipsToBounds = true
            }
            $0.addTarget(self, action: #selector(backToSearchMovies), for: .touchUpInside)
        }
        let stack = UIStackView(arrangedSubviews: [
            titleLabel, messageLabel, addButton
        ]).then {
            $0.axis = .vertical
            $0.spacing = 8.0
            $0.alignment = .center
        }
        $0.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.size.equalTo(UIScreen.main.bounds.width * 0.65)
        }
        $0.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
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
            tableView.backgroundView = $0.isEmpty ? emptyTableBackgroundView : nil
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
