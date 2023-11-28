import SpriteKit
import UIKit
import Swash


let LINE_WIDTH: Double = 1

func createGunSupplierTexture(radius: Double, color: UIColor) -> SKTexture {
    let size = CGSize(width: radius * 2, height: radius * 2)
    let renderer = UIGraphicsImageRenderer(size: size)
    let controller = renderer.image { ctx in
        ctx.cgContext.setStrokeColor(color.cgColor)
        ctx.cgContext.setFillColor(color.cgColor)
        ctx.cgContext.setLineWidth(0)
        ctx.cgContext.move(to: CGPoint(x: 0, y: 0))
        ctx.cgContext.strokeEllipse(in: CGRect(origin: .zero, size: size))
        ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
    }
    return SKTexture(image: controller)
}

func createBulletTexture(color: UIColor) -> SKTexture {
    let rect = CGRect(x: 0, y: 0, width: 7, height: 7)
    let size = CGSize(width: 5, height: 5)
    let renderer = UIGraphicsImageRenderer(size: size)
    let controller = renderer.image { ctx in
		ctx.cgContext.setStrokeColor(UIColor.clear.cgColor)
        ctx.cgContext.setFillColor(color.cgColor)
        ctx.cgContext.setLineWidth(0)
        ctx.cgContext.move(to: CGPoint(x: 0, y: 0))
        ctx.cgContext.fillEllipse(in: rect)
        ctx.cgContext.strokeEllipse(in: rect)
    }
    return SKTexture(image: controller)
}

func createButtonTexture(color: UIColor, text: String) -> SKTexture {
	let size = CGSize(width: 120, height: 120)
	let renderer = UIGraphicsImageRenderer(size: size)
	let controller = renderer.image { ctx in
		ctx.cgContext.setStrokeColor(color.cgColor)
		ctx.cgContext.setFillColor(color.cgColor)
		ctx.cgContext.setLineWidth(0)
		ctx.cgContext.move(to: CGPoint(x: 0, y: 0))
		ctx.cgContext.strokeEllipse(in: CGRect(origin: .zero, size: size))
		ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))

		// Create a label and render it to an image
		let label = SKLabelNode(text: " \(text) ")
		label.horizontalAlignmentMode = .center
		label.fontName = "Helvetica Bold"
		label.fontColor = .black
		label.alpha = 0.3
		label.fontSize = 18/UIScreen.main.scale
		label.position = CGPoint(x: size.width / 2, y: size.height / 2 - 16/UIScreen.main.scale)
		let view = SKView()
		let labelTexture = view.texture(from: label)
		let labelImage = UIImage(cgImage: labelTexture!.cgImage())

		// Draw the label image onto the button image
		labelImage.draw(at: CGPoint(x: (size.width - labelImage.size.width) / 2, y: (size.height - labelImage.size.height) / 2))
	}
	return SKTexture(image: controller)
}


func createEnemyShipTexture(color: UIColor) -> SKTexture {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 51, height: 42))
    let ship = renderer.image { ctx in
        // triangle ship
        ctx.cgContext.move(to: CGPoint(x: 51, y: 21))
        ctx.cgContext.addLine(to: CGPoint(x: 0, y: 42))
        ctx.cgContext.addLine(to: CGPoint(x: 9, y: 21))
        ctx.cgContext.addLine(to: CGPoint(x: 0, y: 0))
        ctx.cgContext.addLine(to: CGPoint(x: 51, y: 21))
    }
    return SKTexture(image: ship)
}

func createEngineTexture(color: UIColor = .nacelles) -> SKTexture {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 51, height: 42))
    let ship = renderer.image { ctx in
        ctx.cgContext.addRect(CGRect(x: 23, y: 10, width: 2, height: -4))
        ctx.cgContext.addRect(CGRect(x: 23, y: 32, width: 2, height: 4))
        ctx.cgContext.setLineWidth(LINE_WIDTH)
        ctx.cgContext.setStrokeColor(color.cgColor)
        ctx.cgContext.strokePath()
        ctx.cgContext.setFillColor(color.cgColor)
        ctx.cgContext.fill(CGRect(x: 23, y: 10, width: 2, height: -4))
        ctx.cgContext.fill(CGRect(x: 23, y: 32, width: 2, height: 4))
    }
    return SKTexture(image: ship)
}

func createShipTexture(color: UIColor = .ship) -> SKTexture {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 51, height: 42))
    let ship = renderer.image { ctx in
        drawPrimaryHull(ctx: ctx)
        drawSecondaryHull(ctx: ctx)
        drawStarboardNacelle(ctx: ctx)
        drawPortNacelle(ctx: ctx)
        ctx.cgContext.setLineWidth(LINE_WIDTH)
        ctx.cgContext.setStrokeColor(color.cgColor)
        ctx.cgContext.strokePath()
    }
    return SKTexture(image: ship)

    func drawPortNacelle(ctx: UIGraphicsImageRendererContext) {
        ctx.cgContext.move(to: CGPoint(x: 16, y: 17))
        ctx.cgContext.addLine(to: CGPoint(x: 16, y: 11))
        ctx.cgContext.addRect(CGRect(x: 1, y: 10, width: 24, height: -4))
    }

    func drawStarboardNacelle(ctx: UIGraphicsImageRendererContext) {
        ctx.cgContext.move(to: CGPoint(x: 16, y: 25))
        ctx.cgContext.addLine(to: CGPoint(x: 16, y: 31))
        ctx.cgContext.addRect(CGRect(x: 1, y: 32, width: 24, height: 4))
    }

    func drawSecondaryHull(ctx: UIGraphicsImageRendererContext) {
        ctx.cgContext.move(to: CGPoint(x: 26, y: 26))
        ctx.cgContext.addLine(to: CGPoint(x: 8, y: 24))
        ctx.cgContext.addLine(to: CGPoint(x: 8, y: 19))
        ctx.cgContext.addLine(to: CGPoint(x: 26, y: 17))
    }

    func drawPrimaryHull(ctx: UIGraphicsImageRendererContext) {
        ctx.cgContext.move(to: CGPoint(x: 25, y: 21))
        ctx.cgContext.addLine(to: CGPoint(x: 32, y: 33))
        ctx.cgContext.addLine(to: CGPoint(x: 43, y: 33))
        ctx.cgContext.addLine(to: CGPoint(x: 50, y: 21))
        ctx.cgContext.addLine(to: CGPoint(x: 43, y: 9))
        ctx.cgContext.addLine(to: CGPoint(x: 32, y: 9))
        ctx.cgContext.addLine(to: CGPoint(x: 25, y: 21))
    }

    /* 
    // Another way to do it with SKShapeNode, but it require a reference to the view to call view.texture(from:).
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 10, y: 0))
        path.addLine(to: CGPoint(x: -7, y: 7))
        path.addLine(to: CGPoint(x: -4, y: 0))
        path.addLine(to: CGPoint(x: -7, y: -7))
        path.addLine(to: CGPoint(x: 10, y: 0))
        let shipShape = SKShapeNode(path: path.cgPath)
        shipShape.xScale = 3
        shipShape.yScale = 3
        shipShape.strokeColor = UIColor.white
        shipShape.lineWidth = 3
        shipShape.lineJoin = .miter
        shipShape.lineCap = .square
        shipShape.position = CGPoint(x: 500, y: 300)
        let shapeTexture = view.texture(from: shipShape)
        return shapeTexture
     */
}

func createAsteroidTexture(radius: Double, color: UIColor) -> SKTexture {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: radius * 2, height: radius * 2))
    let asteroid = renderer.image { ctx in
        ctx.cgContext.translateBy(x: radius, y: radius) // move to center
		ctx.cgContext.setStrokeColor(color.cgColor)
        ctx.cgContext.setLineWidth(LINE_WIDTH)
        var angle = 0.0
        ctx.cgContext.move(to: CGPoint(x: radius, y: 0.0))
        while angle < (Double.pi * 2) {
            let length = (0.75 + Double.random(in: 0.0...0.25)) * radius
            let posX = cos(angle) * length
            let posY = sin(angle) * length
            let point = CGPoint(x: posX, y: posY)
            ctx.cgContext.addLine(to: point)
            angle += Double.random(in: 0.0...0.5)
        }
        ctx.cgContext.addLine(to: CGPoint(x: radius, y: 0.0))
        ctx.cgContext.strokePath()
    }
    return SKTexture(image: asteroid)
}

