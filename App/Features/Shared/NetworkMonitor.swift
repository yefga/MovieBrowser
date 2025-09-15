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

/// A singleton that monitors network connectivity and shows a persistent toast
/// when the device is offline. The toast is hidden automatically when the
/// connection is restored.
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

    /// Starts monitoring connectivity for the given window and manages the offline toast.
    /// - Parameter window: The app's main window on which to present the toast.
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

    /// Stops monitoring and hides any active offline toast.
    func stop() {
        guard isMonitoring else { return }
        isMonitoring = false
        monitor.cancel()

        DispatchQueue.main.async {
            if let window = self.window, let toast = self.offlineToastView {
                window.hideToast(toast)
                self.offlineToastView = nil
            }
            // Restore tap-to-dismiss if we modified it
            ToastManager.shared.isTapToDismissEnabled = self.previousTapToDismissSetting
        }
    }

    // MARK: - Private

    private func handlePathUpdate(_ path: NWPath) {
        let isConnected = (path.status == .satisfied)
        lastIsConnected = isConnected
        if isConnected {
            // Hide offline toast if showing
            if let window = window, let toast = offlineToastView {
                window.hideToast(toast)
                offlineToastView = nil
            }
            // Restore global tap-to-dismiss
            ToastManager.shared.isTapToDismissEnabled = previousTapToDismissSetting
        } else {
            guard let window = window else { return }
            showOrRefreshOfflineToast(on: window)
        }
    }

    /// Presents the offline toast if not already visible, adds a spinner, and
    /// uses the completion handler to re-show it while still offline.
    private func showOrRefreshOfflineToast(on window: UIWindow) {
        // If already showing, do nothing — the completion will handle refresh
        if offlineToastView != nil { return }

        var style = ToastManager.shared.style
        style.backgroundColor = UIColor.systemRed.withAlphaComponent(0.92)
        style.messageColor = .white
        style.messageAlignment = .center
        style.cornerRadius = 12
        style.displayShadow = false

        // Use a title as a retry hint and message for clarity
        let toastView = try? window.toastViewForMessage(
            "No Internet Connection",
            title: "Trying to reconnect…",
            image: nil,
            style: style
        )
        guard let toast = toastView else { return }

        // Add a small activity indicator to the toast view
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

        // Ensure the toast cannot be dismissed by tap while offline
        previousTapToDismissSetting = ToastManager.shared.isTapToDismissEnabled
        ToastManager.shared.isTapToDismissEnabled = false

        // Show for a short duration and refresh as long as we're offline
        window.showToast(toast, duration: 8, position: .bottom) { [weak self] _ in
            guard let self = self else { return }
            // Clear the reference since the toast has completed its cycle
            if self.offlineToastView === toast { self.offlineToastView = nil }

            // If still offline, show again to keep it persistent
            if !self.lastIsConnected, let window = self.window {
                self.showOrRefreshOfflineToast(on: window)
            }
        }

        offlineToastView = toast
    }
}
