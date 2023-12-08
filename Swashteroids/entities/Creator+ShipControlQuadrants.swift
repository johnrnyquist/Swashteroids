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

extension Creator {
    func removeShipControlQuadrants() {
        let quadrants: [EntityName] = [.q1, .q2, .q3, .q4]
        engine.removeEntities(named: quadrants)
    }

    /// Instead of visible buttons, the player will be able to touch quadrants on the screen to control the ship.
    func createShipControlQuadrants() {
        let noButtonsInfoArt = SKScene(fileNamed: "NoButtonsInfo.sks")!
        let q1Sprite = noButtonsInfoArt.childNode(withName: "//q1") as! SwashteroidsSpriteNode
        let q2Sprite = noButtonsInfoArt.childNode(withName: "//q2") as! SwashteroidsSpriteNode
        let q3Sprite = noButtonsInfoArt.childNode(withName: "//q3") as! SwashteroidsSpriteNode
        let q4Sprite = noButtonsInfoArt.childNode(withName: "//q4") as! SwashteroidsSpriteNode
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
                        sprite.alpha = 0.6
                        engine.ship?.add(component: FlipComponent.instance)
                    },
                    touchUp: { sprite in sprite.alpha = 0.2 },
                    touchUpOutside: { sprite in sprite.alpha = 0.2 },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }
                ))
        q2Entity
                .add(component: DisplayComponent(sknode: q2Sprite))
                .add(component: PositionComponent(x: q2Sprite.x, y: q2Sprite.y, z: .bottom, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        sprite.alpha = 0.6
                        engine.ship?.add(component: HyperSpaceJumpComponent())
                    },
                    touchUp: { sprite in sprite.alpha = 0.2 },
                    touchUpOutside: { sprite in sprite.alpha = 0.2 },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }
                ))
        q3Entity
                .add(component: DisplayComponent(sknode: q3Sprite))
                .add(component: PositionComponent(x: q3Sprite.x, y: q3Sprite.y, z: .bottom, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { sprite in
                        if let ship = self.engine.ship {
                            ship.add(component: ApplyThrustComponent.instance)
                            ship.warpDrive?.isThrusting = true //HACK
                            ship.repeatingAudio?.state = .shouldBegin //HACK
                        }
                    },
                    touchUp: { sprite in
                        if let ship = self.engine.ship {
                            ship.remove(componentClass: ApplyThrustComponent.self)
                            ship.warpDrive?.isThrusting = false //HACK
                            ship.repeatingAudio?.state = .shouldStop //HACK
                        }
                    },
                    touchUpOutside: { sprite in
                        if let ship = self.engine.ship {
                            ship.remove(componentClass: ApplyThrustComponent.self)
                            ship.warpDrive?.isThrusting = false //HACK
                            ship.repeatingAudio?.state = .shouldStop //HACK
                        }
                    },
                    touchMoved: { sprite, over in
                        if over {
                            if let ship = self.engine.ship {
                                ship.add(component: ApplyThrustComponent.instance)
                                ship.warpDrive?.isThrusting = true //HACK
                                ship.repeatingAudio?.state = .shouldBegin //HACK
                            }
                        } else {
                            if let ship = self.engine.ship {
                                ship.remove(componentClass: ApplyThrustComponent.self)
                                ship.warpDrive?.isThrusting = false //HACK
                                ship.repeatingAudio?.state = .shouldStop //HACK
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
                        sprite.alpha = 0.6
                        self.engine.ship?.add(component: TriggerDownComponent.instance)
                    },
                    touchUp: { sprite in
                        sprite.alpha = 0.2; self.engine
                                                .ship?
                                                .remove(componentClass: TriggerDownComponent.self)
                    },
                    touchUpOutside: { sprite in
                        sprite.alpha = 0.2; self.engine
                                                .ship?
                                                .remove(componentClass: TriggerDownComponent.self)
                    },
                    touchMoved: { sprite, over in
                        if over {
                            sprite.alpha = 0.6; self.engine.ship?.add(component: TriggerDownComponent.instance)
                        } else {
                            sprite.alpha = 0.2; self.engine
                                                    .ship?
                                                    .remove(componentClass: TriggerDownComponent.self)
                        }
                    }
                ))
    }
}