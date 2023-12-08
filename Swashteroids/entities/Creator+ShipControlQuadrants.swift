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
        let q1Entity = Entity(name: .q1)
                .add(component: DisplayComponent(sknode: q1Sprite))
                .add(component: PositionComponent(x: q1Sprite.x, y: q1Sprite.y, z: .bottom, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        sprite.alpha = 0.6
                        self.engine.ship?.add(component: FlipComponent.instance)
                    },
                    touchUp: { sprite in sprite.alpha = 0.2 },
                    touchUpOutside: { sprite in sprite.alpha = 0.2 },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }
                ))
        q1Sprite.entity = q1Entity
        let q2Entity = Entity(name: .q2)
                .add(component: DisplayComponent(sknode: q2Sprite))
                .add(component: PositionComponent(x: q2Sprite.x, y: q2Sprite.y, z: .bottom, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        sprite.alpha = 0.6
                        self.engine.ship?.add(component: HyperSpaceJumpComponent())
                    },
                    touchUp: { sprite in sprite.alpha = 0.2 },
                    touchUpOutside: { sprite in sprite.alpha = 0.2 },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }
                ))
        q2Sprite.entity = q2Entity
        let q3Entity = Entity(name: .q3)
                .add(component: DisplayComponent(sknode: q3Sprite))
                .add(component: PositionComponent(x: q3Sprite.x, y: q3Sprite.y, z: .bottom, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        sprite.alpha = 0.6
                        self.engine.ship?.add(component: ApplyThrustComponent.instance)
                        (self.engine
                             .ship?
                             .get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = true //HACK
                    },
                    touchUp: { sprite in
                        sprite.alpha = 0.2
                        self.engine.ship?.remove(componentClass: ApplyThrustComponent.self)
                        (self.engine
                             .ship?
                             .get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = false //HACK
                    },
                    touchUpOutside: { sprite in
                        sprite.alpha = 0.2
                        self.engine.ship?.remove(componentClass: ApplyThrustComponent.self)
                        (self.engine
                             .ship?
                             .get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = false //HACK
                    },
                    touchMoved: { sprite, over in
                        if over {
                            sprite.alpha = 0.6
                            self.engine.ship?.add(component: ApplyThrustComponent.instance)
                            (self.engine
                                 .ship?
                                 .get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = true //HACK
                        } else {
                            sprite.alpha = 0.2
                            self.engine.ship?.remove(componentClass: ApplyThrustComponent.self)
                            (self.engine
                                 .ship?
                                 .get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = false //HACK
                        }
                    }
                ))
        q3Sprite.entity = q3Entity
        let q4Entity = Entity(name: .q4)
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
        q4Sprite.entity = q4Entity
        engine.replaceEntity(entity: q1Entity)
        engine.replaceEntity(entity: q2Entity)
        engine.replaceEntity(entity: q3Entity)
        engine.replaceEntity(entity: q4Entity)
    }
}