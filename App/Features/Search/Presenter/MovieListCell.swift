//
//  MovieListCell.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit
import SnapKit
import MovieUI
import MovieCore

final class MovieListCell: UITableViewCell {

    private let poster = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    private let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.numberOfLines = 2
        $0.textColor = .label
    }
    private let badgeLabel = PaddingLabel().then {
        $0.textColor = .systemBackground
        $0.backgroundColor = .label.withAlphaComponent(0.85)
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        $0.font = .systemFont(ofSize: 12, weight: .semibold)
        $0.horizontalPadding = 6
        $0.verticalPadding = 2
    }
    private let metaLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .secondaryLabel
    }
    private let statusLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .tertiaryLabel
    }
    private let originalLanguageLabel = PaddingLabel().then {
        $0.textColor = .white
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        $0.font = .systemFont(ofSize: 12, weight: .semibold)
        $0.horizontalPadding = 6
        $0.verticalPadding = 2
        $0.isHidden = true
    }
    private let voteAverageLabel = PaddingLabel().then {
        $0.textColor = .white
        $0.backgroundColor = .systemGray
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        $0.font = .systemFont(ofSize: 12, weight: .semibold)
        $0.horizontalPadding = 6
        $0.verticalPadding = 2
        $0.isHidden = true
    }
    private let favoriteButton = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage.symbol(.heart), for: .normal)
        $0.tintColor = .systemRed
    }

    var isFavorite: Bool?
    var onToggleFavorite: (() -> Void)?
    
    private var currentPosterURL: URL?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureUI()
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        poster.cancelImageLoad(loader: ImageLoaderRegistry.loader, url: currentPosterURL)
        currentPosterURL = nil

        poster.image = nil
        titleLabel.text = nil
        badgeLabel.text = nil
        metaLabel.text = nil
        statusLabel.text = nil
        
        originalLanguageLabel.text = nil
        originalLanguageLabel.isHidden = true
        voteAverageLabel.text = nil
        voteAverageLabel.isHidden = true
        voteAverageLabel.backgroundColor = .systemGray
    }
    
    @objc private func didTapFavorite() {
        if self.isFavorite != nil {
            self.isFavorite?.toggle()
            favoriteButton.setImage(UIImage.symbol((self.isFavorite ?? false) ? .heartFill : .heart), for: .normal)
            onToggleFavorite?()
        }
    }
}

extension MovieListCell {
    struct Model: Hashable {
        let id: Int
        let title: String
        let badge: String?
        let runtimeText: String?
        let releaseText: String?
        let statusText: String?
        let originalLanguage: String?
        let voteAverage: Double?
        let posterURL: URL?
    }
    
    func configure(_ model: Movie) {
        titleLabel.text = model.title
        badgeLabel.isHidden = (model.adult == true) == false
        badgeLabel.text = (model.adult == true) ? "🔞" : nil
        metaLabel.text = model.releaseDateText ?? ""
        if let lang = model.originalLanguage, !lang.isEmpty {
            originalLanguageLabel.text = lang.uppercased()
            originalLanguageLabel.isHidden = false
        } else {
            originalLanguageLabel.isHidden = true
            originalLanguageLabel.text = nil
        }

        if let score = model.voteAverage, score > 0 {
            voteAverageLabel.text = String(format: "%.1f", score)
            let bgColor: UIColor
            switch score {
            case ..<5.0:
                bgColor = .systemRed
            case 5.0..<7.0:
                bgColor = .systemYellow
            default:
                bgColor = .systemGreen
            }
            voteAverageLabel.backgroundColor = bgColor
            voteAverageLabel.isHidden = false
        } else {
            voteAverageLabel.isHidden = true
            voteAverageLabel.text = nil
            voteAverageLabel.backgroundColor = nil
        }

        poster.setImage(
            url: model.posterURL(base: URL(string: "https://image.tmdb.org/t/p/w154/")),
            loader: ImageLoaderRegistry.loader,
            options: .init(cachePolicy: .default),
            placeholder: UIImage.symbol(.photo),
            transitionDuration: 0.2
        )
        isFavorite = model.isFavorite
        favoriteButton.setImage(UIImage.symbol((isFavorite ?? false) ? .heartFill : .heart), for: .normal)
    }

}
// MARK: - Private UI setup
private extension MovieListCell {
    func configureUI() {
        contentView.backgroundColor = .systemBackground
        let titleRow = UIStackView(arrangedSubviews: [titleLabel, badgeLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .firstBaseline
            $0.spacing = 8
        }

        badgeLabel.setContentHuggingPriority(.required, for: .horizontal)

        let chipsRow = UIStackView(arrangedSubviews: [originalLanguageLabel, voteAverageLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .leading
            $0.spacing = 8
        }

        let rightStack = UIStackView(arrangedSubviews: [
            titleRow,
            metaLabel,
            chipsRow,
            statusLabel
        ]).then {
            $0.axis = .vertical
            $0.spacing = 6
            $0.alignment = .leading
            $0.distribution = .fillProportionally
        }

        // Horizontal container for poster and right stack
        let hStack = UIStackView(arrangedSubviews: [poster, rightStack]).then {
            $0.axis = .horizontal
            $0.alignment = .top
            $0.spacing = 12
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(hStack)
        contentView.addSubview(favoriteButton)
        poster.snp.makeConstraints { make in
            make.width.equalTo(72)
            make.height.equalTo(108)
        }

        hStack.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).inset(16)
            make.top.equalTo(contentView.snp.top).inset(12)
            make.trailing.lessThanOrEqualTo(favoriteButton.snp.leading).offset(-12)
            make.bottom.lessThanOrEqualTo(contentView.snp.bottom).inset(12)
        }

        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(hStack.snp.top)
            make.trailing.equalTo(contentView.snp.trailing).inset(16)
            make.size.equalTo(20)
        }
    }
}

/// Small padded label to act like a rounded badge/pill
final class PaddingLabel: UILabel {
    var horizontalPadding: CGFloat = 0
    var verticalPadding: CGFloat = 0
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + horizontalPadding * 2,
            height: size.height + verticalPadding * 2
        )
    }
}
