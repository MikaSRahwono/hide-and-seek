//
//  Object.swift
//  goleki
//
//  Created by Mika S Rahwono on 24/06/24.
//

import SpriteKit

class Object {
    
    var item: Item!
    var hider: Hider!
    var tileMapNode: SKTileMapNode
    
    init(tileMapNode: SKTileMapNode) {
        self.tileMapNode = tileMapNode
    }
    
    func hide(hider: Hider) {
        self.hider = hider
    }
    
    func isAvailable() -> Bool{
        if hider != nil {
            return false
        }
        return true
    }
    
    func exit() {
        self.hider = nil
    }
    
    func find() -> Bool! {
        if let hider = self.hider {
            hider.found()
            self.hider = nil
            self.item.player = nil
            return true
        } else {
            return false
        }
    }
}
