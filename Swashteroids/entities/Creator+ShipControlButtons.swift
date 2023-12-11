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
    func removeShipControlButtons() {
        let shipControls: [EntityName] = [.leftButton, .rightButton, .thrustButton, .fireButton, .flipButton, .hyperSpaceButton]
        engine.removeEntities(named: shipControls)
    }

    func createShipControlButtons() {
        // flip
        let flipButton = SwashteroidsSpriteNode(imageNamed: "flip")
        flipButton.alpha = 0.2
        let flipx = flipButton.size.width / 2 + 30
        let flipy = flipButton.size.height + 120
        let flipButtonEntity = Entity(name: .flipButton)
                .add(component: PositionComponent(x: flipx, y: flipy, z: .buttons, rotation: 0.0))
                .add(component: DisplayComponent(sknode: flipButton))
        flipButton.entity = flipButtonEntity
        engine.replaceEntity(entity: flipButtonEntity)
        // left
        let leftButton = SwashteroidsSpriteNode(imageNamed: "left")
        leftButton.alpha = 0.2
        let leftx = leftButton.size.width / 2 + 30
        let lefty = leftButton.size.height / 2 + 30
        let leftButtonEntity = Entity(name: .leftButton)
                .add(component: PositionComponent(x: leftx, y: lefty, z: .buttons, rotation: 0.0))
                .add(component: DisplayComponent(sknode: leftButton))
        leftButton.entity = leftButtonEntity
        engine.replaceEntity(entity: leftButtonEntity)
        // right
        let rightButton = SwashteroidsSpriteNode(imageNamed: "left")
        rightButton.alpha = 0.2
        rightButton.xScale = -1.0
        let rightx = rightButton.size.width + 30 + leftx
        let righty = lefty
        let rightButtonEntity = Entity(name: .rightButton)
                .add(component: PositionComponent(x: rightx, y: righty, z: .buttons, rotation: 0.0))
                .add(component: DisplayComponent(sknode: rightButton))
        engine.replaceEntity(entity: rightButtonEntity)
        rightButton.entity = rightButtonEntity
        // thrust
        let thrustButton = SwashteroidsSpriteNode(imageNamed: "thrust")
        thrustButton.alpha = 0.2
        let thrustx = 1024 - thrustButton.size.width / 2 - 30
        let thrusty = lefty
        let thrustButtonEntity = Entity(name: .thrustButton)
                .add(component: PositionComponent(x: thrustx, y: thrusty, z: .buttons, rotation: 0.0))
                .add(component: DisplayComponent(sknode: thrustButton))
        thrustButton.entity = thrustButtonEntity
        engine.replaceEntity(entity: thrustButtonEntity)
        // fire
        let fireButton = SwashteroidsSpriteNode(imageNamed: "trigger")
        fireButton.alpha = 0.2
        let firex = -thrustButton.size.width - 30 + thrustx
        let firey = lefty
        let fireButtonEntity = Entity(name: .fireButton)
                .add(component: PositionComponent(x: firex, y: firey, z: .buttons, rotation: 0.0))
                .add(component: DisplayComponent(sknode: fireButton))
        fireButton.entity = fireButtonEntity
        engine.replaceEntity(entity: fireButtonEntity)
        // hyperSpace
        let hyperSpaceButton = SwashteroidsSpriteNode(imageNamed: "hyperspace")
        hyperSpaceButton.alpha = 0.2
        let hyperSpacex = 1024 - thrustButton.size.width / 2 - 30
        let hyperSpacey = hyperSpaceButton.size.height + 120
        let hyperSpaceButtonEntity = Entity(name: .hyperSpaceButton)
                .add(component: PositionComponent(x: hyperSpacex, y: hyperSpacey, z: .buttons, rotation: 0.0))
                .add(component: DisplayComponent(sknode: hyperSpaceButton))
        hyperSpaceButton.entity = hyperSpaceButtonEntity
        engine.replaceEntity(entity: hyperSpaceButtonEntity)
    }

    /// Since buttons are used inertly on the info screen, we need to enable them for gameplay.
    func enableShipControlButtons() {
        guard let flip = engine.getEntity(named: .flipButton),
              let hyperspace = engine.getEntity(named: .hyperSpaceButton),
              let left = engine.getEntity(named: .leftButton),
              let right = engine.getEntity(named: .rightButton),
              let thrust = engine.getEntity(named: .thrustButton),
              let fire = engine.getEntity(named: .fireButton)
        else {
            print("WARNING: could not find all buttons in engine")
            return
        }
        // Set up the ship control buttons
        flip.add(component: TouchableComponent())
            .add(component: ButtonBehaviorComponent(
                touchDown: { [unowned self] sprite in
                    sprite.alpha = 0.6
                    generator.impactOccurred()
                    engine.ship?.add(component: FlipComponent.shared)
                },
                touchUp: { sprite in sprite.alpha = 0.2 },
                touchUpOutside: { sprite in sprite.alpha = 0.2 },
                touchMoved: { sprite, over in
                    if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                }
            ))
        hyperspace.sprite?.alpha = 0.0 //HACK
        hyperspace.add(component: TouchableComponent())
                  .add(component: ButtonBehaviorComponent(
                      touchDown: { [unowned self] sprite in
                          sprite.alpha = 0.6
                          generator.impactOccurred()
                          engine.ship?.add(component: HyperSpaceJumpComponent())
                      },
                      touchUp: { sprite in sprite.alpha = 0.2 },
                      touchUpOutside: { sprite in sprite.alpha = 0.2 },
                      touchMoved: { sprite, over in
                          if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                      }
                  ))
        left.add(component: TouchableComponent())
            .add(component: ButtonBehaviorComponent(
                touchDown: { [unowned self] sprite in
                    sprite.alpha = 0.6
                    generator.impactOccurred()
                    self.engine.ship?.add(component: LeftComponent.shared)
                },
                touchUp: { sprite in
                    sprite.alpha = 0.2
                    self.engine.ship?.remove(componentClass: LeftComponent.self)
                },
                touchUpOutside: { sprite in
                    sprite.alpha = 0.2
                    self.engine.ship?.remove(componentClass: LeftComponent.self)
                },
                touchMoved: { sprite, over in
                    if over {
                        sprite.alpha = 0.6
                        self.engine.ship?.add(component: LeftComponent.shared)
                    } else {
                        sprite.alpha = 0.2
                        self.engine.ship?.remove(componentClass: LeftComponent.self)
                    }
                }
            ))
        right.add(component: TouchableComponent())
             .add(component: ButtonBehaviorComponent(
                 touchDown: { [unowned self] sprite in
                     sprite.alpha = 0.6
                     generator.impactOccurred()
                     self.engine.ship?.add(component: RightComponent.shared)
                 },
                 touchUp: { sprite in
                     sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: RightComponent.self)
                 },
                 touchUpOutside: { sprite in
                     sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: RightComponent.self)
                 },
                 touchMoved: { sprite, over in
                     if over {
                         sprite.alpha = 0.6; self.engine.ship?.add(component: RightComponent.shared)
                     } else {
                         sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: RightComponent.self)
                     }
                 }
             ))
        thrust.add(component: TouchableComponent())
              .add(component: ButtonBehaviorComponent(
                  touchDown: { [unowned self] sprite in
                      sprite.alpha = 0.6
                      generator.impactOccurred()
                      if let ship = self.engine.ship {
                          ship.add(component: ApplyThrustComponent.shared)
                          ship.warpDrive?.isThrusting = true
                          ship.repeatingAudio?.state = .shouldBegin
                      }
                  },
                  touchUp: { sprite in
                      sprite.alpha = 0.2
                      if let ship = self.engine.ship {
                          ship.remove(componentClass: ApplyThrustComponent.self)
                          ship.warpDrive?.isThrusting = false
                          ship.repeatingAudio?.state = .shouldStop
                      }
                  },
                  touchUpOutside: { sprite in
                      sprite.alpha = 0.2
                      if let ship = self.engine.ship {
                          ship.remove(componentClass: ApplyThrustComponent.self)
                          ship.warpDrive?.isThrusting = false
                          ship.repeatingAudio?.state = .shouldStop
                      }
                  },
                  touchMoved: { sprite, over in
                      if over {
                          sprite.alpha = 0.6
                          if let ship = self.engine.ship {
                              ship.add(component: ApplyThrustComponent.shared)
                              ship.warpDrive?.isThrusting = true
                              ship.repeatingAudio?.state = .shouldBegin
                          }
                      } else {
                          sprite.alpha = 0.2
                          if let ship = self.engine.ship {
                              ship.remove(componentClass: ApplyThrustComponent.self)
                              ship.warpDrive?.isThrusting = false
                              ship.repeatingAudio?.state = .shouldStop
                          }
                      }
                  }
              ))
        fire.sprite?.alpha = 0.0 //HACK
        fire.add(component: TouchableComponent())
            .add(component: ButtonBehaviorComponent(
                touchDown: { [unowned self] sprite in
                    sprite.alpha = 0.6
                    generator.impactOccurred()
                    engine.ship?.add(component: TriggerDownComponent.shared)
                },
                touchUp: { sprite in
                    sprite.alpha = 0.2
                    self.engine.ship?.remove(componentClass: TriggerDownComponent.self)
                },
                touchUpOutside: { sprite in
                    sprite.alpha = 0.2
                    self.engine.ship?.remove(componentClass: TriggerDownComponent.self)
                },
                touchMoved: { sprite, over in
                    if over {
                        sprite.alpha = 0.6
                        self.engine.ship?.add(component: TriggerDownComponent.shared)
                    } else {
                        sprite.alpha = 0.2
                        self.engine.ship?.remove(componentClass: TriggerDownComponent.self)
                    }
                }
            ))
    }
}
