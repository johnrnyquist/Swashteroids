//
//  SplitAsteroidNode.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/8/24.
//

import Swash

class SplitAsteroidNode: Node {
    required init() {
        super.init()
        components = [
            SplitAsteroidComponent.name: nil_component,
            AsteroidComponent.name: nil_component,
            PositionComponent.name: nil_component,
            VelocityComponent.name: nil_component
        ]
    }
}
