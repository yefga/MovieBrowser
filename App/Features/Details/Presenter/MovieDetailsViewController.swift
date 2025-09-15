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

    private let poster = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    private let gradientLayer = CAGradientLayer()
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
    private let readMoreButton = UIButton(type: .system).then {
        $0.setTitle(Constants.UI.readMore, for: .normal)
        $0.contentHorizontalAlignment = .left
        $0.setTitleColor(.white, for: .normal)
    }
    private lazy var stack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.addArrangedSubview(titleLabel)
        $0.addArrangedSubview(metaLabel)
        $0.addArrangedSubview(overviewLabel)
        $0.addArrangedSubview(readMoreButton)
    }
    private let contentContainer = UIView()
    private lazy var scrollView = UIScrollView().then {
        $0.addSubview(contentContainer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.symbol(.heart),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )

        readMoreButton.addTarget(self, action: #selector(toggleReadMore), for: .touchUpInside)
        setupUI()
        Task { await viewModel.load(); bind() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.isTranslucent = true
        
        navigationItem.title = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayGradientLayer.frame = overlayView.bounds
    }

    private func setupUI() {
        view.addSubview(poster)
        view.addSubview(overlayView)
        view.addSubview(scrollView)
        overlayView.layer.insertSublayer(overlayGradientLayer, at: 0)
        overlayGradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0.9).cgColor
        ]
        overlayGradientLayer.locations = [0.0, 0.6, 1.0]

        contentContainer.addSubview(stack)

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

        stack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
            make.top.greaterThanOrEqualToSuperview().inset(16)
        }

        view.sendSubviewToBack(poster)
        view.bringSubviewToFront(scrollView)
    }

    private func bind() {
        guard let model = viewModel.movie else { return }
        titleLabel.text = model.title
        metaLabel.text = [model.releaseDateText, Constants.UI.defaultGenre].compactMap { $0 }.joined(separator: " · ")
        overviewLabel.text = model.overview ?? Constants.UI.noOverview

        if let base = URL(string: Constants.Image.tmdbBaseW200 + (model.posterPath ?? .empty)) {
            poster.setImage(url: model.posterURL(base: base), loader: ImageLoaderRegistry.loader)
        }

        navigationItem.rightBarButtonItem?.image = UIImage.symbol(viewModel.isFavorite ? .heartFill : .heart)

        if let overviewText = model.overview, !overviewText.isEmpty {
            readMoreButton.isHidden = false
            overviewLabel.numberOfLines = 2
            readMoreButton.setTitle(Constants.UI.readMore, for: .normal)
        } else {
            readMoreButton.isHidden = true
            overviewLabel.numberOfLines = 0
        }
    }

    @objc private func toggleFavorite() {
        viewModel.toggleFavorite()
        navigationItem.rightBarButtonItem?.image = UIImage.symbol(viewModel.isFavorite ? .heartFill : .heart)
    }

    @objc private func toggleReadMore() {
        if overviewLabel.numberOfLines == 0 {
            overviewLabel.numberOfLines = 2
            readMoreButton.setTitle(Constants.UI.readMore, for: .normal)
        } else {
            overviewLabel.numberOfLines = 0
            readMoreButton.setTitle(Constants.UI.readLess, for: .normal)
        }
    }
}
