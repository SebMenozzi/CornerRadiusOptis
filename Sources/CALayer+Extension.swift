import UIKit

extension CALayer {
    
    class func performWithoutAnimations(_ actions: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        actions()
        CATransaction.commit()
    }
}
