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

extension CGRect {
    mutating func scale(by factor: CGFloat) {
        self.size.width *= factor
        self.size.height *= factor
    }

    func scaled(by factor: CGFloat) -> CGRect {
        var newRect = self
        newRect.size.width *= factor
        newRect.size.height *= factor
        return newRect
    }
}
