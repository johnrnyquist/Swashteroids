//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit

let LINE_WIDTH: Double = 2

/// These methods for creating textures were fun to do but I'll eventually remove them.
func createTorpedoTexture(color: UIColor) -> SKTexture {
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

func createNacelleTexture(color: UIColor = .nacelles) -> SKTexture {
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


