//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import SpriteKit

class ShipQuadrantsControlsCreator: ShipQuadrantsControlsCreatorUseCase {
    private var engine: Engine
    private var size: CGSize
    private var generator: UIImpactFeedbackGenerator?

    init(engine: Engine, size: CGSize, generator: UIImpactFeedbackGenerator?) {
        self.engine = engine
        self.size = size
        self.generator = generator
    }

    func removeShipControlQuadrants() {
        let quadrants: [EntityName] = [.q1, .q2, .q3, .q4]
        engine.removeEntities(named: quadrants)
    }

    func createQuadrantSprite(quadrant: Int, entity: Entity) -> SwashSpriteNode {
        let position: CGPoint
        switch quadrant {
        case 1:
            position = CGPoint(x: 0, y: size.height / 2)
        case 2:
            position = CGPoint(x: size.width / 2, y: size.height / 2)
        case 3:
            position = CGPoint(x: 0, y: 0)
        case 4:
            position = CGPoint(x: size.width / 2, y: 0)
        default:
            position = .zero
        }
        let quadrantSprite = SwashSpriteNode(color: .black, size: CGSize(width: size.width / 2, height: size.height / 2))
        quadrantSprite.anchorPoint = CGPoint(x: 0, y: 0)
        quadrantSprite.position = position
        quadrantSprite.entity = entity
        return quadrantSprite
    }

    /// Instead of visible buttons, the player will be able to touch quadrants on the screen to control the ship.
    func createShipControlQuadrants() {
        // Create the entities
        let q1Entity = Entity(named: .q1)
        let q2Entity = Entity(named: .q2)
        let q3Entity = Entity(named: .q3)
        let q4Entity = Entity(named: .q4)
        // Create the sprites, with associated entities
        let q1Sprite = createQuadrantSprite(quadrant: 1, entity: q1Entity)
        let q2Sprite = createQuadrantSprite(quadrant: 2, entity: q2Entity)
        let q3Sprite = createQuadrantSprite(quadrant: 3, entity: q3Entity)
        let q4Sprite = createQuadrantSprite(quadrant: 4, entity: q4Entity)
        q1Sprite.name = .q1
        q2Sprite.name = .q2
        q3Sprite.name = .q3
        q4Sprite.name = .q4
        // Add the entities to the engine
        engine.add(entity: q1Entity)
        engine.add(entity: q2Entity)
        engine.add(entity: q3Entity)
        engine.add(entity: q4Entity)
        // Configure the entities
        q1Entity
                .add(component: DisplayComponent(sknode: q1Sprite))
                .add(component: PositionComponent(x: q1Sprite.x, y: q1Sprite.y, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator?.impactOccurred()
                        if let ship = self.engine.ship,
                           ship.has(componentClassName: HyperspaceDriveComponent.name) {
                            engine.ship?.add(component: DoHyperspaceJumpComponent(size: size))
                        }
                    },
                    touchUp: { _ in },
                    touchUpOutside: { _ in },
                    touchMoved: { _, _ in }
                ))
        q2Entity
                .add(component: DisplayComponent(sknode: q2Sprite))
                .add(component: PositionComponent(x: q2Sprite.x, y: q2Sprite.y, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator?.impactOccurred()
                        engine.ship?.add(component: FlipComponent.shared)
                    },
                    touchUp: { _ in },
                    touchUpOutside: { _ in },
                    touchMoved: { _, _ in }
                ))
        q3Entity
                .add(component: DisplayComponent(sknode: q3Sprite))
                .add(component: PositionComponent(x: q3Sprite.x, y: q3Sprite.y, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator?.impactOccurred()
                        if let ship = self.engine.ship {
                            ship.add(component: ApplyThrustComponent.shared)
                            ship[WarpDriveComponent.self]?.isThrusting = true
                            ship[RepeatingAudioComponent.self]?.state = .shouldBegin
                        }
                    },
                    touchUp: { sprite in
                        if let ship = self.engine.ship {
                            ship.remove(componentClass: ApplyThrustComponent.self)
                            ship[WarpDriveComponent.self]?.isThrusting = false
                            ship[RepeatingAudioComponent.self]?.state = .shouldStop
                        }
                    },
                    touchUpOutside: { sprite in
                        if let ship = self.engine.ship {
                            ship.remove(componentClass: ApplyThrustComponent.self)
                            ship[WarpDriveComponent.self]?.isThrusting = false
                            ship[RepeatingAudioComponent.self]?.state = .shouldStop
                        }
                    },
                    touchMoved: { sprite, over in
                        if over {
                            if let ship = self.engine.ship {
                                ship.add(component: ApplyThrustComponent.shared)
                                ship[WarpDriveComponent.self]?.isThrusting = true
                                ship[RepeatingAudioComponent.self]?.state = .shouldBegin
                            }
                        } else {
                            if let ship = self.engine.ship {
                                ship.remove(componentClass: ApplyThrustComponent.self)
                                ship[WarpDriveComponent.self]?.isThrusting = false
                                ship[RepeatingAudioComponent.self]?.state = .shouldStop
                            }
                        }
                    }
                ))
        q4Entity
                .add(component: DisplayComponent(sknode: q4Sprite))
                .add(component: PositionComponent(x: q4Sprite.x, y: q4Sprite.y, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator?.impactOccurred()
                        engine.ship?.add(component: FireDownComponent.shared)
                    },
                    touchUp: { sprite in
                    },
                    touchUpOutside: { sprite in
                    },
                    touchMoved: { sprite, over in
                        if over {
                        } else {
                        }
                    }
                ))
    }
}
