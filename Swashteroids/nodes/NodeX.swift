import Foundation
import Swash


let a = NodeX.declarations[.AsteroidCollisionNode]

enum NodeX: String, CaseIterable {
    case AsteroidCollisionNode
    case BulletCollisionNode
    case DeathThroesNode
    case GameNode
    case HudNode
    case MotionControlNode
    case MovementNode
    case RenderNode
    case ShipCollisionNode
    case ShipNode
    static var declarations: [NodeX: [ComponentClassName]] = [
        .AsteroidCollisionNode: [
            AsteroidComponent.name,
            CollisionComponent.name,
            PositionComponent.name,
            DisplayComponent.name,
        ],
        .BulletCollisionNode: [
            BulletComponent.name,
            CollisionComponent.name,
            PositionComponent.name,
        ],
        .DeathThroesNode: [
            DeathThroesComponent.name
        ],
        .GameNode: [
            GameStateComponent.name,
        ],
        .HudNode: [
            GameStateComponent.name,
            HudComponent.name,
        ],
        .MotionControlNode: [
            MotionControlsComponent.name,
            MotionComponent.name,
            PositionComponent.name,
        ],
        .MovementNode: [
            MotionComponent.name,
            PositionComponent.name,
        ],
        .RenderNode: [
            DisplayComponent.name,
            PositionComponent.name,
        ],
        .ShipCollisionNode: [
            CollisionComponent.name,
            PositionComponent.name,
            ShipComponent.name,
        ],
        .ShipNode: [
            PositionComponent.name,
            ShipComponent.name,
        ],
    ]
}
