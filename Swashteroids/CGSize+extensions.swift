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
    static func *(size: CGSize, scalar: Double) -> CGSize {
        CGSize(width: size.width * CGFloat(scalar), height: size.height * CGFloat(scalar))
    }

    static func /(size: CGSize, scalar: Double) -> CGSize {
        CGSize(width: size.width / CGFloat(scalar), height: size.height / CGFloat(scalar))
    }

    static func +(size: CGSize, scalar: Double) -> CGSize {
        CGSize(width: size.width + CGFloat(scalar), height: size.height + CGFloat(scalar))
    }

    static func -(size: CGSize, scalar: Double) -> CGSize {
        CGSize(width: size.width - CGFloat(scalar), height: size.height - CGFloat(scalar))
    }
}
