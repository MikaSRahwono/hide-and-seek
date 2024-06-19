//
//  MapScene.swift
//  goleki
//
//  Created by Mika S Rahwono on 19/06/24.
//
//


import SpriteKit

class MapScene: SKScene {
    init(size: CGSize, level: Int) {
        super.init(size: size)
        
//        let label = SKLabelNode(fontNamed: "PixelGameFont")
//        label.text = "LEVEL  \(level)"
//        label.fontSize = 40
//        label.fontColor = UIColor(named: "Cream")!
//        label.position = CGPoint(x: size.width/2, y: size.height/2)
//        addChild(label)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run() { [weak self] in
                guard let `self` = self else { return }
                let reveal = SKTransition.flipHorizontal(withDuration: 1)
                switch (level) {
                case 1:
                    let scene = ResidenceScene(fileNamed: "ResidenceScene")!
                    scene.level = level
                    scene.sandCount = 7
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene, transition:reveal)
                default:
                    let scene = GameScene()
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene, transition:reveal)
                }
            }
        ]))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
