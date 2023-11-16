import SpriteKit
import Swash

enum Layers: CGFloat {
    case asteroids
    case bullet
    case ship
    case hud
    case buttons
    case wait
}

class GunSupplierComponent: Component {}

/// EntityCreator is a bunch of convenience methods that create and configure entities, then adds them to its engine.
class EntityCreator {
    private weak var engine: Engine!
//    private var waitEntity: Entity?
    private var numAsteroids = 0
    private var numBullets = 0

    init(engine: Engine) {
        self.engine = engine
    }

    @discardableResult
    func createGunSupplier(radius: Double = 7, x: Double = 512, y: Double = 484) -> Entity {
        let sprite = GunSupplierView(texture: createGunSupplierTexture(radius: radius, color: .cyan))
        let entity = Entity(name: "gunSupplier")
        sprite.name = entity.name
        entity
                .add(component: PositionComponent(x: Double.random(in: 200...824),
                                                  y: Double.random(in: 200...568),
                                                  z: .asteroids,
                                                  rotation: 0.0))
                .add(component: CollisionComponent(radius: radius))
                .add(component: GunSupplierComponent())
                .add(component: DisplayComponent(displayObject: sprite))
                .add(component: AnimationComponent(animation: sprite))
        try! engine.addEntity(entity: entity)
        return entity
    }

    @discardableResult
    func createHud() -> Entity {
        // Here we create a subclass of entity
        let hudView = HudView()
        let hudEntity = HudEntity(name: "hud", view: hudView)
        try! engine.addEntity(entity: hudEntity)
        return hudEntity
    }

    @discardableResult
    func createShip() -> Entity {
        let shipSprite = SKSpriteNode(texture: createShipTexture())
        let entity = Entity()
        entity.name = "ship"
        shipSprite.name = entity.name
        let engineSprite = SKSpriteNode(texture: createEngineTexture())
        engineSprite.isHidden = true
        engineSprite.name = "engine"
        shipSprite.addChild(engineSprite)
        entity
                .add(component: EngineComponent())
                .add(component: AudioComponent())
                .add(component: GunControlsComponent())
                .add(component: PositionComponent(x: 512, y: 384, z: .ship, rotation: 0.0))
                .add(component: ShipComponent())
                .add(component: MotionComponent(velocityX: 0.0,
                                                velocityY: 0.0))
                .add(component: CollisionComponent(radius: 25))
                .add(component: DisplayComponent(displayObject: shipSprite))
                .add(component: MotionControlsComponent(left: 1,
                                                        right: 2,
                                                        accelerate: 4,
                                                        accelerationRate: 90,
                                                        rotationRate: 100))
        try! engine.addEntity(entity: entity)
        return entity
    }

    @discardableResult
    func createUserBullet(_ gun: GunComponent, _ parentPosition: PositionComponent, _ parentMotion: MotionComponent, dir: Double = 1.0) -> Entity {
        let cos = cos(parentPosition.rotation * Double.pi / 180)
        let sin = sin(parentPosition.rotation * Double.pi / 180)
        let sprite = SKSpriteNode(texture: createBulletTexture(color: dir > 0 ? .green : .yellow))
        let sparkEmiter = SKEmitterNode(fileNamed: "photon.sks")!
        sparkEmiter.emissionAngle = parentPosition.rotation * Double.pi / 180 + (dir > 0 ? Double.pi : 0)
        sprite.addChild(sparkEmiter)
        numBullets += 1
        let entity = Entity(name: "bullet_\(numBullets)")
                .add(component: BulletComponent(lifeRemaining: gun.bulletLifetime))
                .add(component: PositionComponent(x: cos * gun.offsetFromParent.x - sin * gun.offsetFromParent
                                                                                             .y + parentPosition.position
                                                                                                                .x,
                                                  y: sin * gun.offsetFromParent.x + cos * gun.offsetFromParent
                                                                                             .y + parentPosition.position
                                                                                                                .y,
                                                  z: Layers.bullet,
                                                  rotation: 0))
                .add(component: CollisionComponent(radius: 0))
                .add(component: MotionComponent(velocityX: dir * cos * 220 + parentMotion.velocity.x,
                                                velocityY: dir * sin * 220 + parentMotion.velocity.y,
                                                angularVelocity: 0 + parentMotion.angularVelocity,
                                                damping: 0 + parentMotion.damping))
                .add(component: DisplayComponent(displayObject: sprite))
                .add(component: AudioComponent("fire.wav"))
        sprite.name = entity.name
        try? engine.addEntity(entity: entity)
        return entity
    }

    @discardableResult
    func createWaitForClick() -> Entity? {
//        if waitEntity == nil {
        let waitView: WaitForStartView = WaitForStartView()
        let waitEntity = Entity(name: "wait")
                .add(component: WaitForStartComponent())
                .add(component: DisplayComponent(displayObject: waitView))
                .add(component: PositionComponent(x: 0, y: 0, z: .wait, rotation: 0))
//        }
//        guard let waitEntity else { return nil }
        do {
            try engine?.addEntity(entity: waitEntity)
        }
        catch {
            print(error)
        }
        return waitEntity
    }

    func createButtons() {
		// flip
		let flipButton = SKSpriteNode(texture: createButtonTexture(color: .systemYellow))
		flipButton.alpha = 0.5
		flipButton.name = "flipButton"
		let flipx = flipButton.size.width / 2 + 30
		let flipy = flipButton.size.height + 120
		let flipButtonEntity = Entity(name: "flipButton")
			.add(component: PositionComponent(x: flipx, y: flipy, z: .buttons, rotation: 0.0))
			.add(component: DisplayComponent(displayObject: flipButton))
		try! engine.addEntity(entity: flipButtonEntity)
		// left
		let leftButton = SKSpriteNode(texture: createButtonTexture(color: .white))
		leftButton.alpha = 0.5
		leftButton.name = "leftButton"
		let leftx = leftButton.size.width / 2 + 30
		let lefty = leftButton.size.height / 2 + 30
		let leftButtonEntity = Entity(name: "leftButton")
			.add(component: PositionComponent(x: leftx, y: lefty, z: .buttons, rotation: 0.0))
			.add(component: DisplayComponent(displayObject: leftButton))
		try! engine.addEntity(entity: leftButtonEntity)
        // right
        let rightButton = SKSpriteNode(texture: createButtonTexture(color: .white))
        rightButton.alpha = 0.5
        rightButton.name = "rightButton"
        let rightx = rightButton.size.width + 30 + leftx
        let righty = lefty
        let rightButtonEntity = Entity(name: "rightButton")
                .add(component: PositionComponent(x: rightx, y: righty, z: .buttons, rotation: 0.0))
                .add(component: DisplayComponent(displayObject: rightButton))
        try! engine.addEntity(entity: rightButtonEntity)
        // fire
        let fireButton = SKSpriteNode(texture: createButtonTexture(color: .systemGreen))
        fireButton.alpha = 0.5
        fireButton.name = "thrustButton"
        let firex = 1024 - fireButton.size.width / 2 - 30
        let firey = lefty
        let fireButtonEntity = Entity(name: "thrustButton")
                .add(component: PositionComponent(x: firex, y: firey, z: .buttons, rotation: 0.0))
                .add(component: DisplayComponent(displayObject: fireButton))
        try! engine.addEntity(entity: fireButtonEntity)
        // thrust
        let thrustButton = SKSpriteNode(texture: createButtonTexture(color: .systemRed))
        thrustButton.alpha = 0.5
        thrustButton.name = "fireButton"
        let thrustx = -fireButton.size.width - 30 + firex
        let thrusty = lefty
        let thrustButtonEntity = Entity(name: "fireButton")
                .add(component: PositionComponent(x: thrustx, y: thrusty, z: .buttons, rotation: 0.0))
                .add(component: DisplayComponent(displayObject: thrustButton))
        try! engine.addEntity(entity: thrustButtonEntity)
    }

    @discardableResult
    func createAsteroid(radius: Double, x: Double, y: Double) -> Entity {
        let sprite = SKSpriteNode(texture: createAsteroidTexture(radius: radius))
        let entity = Entity()
        numAsteroids += 1
        entity.name = "asteroid_\(numAsteroids)"
        sprite.name = entity.name
        entity
                .add(component: PositionComponent(x: x, y: y, z: .asteroids, rotation: 0.0))
                .add(component: MotionComponent(velocityX: Double.random(in: -82.0...82.0),
                                                velocityY: Double.random(in: -82.0...82.0),
                                                angularVelocity: Double.random(in: -100.0...100.0),
                                                damping: 0))
                .add(component: CollisionComponent(radius: radius))
                .add(component: AsteroidComponent())
                .add(component: DisplayComponent(displayObject: sprite))
                .add(component: AudioComponent())
        try! engine.addEntity(entity: entity)
        return entity
    }

    func createAsteroids(_ n: Int) {
        for _ in 1...n {
            createAsteroid(radius: LARGE_ASTEROID_RADIUS,
                           x: Double.random(in: 0.0...1024.0),
                           y: Double.random(in: 0...768.0))
        }
    }

    func destroyEntity(_ entity: Entity) {
        engine.removeEntity(entity: entity)
    }
}
