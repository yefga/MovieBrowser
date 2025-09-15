import UIKit

public extension UIImage {
    enum Symbol: String {
        case magnifyingglass
        case xmark
        case heart
        case heartFill = "heart.fill"
        case photo
        case sunMaxFill = "sun.max.fill"
        case moonFill = "moon.fill"
        case exclamationmarkTriangle = "exclamationmark.triangle"
    }

    /// Convenience factory for SF Symbol images used in the app.
    static func symbol(_ symbol: Symbol) -> UIImage? {
        return UIImage(systemName: symbol.rawValue)
    }
}
