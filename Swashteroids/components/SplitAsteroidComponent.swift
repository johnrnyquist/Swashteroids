//
//  SplitAsteroidComponent.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/8/24.
//

import Swash

class SplitAsteroidComponent: Component {
    let level: Int
    let splits: Int

    init(level: Int, splits: Int = 2) {
        self.level = level
        self.splits = splits
        super.init()
    }
}
