//
//  EmptyBackgroundView.swift
//  MovieBrowser
//
//  Created by Yefga on 16/09/25.
//

import UIKit
import SnapKit

public final class EmptyBackgroundView: UIView {
    public var onTap: (() -> Void)?
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 18)
        $0.font = .boldSystemFont(ofSize: 18)
    }
    private let messageLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
    }
    private lazy var actionButton = UIButton(type: .system).then {
        if #available(iOS 15.0, *) {
            $0.clipsToBounds = true
        } else {
            // Fallback (older than iOS 15) – kept for completeness
            $0.setTitleColor(.label, for: .normal)
            $0.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            $0.clipsToBounds = true
        }
        $0.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
    }
    private lazy var textStack = UIStackView(arrangedSubviews: [
        titleLabel, messageLabel, actionButton
    ]).then {
        $0.axis = .vertical
        $0.spacing = 8.0
        $0.alignment = .center
    }
    
    override init(
        frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleActionButton() {
        onTap?()
    }
    
}

extension EmptyBackgroundView {
    func setupUI() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.size.equalTo(UIScreen.main.bounds.width * 0.65)
        }
        addSubview(textStack)
        textStack.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
    public func configure(
        imageName: String,
        title: String,
        message: String,
        titleButton: String? = nil
    ) {
        self.imageView.image = .init(named: imageName)
        self.titleLabel.text = title
        self.messageLabel.text = message
        if let titleButton = titleButton {
            
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.filled()
                var titleAttr = AttributedString(titleButton)
                titleAttr.font = .boldSystemFont(ofSize: 16)
                config.attributedTitle = titleAttr
                config.baseForegroundColor = .white
                var background = UIBackgroundConfiguration.clear()
                background.visualEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                background.cornerRadius = 12
                background.strokeColor = UIColor.white.withAlphaComponent(0.5)
                background.strokeWidth = 1
                background.backgroundColor = .red
                config.background = background
                // Padding
                config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                self.actionButton.configuration = config
            } else {
                self.actionButton.setTitle(titleButton, for: .normal)
            }
            actionButton.isHidden = false

        } else {
            actionButton.isHidden = true
        }
    }
}
