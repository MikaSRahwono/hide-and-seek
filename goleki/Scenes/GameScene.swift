//
//  GameScene.swift
//  goleki
//
//  Created by Mika S Rahwono on 11/06/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var button = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if button.contains(location) {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let mapScene = MapScene(size: self.size, level: 1)
                view?.presentScene(mapScene, transition: reveal)
            }
        }
    }
}


extension GameScene {
    func setupNodes() {
        createButton()
    }
    
    func createButton() {
        button = childNode(withName: "btnPlay") as! SKSpriteNode
        button.zPosition = 10
    }
}
