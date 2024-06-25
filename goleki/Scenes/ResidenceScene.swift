//
//  ResidenceScene.swift
//  goleki
//
//  Created by Mika S Rahwono on 19/06/24.
//

import SpriteKit
import GameplayKit
import GameKit

class ResidenceScene: SKScene {
    
    var person: Person!
    var seeker: Seeker!
    
    var match: GKMatch?
    
    var isHider: Bool!
    
    let cam = SKCameraNode()
    var leftButton = SKNode()
    var rightButton = SKNode()
    var downButton = SKNode()
    var upButton = SKNode()
    var actionButton = SKNode()
    var highlight = SKNode()
    var ray: SKPhysicsBody!
    
    var hiderPlayerMap: [Person] = []
    var seekerPlayerMap: [Seeker] = []
    var objectMap: [CGPoint: Object] = [:]
    var hiderMap: [CGPoint: Person] = [:]
    
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
    var foundHiders: Int = 0
    
    var isTouchEnded: Bool = false
    
    private var gameModel: GameModel!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        isHider = true
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
                    if tileMap.name == "object"{
                        let position = CGPoint(x: ceil(tileMap.position.x * 3 / 100) * 100.0, y: ceil(tileMap.position.y * 3 / 100) * 100.0 )
                        let object = Object(tileMapNode: tileMap)
                        objectMap[position] = object
                        giveTileMapPhysicsBody(map: tileMap, parentScale: scale, zPos: zPos, parentTileMap: tileMap)
                        zPos += 1
                        continue
                    }
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
        addObject()
    }
    
    func addObject() {
        if isHider {
            person = childNode(withName: "Person") as? Person
            person.setup()
        } else {
            seeker = childNode(withName: "Seeker") as? Seeker
            seeker.setup()
        }
        lastRayPos = CGPoint(x: person.position.x + 70, y: person.position.y)
        actionButton = childNode(withName: "actionButton") as! SKSpriteNode
        
        for node in self.children {
            if node.name == "buttonLeft" && !gameover {
                leftButton = node
                herMovesLeft = true
            }
            
            if node.name == "buttonRight" && !gameover {
                rightButton = node
                herMovesRight = true
            }
            
            if node.name == "buttonUp" && !gameover {
                upButton = node
                herMovesUp = true
            }
            
            if node.name == "buttonDown" && !gameover {
                downButton = node
                herMovesDown = true
            }
        }
        
        for seeker in seekerPlayerMap {
            self.addChild(seeker)
        }
        for hider in hiderPlayerMap {
            self.addChild(hider)
        }
    }
    
    private func savePlayers() {
        guard let player2Name = match?.players.first?.displayName else { return }
        let player1 = Player(displayName: GKLocalPlayer.local.displayName)
        let player2 = Player(displayName: player2Name)
        
        gameModel.players = [player1, player2]
        
        gameModel.players.sort { (player1, player2) -> Bool in
            player1.displayName < player2.displayName
        }
        
        sendData()
    }
    
    private func sendData() {
        guard let match = match else { return }
        
        do {
            guard let data = gameModel.encode() else { return }
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Send data failed")
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
                    
                    if tileMap.name == "walls" {
                        tileNode.physicsBody?.categoryBitMask = bitMask.walls.rawValue
                        tileNode.physicsBody?.contactTestBitMask = 0
                        tileNode.physicsBody?.collisionBitMask = bitMask.person.rawValue
                    } else if tileMap.name == "object" {
                        tileNode.physicsBody?.categoryBitMask = bitMask.walls.rawValue
                        tileNode.physicsBody?.contactTestBitMask = 0
                        tileNode.physicsBody?.collisionBitMask = bitMask.person.rawValue
                    }
                    else {
                        tileNode.physicsBody?.categoryBitMask = bitMask.floor.rawValue
                        tileNode.physicsBody?.contactTestBitMask = bitMask.raycast.rawValue
                        tileNode.physicsBody?.collisionBitMask = 0
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
                    if isHider == true {
                        if actionButton.contains(position) && !gameover {
                            let highlightPosition = CGPoint(x: ceil(lastRayPos.x / 100) * 100.0, y: ceil(lastRayPos.y / 100) * 100.0 )
                            if person.hidingObject != nil {
                                person.exit()
                                person.zPosition = 999999
                            } else if let object = objectMap[highlightPosition] {
                                if object.isAvailable() {
                                    person.hide(object: object)
                                    object.hide(person: person)
                                    person.zPosition = 0.1
                                } else {
                                    
                                }
                            }
                        }
                    } else {
                        if actionButton.contains(position) && !gameover {
                            let highlightPosition = CGPoint(x: round(lastRayPos.x / 100) * 100.0, y: round(lastRayPos.y / 100) * 100.0 )
                            if let object = objectMap[highlightPosition] {
                                if object.find() {
                                    foundHiders += 1
                                } else {
                                    
                                }
                            } else if let personFound = hiderMap[highlightPosition]{
                                foundHiders += 1
                                personFound.found()
                            }
                        }

                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        var xDirection = 0.0
        var yDirection = 0.0
        
        var lastPos = lastRayPos
        
        if isHider {
            if person.hidingObject != nil {
                return
            }
            if herMovesRight == true {
                person.position.x += 5
                xDirection = 1
                isTouchEnded = false
                person.texture = SKTexture(imageNamed: "hider1_right_move1")
            }
            
            if herMovesLeft == true {
                person.position.x -= 5
                xDirection = -1
                isTouchEnded = false
                person.texture = SKTexture(imageNamed: "hider1_left_move1")
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
            lastPos = (xDirection == 0 && yDirection == 0) ? lastRayPos : person.position
            person.zPosition = 99999
            
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
            
        } else {
            if herMovesRight == true {
                seeker.position.x += 5
                xDirection = 1
                isTouchEnded = false
                seeker.texture = SKTexture(imageNamed: "hider1_right_move1")
            }
            
            if herMovesLeft == true {
                seeker.position.x -= 5
                xDirection = -1
                isTouchEnded = false
                seeker.texture = SKTexture(imageNamed: "hider1_left_move1")
            }
            
            if herMovesUp == true {
                seeker.position.y += 5
                yDirection = 1
                isTouchEnded = false
            }
            
            if herMovesDown == true {
                seeker.position.y -= 5
                yDirection = -1
                isTouchEnded = false
            }
            lastPos = (xDirection == 0 && yDirection == 0) ? lastRayPos : seeker.position
            seeker.zPosition = 99999
            
            if seeker.position.x > 340 {
                cam.position = CGPoint(x: 340, y: seeker.position.y)
                if seeker.position.y > 535 {
                    cam.position = CGPoint(x: 340, y: 540)
                } else if seeker.position.y < -680 {
                    cam.position = CGPoint(x: 340, y: -680)
                }
            } else if seeker.position.x < -298 {
                cam.position = CGPoint(x: -298, y: seeker.position.y)
                if seeker.position.y > 540 {
                    cam.position = CGPoint(x: -298, y: 540)
                } else if seeker.position.y < -680 {
                    cam.position = CGPoint(x: -298, y: -680)
                }
            } else if seeker.position.y > 540 {
                cam.position = CGPoint(x: seeker.position.x, y: 540)
                if seeker.position.x > 340 {
                    cam.position = CGPoint(x: 340, y: 540)
                } else if seeker.position.x < -298 {
                    cam.position = CGPoint(x: -298, y: 540)
                }
            } else if seeker.position.y < -680 {
                cam.position = CGPoint(x: seeker.position.x, y: -680)
                if seeker.position.x > 340 {
                    cam.position = CGPoint(x: 340, y: -680)
                } else if seeker.position.x < -298 {
                    cam.position = CGPoint(x: -298, y: -680)
                }
            } else {
                cam.position = seeker.position
            }
        }
        

        
        if !herMovesUp && !herMovesDown && !herMovesLeft && !herMovesRight {
            isTouchEnded = true
        }
        
        
        let rayPos = CGPoint(x: lastPos.x + xDirection * 70, y: lastPos.y + yDirection * 70)
        
        ray = SKPhysicsBody(circleOfRadius: 10, center: rayPos)
        ray.categoryBitMask = bitMask.raycast.rawValue
        ray.contactTestBitMask = bitMask.floor.rawValue
        ray.collisionBitMask = bitMask.walls.rawValue
        physicsBody = ray
        lastRayPos = rayPos
        
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
        
        leftButton.zPosition = 99999
        rightButton.zPosition = 99999
        upButton.zPosition = 99999
        downButton.zPosition = 99999
        
        if isHider == true {
            hiderMap[person.position] = self.person
        } else {
            
        }
    }
}
