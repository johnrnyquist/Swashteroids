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

extension Dictionary {
    func mapKeys<T>(_ transform: (Key) throws -> T) rethrows -> [T: Value] {
        var dict = [T: Value]()
        for (key, value) in self {
            dict[try transform(key)] = value
        }
        return dict
    }

    func compactMapKeys<T>(_ transform: (Key) throws -> T?) rethrows -> [T: Value] {
        var dict = [T: Value]()
        for (key, value) in self {
            if let newKey = try transform(key) {
                dict[newKey] = value
            }
        }
        return dict
    }
}