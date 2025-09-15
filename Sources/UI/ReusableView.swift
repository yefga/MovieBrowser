//
//  ReusableView.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit

// MARK: - ReusableView Protocol
// A protocol for providing a reuse identifier, typically for table/collection view cells.
public protocol ReusableView: AnyObject {
    /// Returns the reuse identifier for the view, which is its class name by default.
    static var reuseIdentifier: String { get }
}

// MARK: - ReusableView Extension
// Default implementation for any UIView that conforms to ReusableView.
public extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        // The reuse identifier is the name of the class.
        return String(describing: self)
    }
}

// MARK: - UITableViewCell Conformance
// Make UITableViewCell conform to ReusableView by default.
extension UITableViewCell: ReusableView {}

// MARK: - UITableView Helper Extensions
public extension UITableView {
    
    func registerClass<T: UITableViewCell>(forCellClass cellClass: T.Type) {
        let identifier = cellClass.reuseIdentifier
        register(cellClass, forCellReuseIdentifier: identifier)
    }
    /// Registers a cell for reuse. The cell must conform to `ReusableView`.
    /// The nib file is assumed to have the same name as the cell class.
    ///
    /// - Parameter cellClass: The cell class to register (e.g., `MyCustomCell.self`).
    func register<T: UITableViewCell>(nibForCellClass cellClass: T.Type) {
        let identifier = cellClass.reuseIdentifier
        let nib = UINib(nibName: identifier, bundle: Bundle(for: cellClass))
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    /// Dequeues a reusable cell in a type-safe way.
    ///
    /// - Parameter indexPath: The index path specifying the location of the cell.
    /// - Returns: A fully typed instance of your `UITableViewCell` subclass.
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}
