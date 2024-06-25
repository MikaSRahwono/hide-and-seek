//
//  Object.swift
//  goleki
//
//  Created by Mika S Rahwono on 24/06/24.
//

import SpriteKit

class Object {
    
    var person: Person!
    var tileMapNode: SKTileMapNode
    
    init(tileMapNode: SKTileMapNode) {
        self.tileMapNode = tileMapNode
    }
    
    func hide(person: Person) {
        self.person = person
    }
    
    func isAvailable() -> Bool{
        if person != nil {
            return false
        }
        return true
    }
    
    func exit() {
        self.person = nil
    }
    
    func find() -> Bool! {
        if let person = self.person {
            person.found()
            self.person = nil
            return true
        } else {
            return false
        }
    }
}
