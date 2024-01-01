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

protocol ShipControlButtonsManager: AnyObject {
    func removeShipControlButtons()
    func createShipControlButtons()
    func enableShipControlButtons()
}

extension Creator: ShipControlButtonsManager {
    func removeShipControlButtons() {
        let shipControls: [EntityName] = [.leftButton, .rightButton, .thrustButton, .fireButton, .flipButton, .hyperspaceButton]
        engine.removeEntities(named: shipControls)
    }

    func createShipControlButtons() {
        // left
        let leftButton = SwashSpriteNode(imageNamed: "left")
        leftButton.alpha = 0.2
        let leftX = leftButton.size.width / 2 + buttonPaddingLeft
        let leftY = leftButton.size.height / 2 + firstRowButtonPaddingY
        let leftButtonEntity = Entity(named: .leftButton)
                .add(component: PositionComponent(x: leftX, y: leftY, z: .buttons, rotationDegrees: 0.0))
                .add(component: DisplayComponent(sknode: leftButton))
        leftButton.entity = leftButtonEntity
        engine.replace(entity: leftButtonEntity)
        // right
        let rightButton = SwashSpriteNode(imageNamed: "left")
        rightButton.alpha = 0.2
        rightButton.xScale *= -1.0
        let rightX = rightButton.size.width + buttonPadding + leftX
        let rightY = leftY
        let rightButtonEntity = Entity(named: .rightButton)
                .add(component: PositionComponent(x: rightX, y: rightY, z: .buttons, rotationDegrees: 0.0))
                .add(component: DisplayComponent(sknode: rightButton))
        engine.replace(entity: rightButtonEntity)
        rightButton.entity = rightButtonEntity
        // thrust
        let thrustButton = SwashSpriteNode(imageNamed: "thrust")
        thrustButton.alpha = 0.2
        let thrustX = size.width - thrustButton.size.width / 2 - buttonPaddingRight
        let thrustY = leftY
        let thrustButtonEntity = Entity(named: .thrustButton)
                .add(component: PositionComponent(x: thrustX, y: thrustY, z: .buttons, rotationDegrees: 0.0))
                .add(component: DisplayComponent(sknode: thrustButton))
        thrustButton.entity = thrustButtonEntity
        engine.replace(entity: thrustButtonEntity)
        // fire
        let fireButton = SwashSpriteNode(imageNamed: "fire")
        fireButton.alpha = 0.2
        let fireX = -thrustButton.size.width - buttonPadding + thrustX
        let fireY = leftY
        let fireButtonEntity = Entity(named: .fireButton)
                .add(component: PositionComponent(x: fireX, y: fireY, z: .buttons, rotationDegrees: 0.0))
                .add(component: DisplayComponent(sknode: fireButton))
        fireButton.entity = fireButtonEntity
        engine.replace(entity: fireButtonEntity)
        // flip
        let flipButton = SwashSpriteNode(imageNamed: "flip")
        flipButton.alpha = 0.2
        let flipX = leftX
        let flipY = leftY + flipButton.size.height + buttonPadding
        let flipButtonEntity = Entity(named: .flipButton)
                .add(component: PositionComponent(x: flipX, y: flipY, z: .buttons, rotationDegrees: 0.0))
                .add(component: DisplayComponent(sknode: flipButton))
        flipButton.entity = flipButtonEntity
        engine.replace(entity: flipButtonEntity)
        // hyperspace
        let hyperspaceButton = SwashSpriteNode(imageNamed: "hyperspace")
        hyperspaceButton.alpha = 0.2
        let hyperspaceX = thrustX
        let hyperspaceY = flipY
        let hyperspaceButtonEntity = Entity(named: .hyperspaceButton)
                .add(component: PositionComponent(x: hyperspaceX, y: hyperspaceY, z: .buttons, rotationDegrees: 0.0))
                .add(component: DisplayComponent(sknode: hyperspaceButton))
        hyperspaceButton.entity = hyperspaceButtonEntity
        engine.replace(entity: hyperspaceButtonEntity)
    }

    /// Since buttons are used inertly on the info screen, we need to enable them for gameplay.
    /// Technically, I could have just added Touchable here and had the ButtonBehaviorComponent done initially.
    func enableShipControlButtons() {
        guard let flip = engine.getEntity(named: .flipButton),
              let hyperspace = engine.getEntity(named: .hyperspaceButton),
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
                    generator?.impactOccurred()
                    engine.ship?.add(component: FlipComponent.shared)
                },
                touchUp: { sprite in sprite.alpha = 0.2 },
                touchUpOutside: { sprite in sprite.alpha = 0.2 },
                touchMoved: { sprite, over in
                    if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                }
            ))
        hyperspace.sprite?.alpha = 0.0 //HACK to hide this button until you get the power-up
        hyperspace.add(component: TouchableComponent())
                  .add(component: ButtonBehaviorComponent(
                      touchDown: { [unowned self] sprite in
                          sprite.alpha = 0.6
                          generator?.impactOccurred()
                          engine.ship?.add(component: HyperspaceJumpComponent(size: size))
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
                    generator?.impactOccurred()
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
                     generator?.impactOccurred()
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
                      generator?.impactOccurred()
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
        fire.sprite?.alpha = 0.0 //HACK to hide this button until you get the power-up
        fire.add(component: TouchableComponent())
            .add(component: ButtonBehaviorComponent(
                touchDown: { [unowned self] sprite in
                    sprite.alpha = 0.6
                    generator?.impactOccurred()
                    engine.ship?.add(component: FireDownComponent.shared)
                },
                touchUp: { sprite in
                    sprite.alpha = 0.2
                    self.engine.ship?.remove(componentClass: FireDownComponent.self)
                },
                touchUpOutside: { sprite in
                    sprite.alpha = 0.2
                    self.engine.ship?.remove(componentClass: FireDownComponent.self)
                },
                touchMoved: { sprite, over in
                    if over {
                        sprite.alpha = 0.6
                        self.engine.ship?.add(component: FireDownComponent.shared)
                    } else {
                        sprite.alpha = 0.2
                        self.engine.ship?.remove(componentClass: FireDownComponent.self)
                    }
                }
            ))
    }
}
