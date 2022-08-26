import UIKit

public extension UIBezierPath {
    
    static func smoothPathTopLeft(in rect: CGRect, cornerRadius: CGFloat) -> (UIBezierPath, CGSize) {
        let path = UIBezierPath()

        guard rect.size != .zero else {
            assert(false, "Cannot build a smoothPath with a size of 0")
            return (path, .zero)
        }

        let width = rect.width
        let height = rect.height
        let left = rect.minX
        let top = rect.minY
        let minSide = min(width, height)
        let minFactor = minSide

        let heightLimit = rect.height * 0.5
        let widthLimit = rect.width * 0.5
        let clampedCornerRadius = min(ceil(cornerRadius), min(heightLimit, widthLimit))
        let minsize = min(min(ceil(clampedCornerRadius * 1.5), heightLimit), widthLimit)

        let vertexRatio = computeVertexRatio(
            radius: clampedCornerRadius,
            size: .init(width: minsize, height: minsize),
            widthLimit: minsize,
            heightLimit: minsize
        )
        
        let controlRatio = computeControlRatio(
            radius: clampedCornerRadius,
            size: .init(width: minsize, height: minsize),
            widthLimit: minsize, heightLimit: minsize
        )

        let size = CGSize(
            width: floor(left + min(max(minsize, minsize - clampedCornerRadius * 1.2819 * vertexRatio), minsize)),
            height: floor(min(top + max(minsize, minsize - clampedCornerRadius * 1.12819 * vertexRatio), minsize))
        )

        return (path..{
            $0.move(to: .init(x: left + max(minsize, minsize - clampedCornerRadius * 1.2819 * vertexRatio), y: top))
            $0.addLine(to: .init(x: size.width, y: size.height))
            $0.addLine(to: .init(x: left, y: size.height))

            $0.addCurve(to: .init(x: left + clampedCornerRadius * 0.1336, y: top + clampedCornerRadius * 0.5116),
                        controlPoint1: .init(x: left, y: top + clampedCornerRadius * 0.8362 * controlRatio),
                        controlPoint2: .init(x: left + clampedCornerRadius * 0.0464, y: top + clampedCornerRadius * 0.6745))

            $0.addCurve(to: .init(x: left + clampedCornerRadius * 0.5116, y: top + clampedCornerRadius * 0.1336),
                        controlPoint1: .init(x: left + clampedCornerRadius * 0.2207, y: top + clampedCornerRadius * 0.3486),
                        controlPoint2: .init(x: left + clampedCornerRadius * 0.3486, y: top + clampedCornerRadius * 0.2207))

            $0.addCurve(to: .init(x: left + min(minFactor, clampedCornerRadius * 1.2819 * vertexRatio), y: top),
                        controlPoint1: .init(x: left + clampedCornerRadius * 0.6745, y: top + clampedCornerRadius * 0.0464),
                        controlPoint2: .init(x: left + clampedCornerRadius * 0.8362 * controlRatio, y: top))
            }, size)
    }
    
    // MARK: - Private Methods

    private static func computeVertexRatio(
        radius: CGFloat,
        size: CGSize,
        widthLimit: CGFloat,
        heightLimit: CGFloat
    ) -> CGFloat {
        let minMidDimension = min(widthLimit, heightLimit)

        guard radius / minMidDimension > 0.5 else {
            return 1
        }

        let percentage = ((radius / minMidDimension) - 0.5) / 0.4
        let clampedPer = min(1, percentage)
        
        return 1 - (1 - 1.104 / 1.2819) * clampedPer
    }

    private static func computeControlRatio(
        radius: CGFloat,
        size: CGSize,
        widthLimit: CGFloat,
        heightLimit: CGFloat
    ) -> CGFloat {
        let minMidDimension = min(widthLimit, heightLimit)

        guard radius / minMidDimension > 0.6 else {
            return 1
        }

        let percentage = ((radius / minMidDimension) - 0.6) / 0.3
        let clampedPer = min(1, percentage)
        
        return 1 + (0.8717 / 0.8362 - 1) * clampedPer
    }
}
