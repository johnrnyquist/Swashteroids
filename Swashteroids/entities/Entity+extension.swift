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

extension Entity {
    var sprite: SwashteroidsSpriteNode? {
        let component = get(componentClassName: DisplayComponent.name) as? DisplayComponent
        return component?.sprite
    }
    subscript(componentName: ComponentClassName) -> Component? {
        self.get(componentClassName: componentName)
    }
}
