//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation

extension CGSize {
    mutating func scale(by factor: CGFloat) {
        self.width *= factor
        self.height *= factor
    }

    func scaled(by factor: CGFloat) -> CGSize {
        var newSize = self
        newSize.width *= factor
        newSize.height *= factor
        return newSize
    }
}
