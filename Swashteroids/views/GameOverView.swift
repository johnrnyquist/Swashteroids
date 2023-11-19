//
//  GameOverView.swift
//  Swashteroids
//
//  Created by John Nyquist on 11/19/23.
//

import SpriteKit


class GameOVerView: SKSpriteNode {
	private var gameOver: SKLabelNode = {
		let gameOver = SKLabelNode(text: "Game Over")
		gameOver.fontName = "Helvetica"
		gameOver.fontColor = .waitText
		gameOver.fontSize = 72
		gameOver.horizontalAlignmentMode = .center
		gameOver.position = CGPoint(x: 512, y: 400)
		return gameOver
	}()

	init() {
		super.init(texture: nil, color: .clear, size: CGSize(width: 1024, height: 768))
		name = "gameOver"
		anchorPoint = .zero
		addChild(gameOver)
		zPosition = Layers.wait.rawValue
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


