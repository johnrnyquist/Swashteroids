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

protocol ShipButtonControlsManager: AnyObject {
    func removeShipControlButtons()
    func createShipControlButtons()
    func enableShipControlButtons()
}

extension Creator: ShipButtonControlsManager {
    func removeShipControlButtons() {
        let shipControls: [EntityName] = [.leftButton, .rightButton, .thrustButton, .fireButton, .flipButton, .hyperspaceButton]
        engine.removeEntities(named: shipControls)
    }

    func createButtonEntity(sprite button: SwashSpriteNode, color: UIColor, position: CGPoint, name: EntityName) {
        button.color = color
        button.colorBlendFactor = 1.0
        button.alpha = 0.2
        let buttonEntity = Entity(named: name)
                .add(component: PositionComponent(x: position.x, y: position.y, z: .buttons, rotationDegrees: 0.0))
                .add(component: DisplayComponent(sknode: button))
        button.entity = buttonEntity
        engine.replace(entity: buttonEntity)
    }

    func createShipControlButtons() {
        // left
        let leftButton = SwashSpriteNode(imageNamed: .leftButton)
        let leftX = leftButton.size.width / 2 + buttonPaddingLeft
        let leftY = leftButton.size.height / 2 + firstRowButtonPaddingY
        createButtonEntity(sprite: leftButton, color: .leftButton, position: CGPoint(x: leftX, y: leftY), name: .leftButton)
        // right
        let rightButton = SwashSpriteNode(imageNamed: .rightButton)
        let rightX = rightButton.size.width + buttonPadding + leftX
        let rightY = leftY
        createButtonEntity(sprite: rightButton, color: .rightButton, position: CGPoint(x: rightX, y: rightY), name: .rightButton)
        // thrust
        let thrustButton = SwashSpriteNode(imageNamed: .thrustButton)
        let thrustX = size.width - thrustButton.size.width / 2 - buttonPaddingRight
        let thrustY = leftY
        createButtonEntity(sprite: thrustButton,
                           color: .thrustButton,
                           position: CGPoint(x: thrustX, y: thrustY),
                           name: .thrustButton)
        // fire
        let fireButton = SwashSpriteNode(imageNamed: .fireButton)
        let fireX = -thrustButton.size.width - buttonPadding + thrustX
        let fireY = leftY
        createButtonEntity(sprite: fireButton, color: .fireButton, position: CGPoint(x: fireX, y: fireY), name: .fireButton)
        // flip
        let flipButton = SwashSpriteNode(imageNamed: .flipButton)
        let flipX = leftX
        let flipY = leftY + flipButton.size.height + buttonPadding
        createButtonEntity(sprite: flipButton, color: .flipButton, position: CGPoint(x: flipX, y: flipY), name: .flipButton)
        // hyperspace
        let hyperspaceButton = SwashSpriteNode(imageNamed: .hyperspaceButton)
        let hyperspaceX = thrustX
        let hyperspaceY = flipY
        createButtonEntity(sprite: hyperspaceButton,
                           color: .hyperspaceButton,
                           position: CGPoint(x: hyperspaceX, y: hyperspaceY),
                           name: .hyperspaceButton)
    }

    func enableShipControlButtons() {
        guard let flip = engine.getEntity(named: .flipButton),
              let hyperspace = engine.getEntity(named: .hyperspaceButton),
              let left = engine.getEntity(named: .leftButton),
              let right = engine.getEntity(named: .rightButton),
              let thrust = engine.getEntity(named: .thrustButton),
              let fire = engine.getEntity(named: .fireButton)
        else {
            print(#function, #line, "WARNING: could not find all buttons in engine")
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
