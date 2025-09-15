//
//  SearchViewController.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit
import MovieUI
import SnapKit
import IQKeyboardManagerSwift

final class SearchViewController: UIViewController {
    var onShowFavorites: (() -> Void)?
    var onSelectMovie: ((Int) -> Void)?

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private let viewModel: SearchViewModel

    private lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    private var dataSource: UITableViewDiffableDataSource<Int, Movie>!
    private lazy var tableView = UITableView().then {
        $0.registerClass(forCellClass: MovieListCell.self)
        $0.alwaysBounceVertical = true
        $0.delegate = self
        $0.refreshControl = refreshControl
    }
    private lazy var searchContainer = UIView().then {
        $0.layer.cornerRadius = 22
        $0.clipsToBounds = true

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        $0.addSubview(blur)
        blur.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        $0.addSubview(searchTextField)
        searchTextField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }
    private lazy var searchTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
        $0.clearButtonMode = .never
        $0.returnKeyType = .search
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.textColor = .label
        $0.tintColor = .label
        $0.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        let icon = UIImageView(image: UIImage.symbol(.magnifyingglass))
        icon.tintColor = .secondaryLabel
        let leftContainer = UIView(frame: CGRect(x: .zero, y: .zero, width: 32, height: 24))
        icon.frame = CGRect(x: 8, y: .zero, width: 24, height: 24)
        icon.contentMode = .scaleAspectFit
        leftContainer.addSubview(icon)

        $0.leftView = leftContainer
        $0.leftViewMode = .always
        let rightContainer = UIView(frame: CGRect(x: .zero, y: .zero, width: 28, height: 24))
        rightContainer.addSubview(loadingIndicator)
        $0.rightView = rightContainer
        $0.rightViewMode = .never
    }
    private lazy var clearButton = UIButton(type: .system).then {
        $0.setImage(UIImage.symbol(.xmark), for: .normal)
        $0.tintColor = .label
        $0.backgroundColor = .systemBackground
        $0.layer.cornerRadius = 20
        $0.isHidden = true
        $0.accessibilityLabel = "Clear"
        $0.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        let isEmptyInitially = (searchTextField.text ?? "").isEmpty
        $0.isHidden = isEmptyInitially
    }
    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = .secondaryLabel
    }
    // Keep references to update icons reliably when using multiple right bar buttons
    private var darkModeBarButton: UIBarButtonItem?
    private var favoritesBarButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        view.backgroundColor = .systemBackground
        
        configureSearchBar()
        configureTableView()
        bindViewModel()
        configureDarkModeButton()
        applyNavigationBarAppearance(for: traitCollection.userInterfaceStyle)
        configureFloatingSearchField()        
    }
    
    private func configureSearchBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        dataSource = makeDataSource()
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Int, Movie> {
        let dataSource = UITableViewDiffableDataSource<Int, Movie>(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, row in
                guard let self else { return UITableViewCell() }
                let cell: MovieListCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(row)
                cell.onToggleFavorite = { [weak self] in
                    self?.viewModel.toggleFavorite(movie: row)
                }
                return cell
            }
        )
        return dataSource
    }
    
    @objc private func didPullToRefresh() {
        let currentText = searchTextField.text ?? .empty
        viewModel.updateQuery(currentText)
    }
    
    private func bindViewModel() {
        viewModel.onReload = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                applySnapshot()
                refreshControl.endRefreshing()
                title = viewModel.title
                clearButton.isHidden = viewModel.rows.isEmpty
                self.searchTextField.rightViewMode = .never
                self.loadingIndicator.stopAnimating()
            }
        }
        
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                handleState(state)
            }
        }
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.rows, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func handleState(_ state: SearchViewModel.State) {
        switch state {
        case .loading:
            searchTextField.rightViewMode = .always
            loadingIndicator.startAnimating()
        case .error(let message):
            searchTextField.rightViewMode = .never
            loadingIndicator.stopAnimating()
            view.makeToast(message)
            refreshControl.endRefreshing()
        case .empty:
            searchTextField.rightViewMode = .never
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
        default:
            searchTextField.rightViewMode = .never
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
        }
    }
    
    private func configureFloatingSearchField() {
        searchContainer.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        let searchStack = UIStackView(arrangedSubviews: [searchContainer, clearButton]).then {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.spacing = 8
        }
        view.addSubview(searchStack)
        searchStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        let text = textField.text ?? .empty
        viewModel.updateQuery(text)
        clearButton.isHidden = text.isEmpty
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func clearTapped() {
        searchTextField.text = .empty
        clearButton.isHidden = true
        viewModel.updateQuery(.empty)
        searchTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        viewModel.loadNextPageIfNeeded(appearingRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let row = dataSource.itemIdentifier(for: indexPath) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let id = row.id {
                    onSelectMovie?(id)
                }
                
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension SearchViewController {
    private func configureDarkModeButton() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        // Configure dark mode toggle button
        let darkButton = UIBarButtonItem(
            image: UIImage.symbol(isDark ? .sunMaxFill : .moonFill),
            style: .plain,
            target: self,
            action: #selector(toggleDarkMode)
        )
        darkButton.accessibilityLabel = isDark ? "Switch to Light Mode" : "Switch to Dark Mode"
        self.darkModeBarButton = darkButton

        // Configure favorites button
        let favoritesButton = UIBarButtonItem(
            image: UIImage.symbol(.heart),
            style: .plain,
            target: self,
            action: #selector(showFavorites)
        )
        favoritesButton.accessibilityLabel = "Favorites"
        self.favoritesBarButton = favoritesButton
        navigationItem.rightBarButtonItems = [darkButton, favoritesButton]
    }
    
    @objc private func toggleDarkMode() {
        let window: UIWindow? = {
            if let w = view.window { return w }
            if let scene = view.window?.windowScene {
                return scene.windows.first { $0.isKeyWindow } ?? scene.windows.first
            }
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        }()
        
        guard let window else { return }
        let isDark = window.overrideUserInterfaceStyle == .dark
        let newStyle: UIUserInterfaceStyle = isDark ? .light : .dark
        window.overrideUserInterfaceStyle = newStyle
        darkModeBarButton?.image = UIImage.symbol(newStyle == .dark ? .sunMaxFill : .moonFill)
        darkModeBarButton?.accessibilityLabel = (newStyle == .dark) ? "Switch to Light Mode" : "Switch to Dark Mode"
        applyNavigationBarAppearance(for: newStyle)
    }
    
    @objc private func showFavorites() {
        if let handler = onShowFavorites {
            handler()
            return
        }
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Favorites"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func applyNavigationBarAppearance(for style: UIUserInterfaceStyle) {
        let appearance = UINavigationBarAppearance()
        if style == .dark {
            appearance.backgroundColor = UIColor.black
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        } else {
            appearance.backgroundColor = UIColor.systemBackground
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        }
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = (style == .dark) ? .white : .label
    }
}
