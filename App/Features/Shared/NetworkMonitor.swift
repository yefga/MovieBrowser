//
//  NetworkMonitor.swift
//  MovieBrowser
//
//  Created by Assistant on 15/09/25.
//

import Foundation
import UIKit
import Network
import MovieUI

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private weak var window: UIWindow?
    private var offlineToastView: UIView?
    private var isMonitoring = false
    private var previousTapToDismissSetting: Bool = ToastManager.shared.isTapToDismissEnabled
    private var lastIsConnected: Bool = true

    private init() {}

    func start(on window: UIWindow) {
        self.window = window
        guard !isMonitoring else { return }
        isMonitoring = true
        lastIsConnected = (monitor.currentPath.status == .satisfied)

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handlePathUpdate(path)
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        guard isMonitoring else { return }
        isMonitoring = false
        monitor.cancel()

        DispatchQueue.main.async {
            if let window = self.window {
                // Dismiss any visible or queued toasts (including activity) to avoid lingering UI
                window.hideAllToasts(includeActivity: true, clearQueue: true)
            }
            self.offlineToastView = nil
            // Restore tap-to-dismiss if we modified it
            ToastManager.shared.isTapToDismissEnabled = self.previousTapToDismissSetting
        }
    }
    
    private func handlePathUpdate(_ path: NWPath) {
        let isConnected = (path.status == .satisfied)
        lastIsConnected = isConnected
        if isConnected {
            if let window = window {
                window.hideAllToasts(includeActivity: true, clearQueue: true)
            }
            offlineToastView = nil
            ToastManager.shared.isTapToDismissEnabled = previousTapToDismissSetting
        } else {
            guard let window = window else { return }
            showOrRefreshOfflineToast(on: window)
        }
    }

    private func showOrRefreshOfflineToast(on window: UIWindow) {
        if offlineToastView != nil { return }

        var style = ToastManager.shared.style
        style.backgroundColor = UIColor.systemRed.withAlphaComponent(0.92)
        style.messageColor = .white
        style.messageAlignment = .center
        style.cornerRadius = 12
        style.displayShadow = false

        let toastView = try? window.toastViewForMessage(
            "No Internet Connection",
            title: "Trying to reconnect…",
            image: nil,
            style: style
        )
        guard let toast = toastView else { return }

        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        let padding: CGFloat = 10
        indicator.frame = CGRect(x: toast.bounds.width - 24 - padding,
                                 y: padding,
                                 width: 24,
                                 height: 24)
        indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        indicator.startAnimating()
        toast.addSubview(indicator)

        previousTapToDismissSetting = ToastManager.shared.isTapToDismissEnabled
        ToastManager.shared.isTapToDismissEnabled = false

        if lastIsConnected { return }

        window.showToast(toast, duration: 8, position: .bottom) { [weak self] _ in
            guard let self = self else { return }
            if self.offlineToastView === toast { self.offlineToastView = nil }

            if !self.lastIsConnected, let window = self.window {
                self.showOrRefreshOfflineToast(on: window)
            }
        }

        offlineToastView = toast
    }
}
