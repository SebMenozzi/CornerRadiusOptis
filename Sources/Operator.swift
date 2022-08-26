import Foundation

infix operator .. : MultiplicationPrecedence

@discardableResult
public func .. <T>(object: T, block: (inout T) -> Void) -> T {
    var object = object
    block(&object)
    return object
}
