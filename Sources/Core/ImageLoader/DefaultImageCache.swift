//
//  DefaultImageCache.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

final class DefaultImageCache {

    private let memory = NSCache<NSURL, NSData>()
    private let fileManager = FileManager()
    private let directoryURL: URL

    init(appGroupIdentifier: String? = nil) {
        if let group = appGroupIdentifier,
           let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: group) {
            directoryURL = container.appendingPathComponent("ImageCache", isDirectory: true)
        } else {
            let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            directoryURL = caches.appendingPathComponent("com.yefga.MovieBrowser.images", isDirectory: true)
        }
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        memory.countLimit = 300 // tune as needed
        memory.totalCostLimit = 64 * 1024 * 1024
    }

    func makeFileURL(for url: URL) -> URL {
        let name = url.absoluteString.data(using: .utf8)!.sha256hex
        return directoryURL.appendingPathComponent(name)
    }

    // MARK: Memory
    func memoryData(for url: URL) -> Data? {
        memory.object(forKey: url as NSURL) as Data?
    }

    func setMemory(_ data: Data, for url: URL) {
        memory.setObject(data as NSData, forKey: url as NSURL, cost: data.count)
    }

    // MARK: Disk
    func diskData(for url: URL) -> Data? {
        let fileURL = makeFileURL(for: url)
        return try? Data(contentsOf: fileURL)
    }

    func setDisk(_ data: Data, for url: URL) {
        let fileURL = makeFileURL(for: url)
        try? data.write(to: fileURL, options: .atomic)
    }

    func clearMemory() {
        memory.removeAllObjects()
    }

    func clearDisk() throws {
        if fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.removeItem(at: directoryURL)
        }
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
}

// MARK: - Utilities
private extension Data {
    var sha256hex: String {
#if canImport(CryptoKit)
        let digest = SHA256.hash(data: self)
        return digest.map { String(format: "%02x", $0) }.joined()
#else
        // Fallback (non-cryptographic) if CryptoKit not available
        return String(self.hashValue)
#endif
    }
}
