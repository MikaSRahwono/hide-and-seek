//
//  GameModel.swift
//  goleki
//
//  Created by Muhammad Yusuf on 24/06/24.
//

import Foundation
import UIKit
import GameKit

struct GameModel: Codable {
    var players: [Player] = []
    var items: [CGPoint: Item] = [:]
}

extension GameModel {
    func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func decode(data: Data) -> GameModel? {
        return try? JSONDecoder().decode(GameModel.self, from: data)
    }
}
