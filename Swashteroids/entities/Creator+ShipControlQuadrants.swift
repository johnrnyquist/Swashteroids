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

protocol ShipControlQuadrantsManager {
    func removeShipControlQuadrants()
    func createShipControlQuadrants()
}

extension Creator: ShipControlQuadrantsManager {
    func removeShipControlQuadrants() {
        let quadrants: [EntityName] = [.q1, .q2, .q3, .q4]
        engine.removeEntities(named: quadrants)
    }

    /// Instead of visible buttons, the player will be able to touch quadrants on the screen to control the ship.
    func createShipControlQuadrants() {
        let noButtonsInfoArt = SKScene(fileNamed: "NoButtonsInfo.sks")!
        let q1Sprite = noButtonsInfoArt.childNode(withName: "//q1") as! SwashSpriteNode
        let q2Sprite = noButtonsInfoArt.childNode(withName: "//q2") as! SwashSpriteNode
        let q3Sprite = noButtonsInfoArt.childNode(withName: "//q3") as! SwashSpriteNode
        let q4Sprite = noButtonsInfoArt.childNode(withName: "//q4") as! SwashSpriteNode
        q1Sprite.removeFromParent()
        q2Sprite.removeFromParent()
        q3Sprite.removeFromParent()
        q4Sprite.removeFromParent()
        // Create the entities
        let q1Entity = Entity(name: .q1)
        let q2Entity = Entity(name: .q2)
        let q3Entity = Entity(name: .q3)
        let q4Entity = Entity(name: .q4)
        // Assign entities to sprites
        q1Sprite.entity = q1Entity
        q2Sprite.entity = q2Entity
        q3Sprite.entity = q3Entity
        q4Sprite.entity = q4Entity
        // Add entities to engine
        engine.replaceEntity(entity: q1Entity)
        engine.replaceEntity(entity: q2Entity)
        engine.replaceEntity(entity: q3Entity)
        engine.replaceEntity(entity: q4Entity)
        // Configure the entities
        q1Entity
                .add(component: DisplayComponent(sknode: q1Sprite))
                .add(component: PositionComponent(x: q1Sprite.x, y: q1Sprite.y, z: .bottom, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        if let ship = self.engine.ship,
                           ship.has(componentClassName: HyperspaceEngineComponent.name) {
                            engine.ship?.add(component: HyperspaceJumpComponent())
                        }
                    },
                    touchUp: { _ in },
                    touchUpOutside: { _ in },
                    touchMoved: { _, _ in }
                ))
        q2Entity
                .add(component: DisplayComponent(sknode: q2Sprite))
                .add(component: PositionComponent(x: q2Sprite.x, y: q2Sprite.y, z: .bottom, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        engine.ship?.add(component: FlipComponent.shared)
                    },
                    touchUp: { _ in },
                    touchUpOutside: { _ in },
                    touchMoved: { _, _ in }
                ))
        q3Entity
                .add(component: DisplayComponent(sknode: q3Sprite))
                .add(component: PositionComponent(x: q3Sprite.x, y: q3Sprite.y, z: .bottom, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        if let ship = self.engine.ship {
                            ship.add(component: ApplyThrustComponent.shared)
                            ship.warpDrive?.isThrusting = true
                            ship.repeatingAudio?.state = .shouldBegin
                        }
                    },
                    touchUp: { sprite in
                        if let ship = self.engine.ship {
                            ship.remove(componentClass: ApplyThrustComponent.self)
                            ship.warpDrive?.isThrusting = false
                            ship.repeatingAudio?.state = .shouldStop
                        }
                    },
                    touchUpOutside: { sprite in
                        if let ship = self.engine.ship {
                            ship.remove(componentClass: ApplyThrustComponent.self)
                            ship.warpDrive?.isThrusting = false
                            ship.repeatingAudio?.state = .shouldStop
                        }
                    },
                    touchMoved: { sprite, over in
                        if over {
                            if let ship = self.engine.ship {
                                ship.add(component: ApplyThrustComponent.shared)
                                ship.warpDrive?.isThrusting = true
                                ship.repeatingAudio?.state = .shouldBegin
                            }
                        } else {
                            if let ship = self.engine.ship {
                                ship.remove(componentClass: ApplyThrustComponent.self)
                                ship.warpDrive?.isThrusting = false
                                ship.repeatingAudio?.state = .shouldStop
                            }
                        }
                    }
                ))
        q4Entity
                .add(component: DisplayComponent(sknode: q4Sprite))
                .add(component: PositionComponent(x: q4Sprite.x, y: q4Sprite.y, z: .bottom, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        self.engine.ship?.add(component: FireDownComponent.shared)
                    },
                    touchUp: { sprite in
                        self.engine.ship?.remove(componentClass: FireDownComponent.self)
                    },
                    touchUpOutside: { sprite in
                        self.engine.ship?.remove(componentClass: FireDownComponent.self)
                    },
                    touchMoved: { sprite, over in
                        if over {
                            self.engine.ship?.add(component: FireDownComponent.shared)
                        } else {
                            self.engine.ship?.remove(componentClass: FireDownComponent.self)
                        }
                    }
                ))
    }
}