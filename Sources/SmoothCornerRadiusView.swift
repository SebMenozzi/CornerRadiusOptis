import Foundation
import UIKit

open class SmoothCornerRadiusView: UIView {
    
    // MARK: - Public Properties
    
    public let colorBehindView: UIColor
    public let colorInsideOfCorners: UIColor
    open var cornerRadius: CGFloat {
        didSet {
            cornerRadius = min(cornerRadius, bounds.width / 2)
            cornerRadius = min(cornerRadius, bounds.height / 2)
            cornerRadius = max(cornerRadius, 0)
            cornerRadius = ceil(cornerRadius)
            
            updatePath()
        }
    }
    open var useSmoothCorners: Bool {
        didSet {
            if useSmoothCorners != oldValue {
                updatePath()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var previousSize: CGSize = .zero
    private var cornerLayer: CALayer
    
    private var centerRectangleLayer: CALayer
    
    private var cornerHorizontalAxisReplicatorLayer: CAReplicatorLayer
    private var cornerVerticalAxisReplicatorLayer: CAReplicatorLayer
    
    private var sideHorizontalRectangleLayer: CALayer
    private var sideVerticalRectangleLayer: CALayer
    
    private var sideHorizontalRectangleReplicatorLayer: CAReplicatorLayer
    private var sideVerticalRectangleReplicatorLayer: CAReplicatorLayer
    
    public init(
        colorBehindView: UIColor,
        colorInsideOfCorners: UIColor,
        cornerRadius: CGFloat,
        frame: CGRect,
        useSmoothCorners: Bool = false
    ) {
        self.colorBehindView = colorBehindView
        self.colorInsideOfCorners = colorInsideOfCorners
        self.cornerRadius = cornerRadius
        self.useSmoothCorners = useSmoothCorners
        
        self.cornerLayer = CALayer()
        
        self.centerRectangleLayer = CALayer()
        
        self.cornerHorizontalAxisReplicatorLayer = CAReplicatorLayer()
        self.cornerVerticalAxisReplicatorLayer = CAReplicatorLayer()
        
        self.sideHorizontalRectangleLayer = CALayer()
        self.sideVerticalRectangleLayer = CALayer()
        
        self.sideHorizontalRectangleReplicatorLayer = CAReplicatorLayer()
        self.sideVerticalRectangleReplicatorLayer = CAReplicatorLayer()
        
        super.init(frame: frame)
        
        isOpaque = colorBehindView.isOpaque && colorInsideOfCorners.isOpaque
        cornerLayer.isOpaque = isOpaque
        
        setupCornerReplicators()
        setupSideRectangleReplicators()
        setupCenterRectangle()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        if !previousSize.equalTo(bounds.size) {
            previousSize = bounds.size

            updatePath()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupCornerReplicators() {
        cornerHorizontalAxisReplicatorLayer.instanceCount = 2
        cornerVerticalAxisReplicatorLayer.instanceCount = 2
        
        cornerHorizontalAxisReplicatorLayer.addSublayer(cornerLayer)
        cornerVerticalAxisReplicatorLayer.addSublayer(cornerHorizontalAxisReplicatorLayer)
        layer.addSublayer(cornerVerticalAxisReplicatorLayer)
    }
    
    private func setupSideRectangleReplicators() {
        sideHorizontalRectangleLayer.backgroundColor = colorInsideOfCorners.cgColor
        sideHorizontalRectangleLayer.isOpaque = colorInsideOfCorners.isOpaque
        
        sideHorizontalRectangleReplicatorLayer.instanceCount = 2
        sideHorizontalRectangleReplicatorLayer.addSublayer(sideHorizontalRectangleLayer)
        layer.addSublayer(sideHorizontalRectangleReplicatorLayer)
        
        sideVerticalRectangleLayer.backgroundColor = colorInsideOfCorners.cgColor
        sideVerticalRectangleLayer.isOpaque = colorInsideOfCorners.isOpaque
        
        sideVerticalRectangleReplicatorLayer.instanceCount = 2
        sideVerticalRectangleReplicatorLayer.addSublayer(sideVerticalRectangleLayer)
        layer.addSublayer(sideVerticalRectangleReplicatorLayer)
    }
    
    private func setupCenterRectangle() {
        centerRectangleLayer.backgroundColor = colorInsideOfCorners.cgColor
        centerRectangleLayer.isOpaque = colorInsideOfCorners.isOpaque
        layer.addSublayer(centerRectangleLayer)
    }
    
    private func updatePath() {
        CALayer.performWithoutAnimations {
            let (cornerImage, cornerSize) = createCornerViewImage()
            
            cornerLayer.contents = cornerImage.cgImage
            cornerLayer.frame = CGRect(x: 0.0, y: 0.0, width: cornerSize.width, height: cornerSize.height)
            
            cornerHorizontalAxisReplicatorLayer.isHidden = cornerRadius == 0
            sideHorizontalRectangleReplicatorLayer.isHidden = cornerSize.width >= ceil(bounds.width / 2)
            sideVerticalRectangleReplicatorLayer.isHidden = cornerSize.height >= ceil(bounds.height / 2)
            centerRectangleLayer.isHidden = cornerSize.width >= ceil(bounds.width / 2) && cornerSize.height >= ceil(bounds.height / 2)
            
            centerRectangleLayer.frame = CGRect(x: cornerSize.width, y: cornerSize.height, width: bounds.width - 2 * cornerSize.width, height: bounds.height - 2 * cornerSize.height)
            sideHorizontalRectangleLayer.frame = CGRect(x: cornerSize.width, y: 0, width: bounds.width - 2 * cornerSize.width, height: cornerSize.height)
            sideVerticalRectangleLayer.frame = CGRect(x: 0, y: cornerSize.height, width: cornerSize.width, height: bounds.height - 2 * cornerSize.height)
        
            cornerHorizontalAxisReplicatorLayer.instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(-1.0, 1.0, 1.0), -bounds.width, 0.0, 0.0)
            
            cornerVerticalAxisReplicatorLayer.instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(1.0, -1.0, 1.0), 0.0, -bounds.height, 0.0)
            
            sideVerticalRectangleReplicatorLayer.instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(-1.0, 1.0, 1.0), -bounds.width, 0.0, 0.0)
            
            sideHorizontalRectangleReplicatorLayer.instanceTransform = CATransform3DTranslate(CATransform3DMakeScale(1.0, -1.0, 1.0), 0.0, -bounds.height, 0.0)
        }
    }
    
    private func createCornerViewImage() -> (UIImage, CGSize) {
        /*
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .topLeft,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        let magicFactor = 1.52866483
        let cornerSize: CGSize = .init(width: cornerRadius * magicFactor, height: cornerRadius * magicFactor)
        */
        
        let path: UIBezierPath
        let cornerSize: CGSize
        
        if useSmoothCorners {
            (path, cornerSize) = UIBezierPath.smoothPathTopLeft(in: bounds, cornerRadius: cornerRadius)
        } else {
            path = UIBezierPath()..{
                $0.move(to: .init(x: 0, y: cornerRadius))
                $0.addArc(withCenter: .init(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi / 2, clockwise: true)
                $0.addLine(to: .init(x: cornerRadius, y: cornerRadius))
            }
            cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        }
        
        let finalRect = CGRect(
            origin: .zero,
            size: cornerSize
        )

        let format = UIGraphicsImageRendererFormat()
        format.opaque = isOpaque
        
        let renderer = UIGraphicsImageRenderer(
            size: finalRect.size,
            format: format
        )
        
        let cornerImage = renderer.image { ctx in
            ctx.cgContext.setFillColor(colorInsideOfCorners.cgColor)
            ctx.cgContext.addPath(path.cgPath)
            ctx.cgContext.fillPath()
            
            ctx.cgContext.setFillColor(colorBehindView.cgColor)
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 0.0, y: finalRect.height))
            path.addLine(to: CGPoint(x: finalRect.width, y: finalRect.height))
            path.addLine(to: CGPoint(x: finalRect.width, y: 0.0))
            path.addLine(to: .zero)
            ctx.cgContext.addPath(path.cgPath)
            ctx.cgContext.fillPath()
        }
        
        return (cornerImage, cornerSize)
    }
}
