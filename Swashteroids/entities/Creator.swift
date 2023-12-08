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


/// Creator is a bunch of convenience methods that create and configure entities, then adds them to its engine.
class Creator {
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    private var appStateEntity: Entity!
    private var engine: Engine
    private var inputComponent: InputComponent
    private var numAsteroids = 0
    private var numTorpedoes = 0
    private var scene: SKScene
    private var size: CGSize

    init(engine: Engine, appStateEntity: Entity, inputComponent: InputComponent, scene: SKScene, size: CGSize) {
        print("Creator", #function)
        self.engine = engine
        self.inputComponent = inputComponent
        self.size = size
        self.scene = scene
        self.appStateEntity = appStateEntity
    }

    func setUpStart() {
        print(self, #function)
        // create the sprites
        let startView = StartView(scene: scene)
        let noButtonsSprite = startView.childNode(withName: "//nobuttons")! as! SwashteroidsSpriteNode
        let buttonsSprite = startView.childNode(withName: "//buttons")! as! SwashteroidsSpriteNode
        noButtonsSprite.removeFromParent()
        buttonsSprite.removeFromParent()
        // create the start entity
        let startEntity = Entity(name: .start)
                .add(component: DisplayComponent(sknode: startView))
                .add(component: PositionComponent(x: 0, y: 0, z: .top, rotation: 0))
        // buttons button
        let withButtons = Entity(name: .withButtons)
                .add(component: DisplayComponent(sknode: buttonsSprite))
                .add(component: PositionComponent(x: buttonsSprite.x, y: buttonsSprite.y, z: Layers.top, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in generator.impactOccurred(); sprite.alpha = 0.6 },
                    touchUp: { [unowned self] sprite in
                        sprite.alpha = 0.2
                        appStateEntity.add(component: TransitionAppStateComponent(to: .infoButtons, from: .start))
                    },
                    touchUpOutside: { sprite in sprite.alpha = 0.2 },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }))
        // no buttons button
        let noButtons = Entity(name: .noButtons)
                .add(component: DisplayComponent(sknode: noButtonsSprite))
                .add(component: PositionComponent(x: noButtonsSprite.x,
                                                  y: noButtonsSprite.y,
                                                  z: Layers.top,
                                                  rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in generator.impactOccurred(); sprite.alpha = 0.6 },
                    touchUp: { [unowned self] sprite in
                        sprite.alpha = 0.2
                        appStateEntity.add(component: TransitionAppStateComponent(to: .infoNoButtons, from: .start))
                    },
                    touchUpOutside: { sprite in sprite.alpha = 0.2 },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }))
        // assign entities to sprites
        startView.entity = startEntity
        noButtonsSprite.entity = noButtons
        buttonsSprite.entity = withButtons
        // add entities to engine
        engine.replaceEntity(entity: startEntity)
        engine.replaceEntity(entity: noButtons)
        engine.replaceEntity(entity: withButtons)
    }

    func tearDownStart() {
        engine.removeEntities(named: [.noButtons, .withButtons, .start])
    }

    //MARK: - No buttons state
    func setUpNoButtonsInfoView() {
        print(self, #function)
        let noButtonsInfoArt = SKScene(fileNamed: "NoButtonsInfo.sks")!
        guard let viewSprite = noButtonsInfoArt.childNode(withName: "quadrants") as? SwashteroidsSpriteNode else {
            print("Could not load 'quadrants' as SwashteroidsSpriteNode")
            return
        }
        viewSprite.removeFromParent()
        let viewEntity = Entity(name: .noButtonsInfoView)
                .add(component: DisplayComponent(sknode: viewSprite))
                .add(component: PositionComponent(x: 0, y: 0, z: .buttons, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        appStateEntity.add(component: TransitionAppStateComponent(to: .playing, from: .infoNoButtons))
                    }))
        viewSprite.entity = viewEntity
        engine.replaceEntity(entity: viewEntity)
        createToggleButton(.off)
    }

    func tearDownInfoNoButtons() {
        engine.removeEntities(named: [.noButtonsInfoView])
    }

    //MARK: - Buttons showing state
    func setUpButtonsInfoView() {
        print(self, #function)
        let buttonsInfoArt = SKScene(fileNamed: "ButtonsInfo.sks")!
        guard let viewSprite = buttonsInfoArt.childNode(withName: "buttonsInfo") as? SwashteroidsSpriteNode else {
            print("Could not load 'buttonsInfo' as SwashteroidsSpriteNode")
            return
        }
        viewSprite.removeFromParent()
        createShipControlButtons()
        let viewEntity = Entity(name: .buttonsInfoView)
                .add(component: DisplayComponent(sknode: viewSprite))
                .add(component: PositionComponent(x: 0, y: 0, z: .buttons, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(touchDown: { [unowned self] sprite in
                    generator.impactOccurred()
                    appStateEntity.add(component: TransitionAppStateComponent(to: .playing, from: .infoButtons))
                }))
        viewSprite.entity = viewEntity
        engine.replaceEntity(entity: viewEntity)
        createToggleButton(.on)
    }

    func tearDownInfoButtons() {
        engine.removeEntities(named: [.buttonsInfoView])
    }

    func removeShipControlButtons() {
        let shipControls: [EntityName] = [.leftButton, .rightButton, .thrustButton, .fireButton, .flipButton, .hyperSpaceButton]
        engine.removeEntities(named: shipControls)
    }

    func removeShipControlQuadrants() {
        let quadrants: [EntityName] = [.q1, .q2, .q3, .q4]
        engine.removeEntities(named: quadrants)
    }

    func createShipControlQuadrants() {
        print(self, #function)
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
                        self.engine.ship?.add(component: ThrustComponent.instance)
                        (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = true //HACK
                    },
                    touchUp: { sprite in
                        sprite.alpha = 0.2
                        self.engine.ship?.remove(componentClass: ThrustComponent.self)
                        (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = false //HACK
                    },
                    touchUpOutside: { sprite in
                        sprite.alpha = 0.2
                        self.engine.ship?.remove(componentClass: ThrustComponent.self)
                        (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = false //HACK
                    },
                    touchMoved: { sprite, over in
                        if over {
                            sprite.alpha = 0.6
                            self.engine.ship?.add(component: ThrustComponent.instance)
                            (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = true //HACK
                        } else {
                            sprite.alpha = 0.2
                            self.engine.ship?.remove(componentClass: ThrustComponent.self)
                            (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = false //HACK
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
                    touchUp: { sprite in sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: TriggerDownComponent.self) },
                    touchUpOutside: { sprite in sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: TriggerDownComponent.self) },
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

    func createShipControlButtons() {
        print(self, #function)
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

    func createToggleButton(_ state: Toggle) {
        print(self, #function)
        let name = state == .on ? "toggleButtonsOn" : "toggleButtonsOff"
        let sprite = SwashteroidsSpriteNode(imageNamed: name)
        sprite.name = name
        sprite.alpha = 0.2
        let x = scene.size.width / 2
        let y = 90.0
        let toggleButtonsEntity = Entity(name: .toggleButton)
                .add(component: PositionComponent(x: x, y: y, z: .buttons))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: TouchableComponent())
        sprite.entity = toggleButtonsEntity
        // Add the button behavior
        let toState: ShipControlsState = state == .on ? .hidingButtons : .showingButtons
        toggleButtonsEntity.add(component: ButtonBehaviorComponent(
            touchDown: { [unowned self] sprite in
                engine.hud?.add(component: ChangeShipControlsStateComponent(to: toState))
            },
            touchUp: { sprite in sprite.alpha = 0.2 },
            touchUpOutside: { sprite in sprite.alpha = 0.2 },
            touchMoved: { sprite, over in
                if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
            }
        ))
        engine.replaceEntity(entity: toggleButtonsEntity)
    }

    func enableShipControls() {
        print(self, #function)
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
                touchDown: { sprite in sprite.alpha = 0.6; self.engine.ship?.add(component: FlipComponent.instance) },
                touchUp: { sprite in sprite.alpha = 0.2 },
                touchUpOutside: { sprite in sprite.alpha = 0.2 },
                touchMoved: { sprite, over in
                    if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                }
            ))
        hyperspace.add(component: TouchableComponent())
                  .add(component: ButtonBehaviorComponent(
                      touchDown: { sprite in sprite.alpha = 0.6; self.engine.ship?.add(component: HyperSpaceJumpComponent()) },
                      touchUp: { sprite in sprite.alpha = 0.2 },
                      touchUpOutside: { sprite in sprite.alpha = 0.2 },
                      touchMoved: { sprite, over in
                          if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                      }
                  ))
        left.add(component: TouchableComponent())
            .add(component: ButtonBehaviorComponent(
                touchDown: { sprite in sprite.alpha = 0.6; self.engine.ship?.add(component: LeftComponent.instance) },
                touchUp: { sprite in sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: LeftComponent.self) },
                touchUpOutside: { sprite in sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: LeftComponent.self) },
                touchMoved: { sprite, over in
                    if over {
                        sprite.alpha = 0.6; self.engine.ship?.add(component: LeftComponent.instance)
                    } else {
                        sprite.alpha = 0.2; self.engine
                                                .ship?
                                                .remove(componentClass: LeftComponent.self)
                    }
                }
            ))
        right.add(component: TouchableComponent())
             .add(component: ButtonBehaviorComponent(
                 touchDown: { sprite in sprite.alpha = 0.6; self.engine.ship?.add(component: RightComponent.instance) },
                 touchUp: { sprite in sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: RightComponent.self) },
                 touchUpOutside: { sprite in sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: RightComponent.self) },
                 touchMoved: { sprite, over in
                     if over {
                         sprite.alpha = 0.6; self.engine.ship?.add(component: RightComponent.instance)
                     } else {
                         sprite.alpha = 0.2; self.engine
                                                 .ship?
                                                 .remove(componentClass: RightComponent.self)
                     }
                 }
             ))
        thrust.add(component: TouchableComponent())
              .add(component: ButtonBehaviorComponent(
                  touchDown: { sprite in
                      sprite.alpha = 0.6
                      self.engine.ship?.add(component: ThrustComponent.instance)
                      (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = true //HACK
                  },
                  touchUp: { sprite in
                      sprite.alpha = 0.2
                      self.engine.ship?.remove(componentClass: ThrustComponent.self)
                      (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = false //HACK
                  },
                  touchUpOutside: { sprite in
                      sprite.alpha = 0.2
                      self.engine.ship?.remove(componentClass: ThrustComponent.self)
                      (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = false //HACK
                  },
                  touchMoved: { sprite, over in
                      if over {
                          sprite.alpha = 0.6
                          self.engine.ship?.add(component: ThrustComponent.instance)
                          (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = true //HACK
                      } else {
                          sprite.alpha = 0.2
                          self.engine.ship?.remove(componentClass: ThrustComponent.self)
                          (self.engine.ship?.get(componentClassName: WarpDriveComponent.name) as? WarpDriveComponent)?.isThrusting = false //HACK
                      }
                  }
              ))
        fire.add(component: TouchableComponent())
            .add(component: ButtonBehaviorComponent(
                touchDown: { sprite in sprite.alpha = 0.6; self.engine.ship?.add(component: TriggerDownComponent.instance) },
                touchUp: { sprite in sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: TriggerDownComponent.self) },
                touchUpOutside: { sprite in sprite.alpha = 0.2; self.engine.ship?.remove(componentClass: TriggerDownComponent.self) },
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

    func setUpPlaying(with state: ShipControlsState) {
        print(self, #function)
        guard let appStateComponent = engine.getEntity(named: .appState)?
                                            .get(componentClassName: AppStateComponent.name) as? AppStateComponent else {
            print("WARNING: appStateComponent not found in engine")
            return
        }
        appStateComponent.resetBoard()
        appStateComponent.playing = true
        createHud(gameState: appStateComponent)
        if state == .hidingButtons {
            createToggleButton(.off)
            createShipControlQuadrants()
        } else {
            createToggleButton(.on)
            enableShipControls()
        }
    }

    func createPlasmaTorpedoesPowerUp(radius: Double = 7, x: Double = 512, y: Double = 484, level: Int) {
        print(self, #function)
        let r1 = Int.random(in: 75...(level * 130)) * [-1, 1].randomElement()!
        let r2 = Int.random(in: 75...(level * 100)) * level * [-1, 1].randomElement()!
        let centerX = Double(512 + r1)
        let centerY = Double(384 + r2)
        let sprite = PlasmaTorpedoesPowerUpView(imageNamed: "scope")
        let emitter = SKEmitterNode(fileNamed: "plasmaTorpedoesPowerUp.sks")!
        sprite.addChild(emitter)
        let entity = Entity(name: .plasmaTorpedoesPowerUp)
        sprite.name = entity.name
        sprite.color = .plasmaTorpedo
        sprite.colorBlendFactor = 1.0
        entity
                .add(component: PositionComponent(x: centerX,
                                                  y: centerY,
                                                  z: .asteroids,
                                                  rotation: 0.0))
                .add(component: CollisionComponent(radius: radius))
                .add(component: GunPowerUpComponent())
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AnimationComponent(animation: sprite))
                .add(component: MotionComponent(velocityX: 0, velocityY: 0, angularVelocity: 100))
        engine.replaceEntity(entity: entity)
    }

    @discardableResult
    func createHud(gameState: AppStateComponent) -> Entity {
        // Here we create a subclass of entity
        let hudView = HudView()
        let hudEntity = HudEntity(name: .hud, view: hudView, gameState: gameState)
        engine.replaceEntity(entity: hudEntity)
        return hudEntity
    }

    @discardableResult
    func createShip(_ state: ShipControlsState) -> Entity {
        print(self, #function, state)
        let shipSprite = SwashteroidsSpriteNode(texture: createShipTexture())
        let ship = Entity()
        ship.name = "ship"
        shipSprite.name = ship.name
        shipSprite.zPosition = Layers.ship.rawValue
        let nacellesSprite = SwashteroidsSpriteNode(texture: createEngineTexture())
        nacellesSprite.zPosition = shipSprite.zPosition + 0.1
        nacellesSprite.isHidden = true
        nacellesSprite.name = "nacelles"
        shipSprite.addChild(nacellesSprite)
        ship
            // Uncomment to be able to fire right away
            //  .add(component: GunComponent(offsetX: 21, offsetY: 0, minimumShotInterval: 0.25, bulletLifetime: 2))
                .add(component: WarpDriveComponent())
                .add(component: HyperSpaceEngineComponent())
                .add(component: AudioComponent())
                .add(component: PositionComponent(x: 512, y: 384, z: .ship, rotation: 0.0))
                .add(component: ShipComponent())
                .add(component: MotionComponent(velocityX: 0.0, velocityY: 0.0, damping: 0.0))
                .add(component: CollisionComponent(radius: 25))
                .add(component: DisplayComponent(sknode: shipSprite))
                .add(component: MotionControlsComponent(left: 1, right: 2, accelerate: 4, accelerationRate: 90, rotationRate: 100))
                .add(component: inputComponent)
                .add(component: AccelerometerComponent())
        switch state {
            case .hidingButtons:
                ship.add(component: AccelerometerComponent())
            case .showingButtons:
                ship.remove(componentClass: AccelerometerComponent.self)
        }
        engine.replaceEntity(entity: ship)
        return ship
    }

    @discardableResult
    func createUserTorpedo(_ gunComponent: GunComponent, _ parentPosition: PositionComponent, _ parentMotion: MotionComponent) -> Entity {
        print(self, #function)
        let cos = cos(parentPosition.rotation * Double.pi / 180)
        let sin = sin(parentPosition.rotation * Double.pi / 180)
        let sprite = SwashteroidsSpriteNode(texture: createBulletTexture(color: .plasmaTorpedo))
        let sparkEmitter = SKEmitterNode(fileNamed: "plasmaTorpedo.sks")!
        sparkEmitter.emissionAngle = parentPosition.rotation * Double.pi / 180 + Double.pi
        sprite.addChild(sparkEmitter)
        numTorpedoes += 1
        let entity = Entity(name: "bullet_\(numTorpedoes)")
                .add(component: PlasmaTorpedoComponent(lifeRemaining: gunComponent.torpedoLifetime))
                .add(component: PositionComponent(x: cos * gunComponent.offsetFromParent.x - sin * gunComponent.offsetFromParent
                                                                                                               .y + parentPosition.position
                                                                                                                                  .x,
                                                  y: sin * gunComponent.offsetFromParent.x + cos * gunComponent.offsetFromParent
                                                                                                               .y + parentPosition.position
                                                                                                                                  .y,
                                                  z: Layers.bullets,
                                                  rotation: 0))
                .add(component: CollisionComponent(radius: 0))
                .add(component: MotionComponent(velocityX: cos * 220 + parentMotion.velocity.x,
                                                velocityY: sin * 220 + parentMotion.velocity.y,
                                                angularVelocity: 0 + parentMotion.angularVelocity,
                                                damping: 0 + parentMotion.damping))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AudioComponent("fire.wav"))
        sprite.name = entity.name
        try? engine.addEntity(entity: entity)
        return entity
    }

    func tearDownOver() {
        // Clear any existing asteroids
        let asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        let gameOverNodes = engine.getNodeList(nodeClassType: GameOverNode.self)
        let gameOverNode = gameOverNodes.head
        var asteroid = asteroids.head
        while asteroid != nil {
            destroyEntity(asteroid!.entity!)
            asteroid = asteroid?.next
        }
        if let hud = engine.hud,
           let gameOverNode, let entity = gameOverNode.entity {
            engine.removeEntity(entity: entity)
            engine.removeEntity(entity: hud)
            if let powerUp = engine.getEntity(named: .plasmaTorpedoesPowerUp) {
                engine.removeEntity(entity: powerUp)
            }
        }
    }

    func setUpGameOver() {
        print(self, #function)
        let gameOverView = GameOverView(size: size)
        let gameOverEntity = Entity(name: .gameOver)
                .add(component: GameOverComponent())
                .add(component: DisplayComponent(sknode: gameOverView))
                .add(component: PositionComponent(x: 0, y: 0, z: .top, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: appStateEntity.get(componentClassName: AppStateComponent.name) as! AppStateComponent)
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        appStateEntity
                                .add(component: TransitionAppStateComponent(to: .start, from: .over))
                    }))
        gameOverView.entity = gameOverEntity
        engine.replaceEntity(entity: gameOverEntity)
    }

    func removeToggleButtonsButton() {
        print(self, #function)
        guard let entity = engine.getEntity(named: .toggleButton) else { return }
        engine.removeEntity(entity: entity)
    }

    @discardableResult
    func createAsteroid(radius: Double, x: Double, y: Double, color: UIColor = .asteroid) -> Entity {
        print(self, #function)
        let sprite = SwashteroidsSpriteNode(texture: createAsteroidTexture(radius: radius, color: color))
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
                .add(component: DisplayComponent(sknode: sprite))
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
        print(self, #function)
        engine.removeEntity(entity: entity)
    }
}
