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

extension NodeList {
    var count: Int {
        var n = 0
        var node = head
        while let currentNode = node {
            n += 1
            node = currentNode.next
        }
        return n
    }
}
