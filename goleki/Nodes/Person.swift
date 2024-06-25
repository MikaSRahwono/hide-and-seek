//
//  Person.swift
//  goleki
//
//  Created by Mika S Rahwono on 19/06/24.
//

import SpriteKit

class Person: SKSpriteNode {
    
    
//    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
//        super.init(texture: texture, color: color, size: size)
//
//        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 80))
//        physicsBody?.categoryBitMask = bitMask.person.rawValue
//        physicsBody?.contactTestBitMask = bitMask.sand.rawValue
//        physicsBody?.collisionBitMask = bitMask.wall.rawValue
//        physicsBody?.allowsRotation = false
//        physicsBody?.affectedByGravity = false
//    }
//
////    convenience init(imageNamed name: String) {
////        let texture = SKTexture(imageNamed: name)
////        self.init(texture: texture, color: .white, size: texture.size())
////    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("error")
//    }
    
    func setup() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 80))
        physicsBody?.categoryBitMask = bitMask.person.rawValue
        physicsBody?.contactTestBitMask = bitMask.floor.rawValue
        physicsBody?.collisionBitMask = bitMask.walls.rawValue
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
    }
}
