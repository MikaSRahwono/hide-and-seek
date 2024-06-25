//
//  Seeker.swift
//  goleki
//
//  Created by Mika S Rahwono on 24/06/24.
//

import SpriteKit

class Seeker: SKSpriteNode {
    
    var isFound: Bool!
    
    func setup() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 80))
        physicsBody?.categoryBitMask = bitMask.person.rawValue
        physicsBody?.contactTestBitMask = bitMask.floor.rawValue
        physicsBody?.collisionBitMask = bitMask.walls.rawValue
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        isFound = false
    }
}
