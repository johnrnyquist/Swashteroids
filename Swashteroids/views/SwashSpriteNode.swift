//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import Swash

// Is this to much of a cheat?
class SwashSpriteNode: SKSpriteNode {
    weak var entity: Entity?

    func setup(scaleManager: ScaleManaging = ScaleManager.shared) {
        scale = scaleManager.SCALE_FACTOR
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    convenience init(texture: SKTexture?, size: CGSize) {
        self.init(texture: texture, color: .clear, size: size)
    }

    convenience init(texture: SKTexture?, normalMap: SKTexture?) {
        self.init(texture: texture, color: .clear, size: texture?.size() ?? .zero)
    }

    convenience init(imageNamed name: String, normalMapped generateNormalMap: Bool) {
        self.init(texture: SKTexture(imageNamed: name), color: .clear, size: SKTexture(imageNamed: name).size())
    }

    convenience init(texture: SKTexture?) {
        self.init(texture: texture, color: .clear, size: texture?.size() ?? .zero)
    }

    convenience init(imageNamed name: String) {
        self.init(texture: SKTexture(imageNamed: name), color: .clear, size: SKTexture(imageNamed: name).size())
    }

    convenience init(color: UIColor, size: CGSize) {
        self.init(texture: nil, color: color, size: size)
    }
}

