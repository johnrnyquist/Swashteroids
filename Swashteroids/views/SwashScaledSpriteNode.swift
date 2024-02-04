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

/// A Swash sprite has an Entity
class SwashSpriteNode: SKSpriteNode {
    weak var entity: Entity?
}

// Most of the time we use this to scale the sprite
class SwashScaledSpriteNode: SwashSpriteNode {
    func setup(scaleManager: ScaleManaging = ScaleManager.shared) {
        scale = scaleManager.SCALE_FACTOR
    }

    // 8
    /*
GameOverView.swift
        super.init(texture: nil, color: .clear, size: gameSize)
StartView.swift
        super.init(texture: nil, color: .clear, size: gameSize)
SwashSpriteNode.swift
        self.init(texture: texture, color: .clear, size: texture?.size() ?? .zero)
        self.init(texture: SKTexture(imageNamed: name), color: .clear, size: SKTexture(imageNamed: name).size())
        self.init(texture: nil, color: color, size: size)
        self.init(texture: texture, color: .clear, size: size)
        self.init(texture: texture, color: .clear, size: texture?.size() ?? .zero)
        self.init(texture: SKTexture(imageNamed: name), color: .clear, size: SKTexture(imageNamed: name).size())
     */
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setup()
    }

    // 3
    /*
Creator+AsteroidCreator.swift
        let sprite = SwashSpriteNode(texture: createAsteroidTexture(radius: radius, color: .asteroid))
Creator+ShipCreator.swift
        let sprite = SwashSpriteNode(texture: createShipTexture())
Creator+TorpedoCreator.swift
        let sprite = SwashSpriteNode(texture: createTorpedoTexture(color: gunComponent.torpedoColor))
     */
    convenience init(texture: SKTexture?) {
        self.init(texture: texture, color: .clear, size: texture?.size() ?? .zero)
    }

    // 20
    /*
Creator+AlienCreator.swift
        let sprite = SwashSpriteNode(imageNamed: .alienWorker)
        let sprite = SwashSpriteNode(imageNamed: .alienSoldier)
Creator+PowerUpCreator.swift
        sprite: TorpedoesPowerUpView(imageNamed: .torpedoPowerUp),
        sprite: HyperspacePowerUpView(imageNamed: .hyperspacePowerUp),
Creator+ShipButtonControlsManager.swift
        let leftButton = SwashSpriteNode(imageNamed: .leftButton)
        let rightButton = SwashSpriteNode(imageNamed: .rightButton)
        let thrustButton = SwashSpriteNode(imageNamed: .thrustButton)
        let fireButton = SwashSpriteNode(imageNamed: .fireButton)
        let flipButton = SwashSpriteNode(imageNamed: .flipButton)
        let hyperspaceButton = SwashSpriteNode(imageNamed: .hyperspaceButton)
Creator+ToggleShipControlsManager.swift
        let sprite = SwashSpriteNode(imageNamed: name)
GameOverView.swift
        let swash = SwashSpriteNode(imageNamed: "swash")
HudView.swift
        ammoView = AmmoView(circleColor: .powerUpTorpedo, size: gameSize, icon: TorpedoesPowerUpView(imageNamed: .torpedoPowerUp))
        jumpsView = AmmoView(circleColor: .powerUpHyperspace, size: gameSize, icon: HyperspacePowerUpView(imageNamed: .hyperspacePowerUp))
StartView.swift
        title = SwashSpriteNode(imageNamed: "title")
        noButtons = SwashSpriteNode(imageNamed: "nobuttons")
        buttons = SwashSpriteNode(imageNamed: "buttons")
        let leftRocks = SwashSpriteNode(imageNamed: "rocks_left")
        let rightRocks = SwashSpriteNode(imageNamed: "rocks_right")
        let ship = SwashSpriteNode(imageNamed: "ship")
     */
    convenience init(imageNamed name: String) {
        self.init(texture: SKTexture(imageNamed: name), color: .clear, size: SKTexture(imageNamed: name).size())
    }

    // 5
    /*
Creator+ShipQuadrantsControlsManager.swift
        let quadrantSprite = SwashSpriteNode(color: .black, size: CGSize(width: size.width / 2, height: size.height / 2))
Creator+TreasureCreator.swift
        let sprite = SwashSpriteNode(color: treasureData.color, size: CGSize(width: 12, height: 12))
GameOverView.swift
        let container = SwashSpriteNode(color: .clear, size: gameSize)  
HudView.swift
        pauseButton = SwashSpriteNode(color: .clear, size: CGSize(width: pauseButtonArt.size.width + pausePadding * 2.0, height: pauseButtonArt.size.height + pausePadding * 2.0 ))
Transition+InfoViews.swift
        let viewSprite = SwashSpriteNode(color: .background, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)) */
    convenience init(color: UIColor, size: CGSize) {
        self.init(texture: nil, color: color, size: size)
    }

    //MARK: - NOT IN USE ----------------
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
}

