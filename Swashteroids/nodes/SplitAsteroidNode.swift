//
//  SplitAsteroidNode.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/8/24.
//

import Swash

final class SplitAsteroidNode: Node {
    required init() {
        super.init()
        components = [
            SplitAsteroidComponent.name: nil,
            AsteroidComponent.name: nil,
            PositionComponent.name: nil,
            VelocityComponent.name: nil
        ]
    }
}
