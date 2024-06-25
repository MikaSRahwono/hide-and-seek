//
//  Hider.swift
//  goleki
//
//  Created by Mika S Rahwono on 19/06/24.
//

import SpriteKit

class Hider: SKSpriteNode {
    
    var player: Player!
    var hidingObject: Object!
    var isFound: Bool!
    
    func setup() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 80))
        physicsBody?.categoryBitMask = bitMask.hider.rawValue
        physicsBody?.contactTestBitMask = bitMask.floor.rawValue
        physicsBody?.collisionBitMask = bitMask.walls.rawValue
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        isFound = false
    }
    
    func hide(object: Object) {
        if object.hider != nil {
          return
        } else {
            self.hidingObject = object
            object.hide(hider: self)
        }
    }
    
    func exit() {
        self.hidingObject.exit()
        self.hidingObject = nil
    }
    
    func found() {
        self.isFound = true
        self.hidingObject = nil
    }
}
