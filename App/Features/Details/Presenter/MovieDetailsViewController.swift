//
//  MovieDetailsViewController.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit
import MovieUI
import SnapKit

final class MovieDetailsViewController: UIViewController {
    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private let viewModel: MovieDetailsViewModel
    private var cancelBag = CancelBag()
    private let activityIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.startAnimating()
        $0.color = .red
    }
    private let poster = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    private let overlayView = UIView().then {
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = .clear
    }
    private let overlayGradientLayer = CAGradientLayer()
    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 22)
        $0.numberOfLines = 0
        $0.textColor = .white
    }
    private let metaLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.white.withAlphaComponent(0.85)
        
    }
    private let overviewLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 2
        $0.textColor = .white
    }
    private lazy var readMoreButton = UIButton(type: .system).then {
        $0.setTitle(Constants.Components.readMore, for: .normal)
        $0.contentHorizontalAlignment = .left
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(
            self,
            action: #selector(toggleReadMore),
            for: .touchUpInside
        )
    }
    private lazy var stack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.addArrangedSubview(titleLabel)
        $0.addArrangedSubview(metaLabel)
        $0.addArrangedSubview(overviewLabel)
        $0.addArrangedSubview(readMoreButton)
    }
    private lazy var contentContainer = UIView().then {
        $0.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
            make.top.greaterThanOrEqualToSuperview().inset(16)
        }
    }
    private lazy var scrollView = UIScrollView().then {
        $0.addSubview(contentContainer)
    }
    private lazy var emptyBackgroundView = EmptyBackgroundView().then {
        $0.configure(
            imageName: "no_signal",
            title: "No Signal in the Theater",
            message: "Looks like the internet took an intermission. Refresh when you’re back online",
            titleButton: "Try Again"
        )
        $0.onTap = { [weak self] in
            self?.loadRequest()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFavoriteButton()
        setupBindings()
        loadRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTransparentNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayGradientLayer.frame = overlayView.bounds
    }
    
    @objc private func toggleFavorite() {
        viewModel.toggleFavorite()
    }
    
    @objc private func toggleReadMore() {
        updateReadVisibility()
    }

}

private extension MovieDetailsViewController {
    func loadRequest() {
        Task { await viewModel.load() }
    }
}

private extension MovieDetailsViewController {
    func setupFavoriteButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.symbol(.heart),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
    }
    
    func setupTransparentNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.isTranslucent = true
        
        navigationItem.title = nil
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(poster)
        view.addSubview(overlayView)
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        overlayView.layer.insertSublayer(overlayGradientLayer, at: .zero)
        overlayGradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0.9).cgColor
        ]
        overlayGradientLayer.locations = [0.0, 0.6, 1.0]
        
        poster.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentContainer.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            make.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide.snp.height)
        }
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setupBindings() {
        viewModel.$movie
            .sink { [weak self] model in
                guard let self, let model else {
                    self?.navigationItem.rightBarButtonItem = nil
                    self?.readMoreButton.isHidden = true
                    return
                }
                titleLabel.text = model.title
                metaLabel.text = [
                    model.releaseDateText?.convertDate(from: .yyyyMMdd, to: .long),
                    model.originalLanguage?.uppercased()
                ].compactMap { $0 }.joined(separator: " · ")
                overviewLabel.text = model.overview ?? Constants.Components.noOverview
                
                if let base = URL(string: Constants.Image.tmdbBaseW200 + (model.posterPath ?? .empty)) {
                    poster.setImage(url: model.posterURL(base: base), loader: ImageLoaderRegistry.loader)
                }
                emptyBackgroundView.removeFromSuperview()
                setupReadVisibility()
            }
            .cancel(with: cancelBag)
        
        viewModel.$isLoading.sink { [weak self] in
            if $0 { self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }.cancel(with: cancelBag)
        
        viewModel.$isFavorite
            .removeDuplicates()
            .sink { [weak self] status in
                guard let self else { return }
                navigationItem.rightBarButtonItem?.image = .isFavorite(condition: status)
            }
            .cancel(with: cancelBag)
        
        viewModel.$error
            .compactMap { $0 }
            .sink { [weak self] type in
                guard let self else { return }
                switch type {
                case .noInternet, .timeout:
                    view.addSubview(emptyBackgroundView)
                    emptyBackgroundView.snp.makeConstraints {
                        $0.edges.equalTo(self.view.safeAreaLayoutGuide)
                    }
                default:
                    emptyBackgroundView.removeFromSuperview()
                    view.makeToast(type.localizedDescription)
                }
            }
            .cancel(with: cancelBag)
    }
    
    func setupReadVisibility() {
        guard let text = overviewLabel.text, !text.isEmpty else {
            readMoreButton.isHidden = true
            return
        }
        
        let labelWidth = overviewLabel.bounds.width > 0
        ? overviewLabel.bounds.width
        : view.bounds.inset(by: view.safeAreaInsets).width - 32
        let sizing = UILabel()
        sizing.numberOfLines = 0
        sizing.font = overviewLabel.font
        sizing.text = text
        sizing.lineBreakMode = .byWordWrapping
        let neededHeight = sizing.sizeThatFits(
            CGSize(
                width: labelWidth,
                height: .greatestFiniteMagnitude
            )
        ).height
        let twoLineHeight = ceil(overviewLabel.font.lineHeight * 2)
        let fitsInTwoLines = neededHeight <= twoLineHeight + 0.5
        readMoreButton.isHidden = fitsInTwoLines
        if overviewLabel.numberOfLines != 2 { overviewLabel.numberOfLines = 2 }
    }
    
    func updateReadVisibility() {
        overviewLabel.numberOfLines = overviewLabel.numberOfLines == .zero ? 2 : .zero
        readMoreButton.setTitle(
            overviewLabel.numberOfLines == .zero ?
            Constants.Components.readLess : Constants.Components.readMore,
            for: .normal
        )
    }
}
