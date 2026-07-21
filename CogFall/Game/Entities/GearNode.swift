import SpriteKit
import SwiftUI

/// A poolable gear entity: SKShapeNode cog body + glow, with a circular physics body.
final class GearNode: SKNode {
    private(set) var sizeClass: GearSize = .medium
    var radius: CGFloat { sizeClass.radius }

    private let body = SKShapeNode()
    private let glow = SKShapeNode()

    private(set) var isPowered = false
    /// Rusted solid: sat unpowered too long, can no longer conduct drive.
    private(set) var isSeized = false
    var isSettled = false
    var isLive = false
    var settleTimer: TimeInterval = 0
    var dropTime: TimeInterval = 0
    /// Seconds this settled gear has spent off the powered chain.
    var idleTime: TimeInterval = 0

    override init() {
        super.init()
        glow.zPosition = -1
        addChild(glow)
        addChild(body)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    /// Reconfigure for reuse from the pool.
    func configure(size: GearSize) {
        sizeClass = size
        let r = size.radius
        glow.path = CGPath(ellipseIn: CGRect(x: -r * 1.5, y: -r * 1.5, width: r * 3, height: r * 3), transform: nil)
        glow.fillColor = UIColor(Palette.power)
        glow.strokeColor = .clear
        glow.alpha = 0
        body.path = GearNode.gearPath(radius: r)
        body.lineWidth = 1.6
        isPowered = false; isSettled = false; isLive = false; settleTimer = 0
        isSeized = false; idleTime = 0
        zRotation = 0
        setPowered(false, animated: false)
        attachPhysics(dynamic: false)
    }

    func attachPhysics(dynamic: Bool) {
        let pb = SKPhysicsBody(circleOfRadius: radius * 0.94)
        pb.categoryBitMask = PhysicsCategory.gear
        pb.collisionBitMask = PhysicsCategory.gear | PhysicsCategory.wall | PhysicsCategory.spindle
        pb.contactTestBitMask = 0
        pb.restitution = 0.03
        pb.friction = 0.95
        pb.linearDamping = 0.85
        pb.angularDamping = 0.9
        pb.allowsRotation = true
        pb.isDynamic = dynamic
        physicsBody = pb
    }

    /// Rusts the gear solid: it can never carry drive again and bleeds heat.
    func seize() {
        guard !isSeized else { return }
        isSeized = true
        setPowered(false)
        body.fillColor = UIColor(Palette.rust)
        body.strokeColor = UIColor(Palette.rustDeep)
        run(.sequence([.scale(to: 0.92, duration: 0.1), .scale(to: 1.0, duration: 0.14)]))
    }

    func setPowered(_ on: Bool, animated: Bool = true) {
        guard !(isSeized && on) else { return }
        isPowered = on
        if isSeized {
            body.fillColor = UIColor(Palette.rust)
            body.strokeColor = UIColor(Palette.rustDeep)
            glow.alpha = 0
            removeAction(forKey: "spin")
            return
        }
        body.fillColor = on ? UIColor(Palette.brass) : UIColor(Palette.steel)
        body.strokeColor = on ? UIColor(Palette.brassEdge) : UIColor(Palette.steelEdge)
        if animated {
            glow.run(.fadeAlpha(to: on ? 0.45 : 0.0, duration: 0.25))
        } else {
            glow.alpha = on ? 0.45 : 0.0
        }
        if on {
            if action(forKey: "spin") == nil {
                let cw = Int(position.x / 20) % 2 == 0
                run(.repeatForever(.rotate(byAngle: (cw ? 1 : -1) * .pi, duration: 2.6)), withKey: "spin")
            }
        } else {
            removeAction(forKey: "spin")
        }
    }

    func recycle() {
        removeAllActions()
        physicsBody = nil
        isPowered = false; isSettled = false; isLive = false; settleTimer = 0
        isSeized = false; idleTime = 0
        glow.alpha = 0
        zRotation = 0
        removeFromParent()
    }

    static func gearPath(radius R: CGFloat, teeth: Int = 12) -> CGPath {
        let path = CGMutablePath()
        let bodyR = R * 0.74
        path.addEllipse(in: CGRect(x: -bodyR, y: -bodyR, width: bodyR * 2, height: bodyR * 2))
        let tw = R * 0.26
        let th = R * 0.32
        for i in 0..<teeth {
            let a = CGFloat(i) / CGFloat(teeth) * 2 * .pi
            let rect = CGRect(x: -tw / 2, y: R - th, width: tw, height: th)
            let tooth = CGPath(roundedRect: rect, cornerWidth: tw * 0.25, cornerHeight: tw * 0.25, transform: nil)
            let t = CGAffineTransform(rotationAngle: a)
            path.addPath(tooth, transform: t)
        }
        return path
    }
}
