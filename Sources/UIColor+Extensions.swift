import UIKit

public extension UIColor {
    
    var isOpaque: Bool {
        cgColor.alpha.isEqual(to: 1.0)
    }
}
