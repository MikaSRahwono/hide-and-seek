//
//  ContactHelper.swift
//  goleki
//
//  Created by Mika S Rahwono on 19/06/24.
//

import SpriteKit

enum bitMask: UInt32 {
    case person = 0x1
    case floor = 0x5
    case highlight = 0x3
    case walls = 0x2
    case raycast = 0x4
}

extension ResidenceScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bitmaskA = contact.bodyA.categoryBitMask
        let bitmaskB = contact.bodyB.categoryBitMask
        
        if (bitmaskA == bitMask.raycast.rawValue && bitmaskB == bitMask.floor.rawValue && !isTouchEnded) {
//            highlight.position = contact.bodyB.node!.position
            print("kesini2")
            isTouchEnded = false
            
        } else if (bitmaskA == bitMask.floor.rawValue && bitmaskB == bitMask.raycast.rawValue && !isTouchEnded) {
//            highlight.position = contact.bodyA.node!.position
            print("kesini3")
            isTouchEnded = false
        }
    }
}
