import SpriteKit
import Swash

enum Layers: Double {
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
    private weak var inputComponent: InputComponent!
    private var numAsteroids = 0
    private var numBullets = 0

    init(engine: Engine, input: InputComponent) {
        self.engine = engine
        self.inputComponent = input
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
        let nacellesSprite = SKSpriteNode(texture: createEngineTexture())
        nacellesSprite.isHidden = true
        nacellesSprite.name = "nacelles"
        shipSprite.addChild(nacellesSprite)
        entity
                .add(component: WarpDriveComponent())
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
                .add(component: inputComponent)
        try! engine.addEntity(entity: entity)
        return entity
    }

    @discardableResult
    func createUserBullet(_ gun: GunComponent, _ parentPosition: PositionComponent, _ parentMotion: MotionComponent) -> Entity {
        let cos = cos(parentPosition.rotation * Double.pi / 180)
        let sin = sin(parentPosition.rotation * Double.pi / 180)
        let sprite = SKSpriteNode(texture: createBulletTexture(color: .bullet))
        let sparkEmiter = SKEmitterNode(fileNamed: "photon.sks")!
        sparkEmiter.emissionAngle = parentPosition.rotation * Double.pi / 180 + Double.pi
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
                .add(component: MotionComponent(velocityX: cos * 220 + parentMotion.velocity.x,
                                                velocityY: sin * 220 + parentMotion.velocity.y,
                                                angularVelocity: 0 + parentMotion.angularVelocity,
                                                damping: 0 + parentMotion.damping))
                .add(component: DisplayComponent(displayObject: sprite))
                .add(component: AudioComponent("fire.wav"))
        sprite.name = entity.name
        try? engine.addEntity(entity: entity)
        return entity
    }

    @discardableResult
    func createWaitForTap() -> Entity? {
        let waitView = WaitForStartView()
        let waitEntity = Entity(name: "wait")
                .add(component: WaitForStartComponent())
                .add(component: DisplayComponent(displayObject: waitView))
                .add(component: PositionComponent(x: 0, y: 0, z: .wait, rotation: 0))
                .add(component: inputComponent)
        do {
            try engine?.addEntity(entity: waitEntity)
        }
        catch {
            print(error)
        }
        return waitEntity
    }

    @discardableResult
    func createGameOver() -> Entity? {
        let gameOverView = GameOVerView()
        let gameOverEntity = Entity(name: "gameOver")
                .add(component: GameOverComponent())
                .add(component: DisplayComponent(displayObject: gameOverView))
                .add(component: PositionComponent(x: 0, y: 0, z: .wait, rotation: 0))
                .add(component: inputComponent)
        do {
            try engine?.addEntity(entity: gameOverEntity)
        }
        catch {
            print(error)
        }
        return gameOverEntity
    }

	func createButtons() {

		// flip
		let flipButton = SKSpriteNode(texture: createButtonTexture(color: .flipButton, text: "flip"))
		flipButton.alpha = 0.5
		flipButton.name = InputName.flipButton
		let flipx = flipButton.size.width / 2 + 30
		let flipy = flipButton.size.height + 120
		let flipButtonEntity = Entity(name: InputName.flipButton)
			.add(component: PositionComponent(x: flipx, y: flipy, z: .buttons, rotation: 0.0))
			.add(component: DisplayComponent(displayObject: flipButton))
		try! engine.addEntity(entity: flipButtonEntity)

		// left
		let leftButton = SKSpriteNode(texture: createButtonTexture(color: .leftButton, text: "left"))
		leftButton.alpha = 0.5
		leftButton.name = InputName.leftButton
		let leftx = leftButton.size.width / 2 + 30
		let lefty = leftButton.size.height / 2 + 30
		let leftButtonEntity = Entity(name: InputName.leftButton)
			.add(component: PositionComponent(x: leftx, y: lefty, z: .buttons, rotation: 0.0))
			.add(component: DisplayComponent(displayObject: leftButton))
		try! engine.addEntity(entity: leftButtonEntity)

		// right
		let rightButton = SKSpriteNode(texture: createButtonTexture(color: .rightButton, text: "right"))
		rightButton.alpha = 0.5
		rightButton.name = InputName.rightButton
		let rightx = rightButton.size.width + 30 + leftx
		let righty = lefty
		let rightButtonEntity = Entity(name: InputName.rightButton)
			.add(component: PositionComponent(x: rightx, y: righty, z: .buttons, rotation: 0.0))
			.add(component: DisplayComponent(displayObject: rightButton))
		try! engine.addEntity(entity: rightButtonEntity)

		// thrust
		let thrustButton = SKSpriteNode(texture: createButtonTexture(color: .thrustButton, text: "thrust"))
		thrustButton.alpha = 0.5
		thrustButton.name = InputName.thrustButton
		let thrustx = 1024 - thrustButton.size.width / 2 - 30
		let thrusty = lefty
		let thrustButtonEntity = Entity(name: InputName.thrustButton)
			.add(component: PositionComponent(x: thrustx, y: thrusty, z: .buttons, rotation: 0.0))
			.add(component: DisplayComponent(displayObject: thrustButton))
		try! engine.addEntity(entity: thrustButtonEntity)

		// fire
		let fireButton = SKSpriteNode(texture: createButtonTexture(color: .fireButton, text: "fire"))
		fireButton.alpha = 0.5
		fireButton.name = InputName.fireButton
		let firex = -thrustButton.size.width - 30 + thrustx
		let firey = lefty
		let fireButtonEntity = Entity(name: InputName.fireButton)
			.add(component: PositionComponent(x: firex, y: firey, z: .buttons, rotation: 0.0))
			.add(component: DisplayComponent(displayObject: fireButton))
		try! engine.addEntity(entity: fireButtonEntity)

		// hyperSpace
		let hyperSpaceButton = SKSpriteNode(texture: createButtonTexture(color: .hyperSpaceButton, text: "hyperspace"))
		hyperSpaceButton.alpha = 0.5
		hyperSpaceButton.name = InputName.hyperSpaceButton
		let hyperSpacex = 1024 - thrustButton.size.width / 2 - 30
		let hyperSpacey = hyperSpaceButton.size.height + 120
		let hyperSpaceButtonEntity = Entity(name: InputName.hyperSpaceButton)
			.add(component: PositionComponent(x: hyperSpacex, y: hyperSpacey, z: .buttons, rotation: 0.0))
			.add(component: DisplayComponent(displayObject: hyperSpaceButton))
		try! engine.addEntity(entity: hyperSpaceButtonEntity)
	}

    @discardableResult
	func createAsteroid(radius: Double, x: Double, y: Double, color: UIColor = .asteroid) -> Entity {
		let sprite = SKSpriteNode(texture: createAsteroidTexture(radius: radius, color: color))
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
