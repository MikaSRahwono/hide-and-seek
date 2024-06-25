//
//  Person.swift
//  goleki
//
//  Created by Mika S Rahwono on 19/06/24.
//

import SpriteKit

class Person: SKSpriteNode {
    
    var hidingObject: Object!
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
    
    func hide(object: Object) {
        if let personHiding = object.person {
          return
        } else {
            self.hidingObject = object
            object.hide(person: self)
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
