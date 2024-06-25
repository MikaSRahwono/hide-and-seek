//
//  ResidenceScene.swift
//  goleki
//
//  Created by Mika S Rahwono on 19/06/24.
//

import SpriteKit
import GameplayKit

class ResidenceScene: SKScene {
    
    var person: Person!
    let cam = SKCameraNode()
    var leftButton = SKNode()
    var rightButton = SKNode()
    var downButton = SKNode()
    var upButton = SKNode()
    var actionButton = SKNode()
    var ray: SKPhysicsBody!
    var sandArray = [SKSpriteNode]()
    
//    let walkingSound = SKAction.playSoundFileNamed("walkingSFX.mp3", waitForCompletion: false)
//    let bombSound = SKAction.playSoundFileNamed("bombSFX.mp3", waitForCompletion: false)
//    let shovelSound = SKAction.playSoundFileNamed("shovelSFX.mp3", waitForCompletion: false)
//    let chestSound = SKAction.playSoundFileNamed("treasureSFX.mp3", waitForCompletion: false)
    
    var lastRayPos = CGPoint(x: 0, y: 0)
    var treasurePos = CGPoint(x: 0, y: 0)
    var bombPos = CGPoint(x: 0, y: 0)
    
    var gameover: Bool = false
    var herMovesLeft = false
    var herMovesRight = false
    var herMovesUp = false
    var herMovesDown = false
    
    var sandCount: Int = 0
    var level: Int = 0
    
    var isTouchEnded: Bool = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        print("masuk kesini")
        self.camera = cam
        
        if let mapNode = self.childNode(withName: "map") as? SKTileMapNode {
            mapNode.setScale(3)
            var zPos: CGFloat = 1
            for node in mapNode.children {
                var scale: CGFloat = 1 * mapNode.xScale
                if node.name == "Bridges"{
                    scale = 1.75 * mapNode.xScale
                }
                zPos += 1
                if let tileMap: SKTileMapNode = node as? SKTileMapNode {
                    for childChildNode in tileMap.children {
                        zPos += 1
                        if let childTileMap: SKTileMapNode = childChildNode as? SKTileMapNode {
                            giveTileMapPhysicsBody(map: childTileMap, parentScale: scale, zPos: zPos, parentTileMap: tileMap)
                            childTileMap.removeFromParent()
                        }
                    }
                    zPos += 1
                    giveTileMapPhysicsBody(map: tileMap, parentScale: scale, zPos: zPos, parentTileMap: tileMap)
                    tileMap.removeFromParent()
                }
            }
        }
        
//        
//        for node in self.children {
//            if (node.name == "map.walls"){
//                if let someTileMap: SKTileMapNode = node as? SKTileMapNode {
//                    print("masuk kesini")
//                    giveTileMapPhysicsBody(map: someTileMap)
//
//                    someTileMap.removeFromParent()
//                }
//            }
//            
//            if (node.name == "floor") {
//                if let someTileMap: SKTileMapNode = node as? SKTileMapNode {
//                    giveTileMapPhysicsBody(map: someTileMap)
//                    
//                    someTileMap.removeFromParent()
//                }
//                break
//            }
//        }
        
        addObject()
    }
    
    func addObject() {
        person = childNode(withName: "Person") as? Person
        person.setup()
        lastRayPos = CGPoint(x: person.position.x + 70, y: person.position.y)
        
        
//        highlight = childNode(withName: "highlited") as! SKSpriteNode
        
        actionButton = childNode(withName: "actionButton") as! SKSpriteNode
//        closeButton = childNode(withName: "buttonClose") as! SKSpriteNode
        
        

        
        for node in self.children {
            if node.name == "buttonLeft" && !gameover {
//                    run(walkingSound)
                leftButton = node
                herMovesLeft = true
            }
            
            if node.name == "buttonRight" && !gameover {
//                    run(walkingSound)
                rightButton = node
                herMovesRight = true
            }
            
            if node.name == "buttonUp" && !gameover {
//                    run(walkingSound)
                upButton = node
                herMovesUp = true
            }
            
            if node.name == "buttonDown" && !gameover {
//                    run(walkingSound)
                downButton = node
                herMovesDown = true
            }
        }
    }
    
    func giveTileMapPhysicsBody(map: SKTileMapNode, parentScale: CGFloat, zPos: CGFloat, parentTileMap: SKTileMapNode) {
        let tileMap = map
        let startLocation: CGPoint = parentTileMap.position
        let tileSize = tileMap.tileSize
        let scaledTileSize = CGSize(width: tileSize.width * parentScale, height: tileSize.height * parentScale)
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * scaledTileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * scaledTileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    
                    let tileArray = tileDefinition.textures
                    let tileTextures = tileArray[0]
                    let x = CGFloat(col) * scaledTileSize.width - halfWidth + (scaledTileSize.width / 2)
                    let y = CGFloat(row) * scaledTileSize.height - halfHeight + (scaledTileSize.height / 2)
                    
                    let tileNode = SKSpriteNode(texture: tileTextures)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.size = scaledTileSize
                    tileNode.physicsBody = SKPhysicsBody(texture: tileTextures, size: scaledTileSize)
                    print("masuk")
                    
                    if tileMap.name == "walls" {
                        tileNode.physicsBody?.categoryBitMask = bitMask.walls.rawValue
                        tileNode.physicsBody?.contactTestBitMask = 0
                        tileNode.physicsBody?.collisionBitMask = bitMask.person.rawValue
                        print("walls_collisions")
                    }
                    else {
                        tileNode.physicsBody?.categoryBitMask = bitMask.floor.rawValue
                        tileNode.physicsBody?.contactTestBitMask = bitMask.raycast.rawValue
                        tileNode.physicsBody?.collisionBitMask = 0
                        sandArray.append(tileNode)
                    }
                    
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = zPos
                    
                    tileNode.position = CGPoint(x: tileNode.position.x + startLocation.x * parentScale, y: tileNode.position.y  + startLocation.y * parentScale)
                    self.addChild(tileNode)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let position = touch.location(in: self)
            let touchNode = self.nodes(at: position)
            
            for node in touchNode {
                if node.name == "buttonLeft" && !gameover {
//                    run(walkingSound)
                    herMovesLeft = true
                }
                
                if node.name == "buttonRight" && !gameover {
//                    run(walkingSound)
                    herMovesRight = true
                }
                
                if node.name == "buttonUp" && !gameover {
//                    run(walkingSound)
                    herMovesUp = true
                }
                
                if node.name == "buttonDown" && !gameover {
//                    run(walkingSound)
                    herMovesDown = true
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let position = touch.location(in: self)
            let touchNode = self.nodes(at: position)
            
            for _ in touchNode {
                if !gameover {
                    herMovesUp = false
                    herMovesDown = false
                    herMovesLeft = false
                    herMovesRight = false
                    
//                    if actionButton.contains(position) && !gameover {
//                        let highlightPosition = CGPoint(x: round(highlight.position.x * 10) / 10.0, y: round(highlight.position.y * 10) / 10.0 )
//                        let bombPosition = CGPoint(x: round(bombPos.x * 10) / 10.0, y: round(bombPos.y * 10) / 10.0)
//                        let treasurePosition = CGPoint(x: round(treasurePos.x * 10) / 10.0, y: round(treasurePos.y * 10) / 10.0)
//
//                        if highlightPosition == treasurePosition {
//                            let generator = UIImpactFeedbackGenerator(style: .medium)
//                            generator.impactOccurred()
//                            self.run(SKAction.sequence([
//                                SKAction.run { [self] in
//                                    self.treasure.texture = SKTexture(imageNamed: "treasure_close")
//                                    self.treasure.isHidden = false
//                                },
//                                SKAction.wait(forDuration: 0.1),
//                                SKAction.run { [self] in
//                                    self.treasure.texture = SKTexture(imageNamed: "treasure_open_little")
//                                },
//                                SKAction.wait(forDuration: 0.1),
//                                SKAction.run { [self] in
//                                    self.treasure.texture = SKTexture(imageNamed: "treasure_open_half")
//                                },
//                                SKAction.wait(forDuration: 0.1),
//                                SKAction.run { [self] in
//                                    self.treasure.texture = SKTexture(imageNamed: "Treasure")
//                                },
//                                SKAction.wait(forDuration: 0.2)
//                            ]))
//                            gameover = true
//                            level += 1
//                            run(SKAction.sequence([
//                                chestSound,
//                                SKAction.wait(forDuration: 1.0),
//                                SKAction.run() { [weak self] in
//                                    guard let `self` = self else { return }
//                                    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//
//                                    let levelScene = LevelScene(size: view!.bounds.size, level: level)
//                                    let creditScene = CreditScene(size: view!.bounds.size, titleName: "Thank You For Playing")
//
//                                    if level > 3 {
//                                        view?.presentScene(creditScene, transition: reveal)
//                                    }
//                                    else {
//                                        view?.presentScene(levelScene, transition: reveal)
//                                    }
//                                }
//                            ]))
//                        }
//
//                        else if highlightPosition == bombPosition {
//                            let generator = UIImpactFeedbackGenerator(style: .heavy)
//                            generator.impactOccurred()
//                            bomb.isHidden = false
//                            gameover = true
//                            run(SKAction.sequence([
//                                bombSound,
//                                SKAction.wait(forDuration: 1.0),
//                                SKAction.run() { [weak self] in
//                                    guard let `self` = self else { return }
//                                    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//                                    let creditScene = CreditScene(size: view!.bounds.size, titleName: "GAME OVER")
//                                    view?.presentScene(creditScene, transition: reveal)
//                                }
//                            ]))
//                        }
//
//                        else {
//                            for array in zonkArray {
//                                let zonkPosition = CGPoint(x: round(array.position.x * 10) / 10.0, y: round(array.position.y * 10) / 10.0)
//
//                                if highlightPosition == zonkPosition && array.isHidden == true {
//                                    run(shovelSound)
//                                    array.isHidden = false
//                                    break
//                                }
//                            }
//                        }
//                    }
                }
                
//                if closeButton.contains(position) {
//                    run(SKAction.sequence([
//                        SKAction.wait(forDuration: 0.5),
//                        SKAction.run() { [weak self] in
//                            guard let `self` = self else { return }
//                            let reveal = SKTransition.fade(withDuration: 0.5)
//                            let scene = GameScene(fileNamed: "GameScene")
//                            scene!.size = view!.bounds.size
//                            scene!.scaleMode = .aspectFill
//                            self.view?.presentScene(scene!, transition:reveal)
//                        }
//                    ]))
//                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        var xDirection = 0.0
        var yDirection = 0.0
        
        if herMovesRight == true {
            person.position.x += 5
            xDirection = 1
            isTouchEnded = false
        }
        
        if herMovesLeft == true {
            person.position.x -= 5
            xDirection = -1
            isTouchEnded = false
        }
        
        if herMovesUp == true {
            person.position.y += 5
            yDirection = 1
            isTouchEnded = false
        }
        
        if herMovesDown == true {
            person.position.y -= 5
            yDirection = -1
            isTouchEnded = false
        }
        
        if !herMovesUp && !herMovesDown && !herMovesLeft && !herMovesRight {
            isTouchEnded = true
        }
        
        let lastPos = (xDirection == 0 && yDirection == 0) ? lastRayPos : person.position
        let rayPos = CGPoint(x: lastPos.x + xDirection * 70, y: lastPos.y + yDirection * 70)
        
        ray = SKPhysicsBody(circleOfRadius: 10, center: rayPos)
        ray.categoryBitMask = bitMask.raycast.rawValue
        ray.contactTestBitMask = bitMask.floor.rawValue
        ray.collisionBitMask = bitMask.walls.rawValue
        physicsBody = ray
        lastRayPos = rayPos
        
        if person.position.x > 340 {
            cam.position = CGPoint(x: 340, y: person.position.y)
            if person.position.y > 535 {
                cam.position = CGPoint(x: 340, y: 540)
            } else if person.position.y < -680 {
                cam.position = CGPoint(x: 340, y: -680)
            }
        } else if person.position.x < -298 {
            cam.position = CGPoint(x: -298, y: person.position.y)
            if person.position.y > 540 {
                cam.position = CGPoint(x: -298, y: 540)
            } else if person.position.y < -680 {
                cam.position = CGPoint(x: -298, y: -680)
            }
        } else if person.position.y > 540 {
            cam.position = CGPoint(x: person.position.x, y: 540)
            if person.position.x > 340 {
                cam.position = CGPoint(x: 340, y: 540)
            } else if person.position.x < -298 {
                cam.position = CGPoint(x: -298, y: 540)
            }
        } else if person.position.y < -680 {
            cam.position = CGPoint(x: person.position.x, y: -680)
            if person.position.x > 340 {
                cam.position = CGPoint(x: 340, y: -680)
            } else if person.position.x < -298 {
                cam.position = CGPoint(x: -298, y: -680)
            }
        } else {
            cam.position = person.position
        }
        
        leftButton.position.x = cam.position.x - 560
        leftButton.position.y = cam.position.y - 175
        rightButton.position.x = cam.position.x - 390
        rightButton.position.y = cam.position.y - 175
        upButton.position.x = cam.position.x - 475
        upButton.position.y = cam.position.y - 90
        downButton.position.x = cam.position.x - 475
        downButton.position.y = cam.position.y - 260
        actionButton.position.x = cam.position.x + 475
        actionButton.position.y = cam.position.y - 175
        
        person.zPosition = 99999
        leftButton.zPosition = 99999
        rightButton.zPosition = 99999
        upButton.zPosition = 99999
        downButton.zPosition = 99999
    }
}
