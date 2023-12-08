import Swash

//TODO:  I'm crazy about this extension
extension Entity {
	var sprite: SwashteroidsSpriteNode? {
		let component = get(componentClassName: DisplayComponent.name) as? DisplayComponent
		return component?.sprite
	}
}
