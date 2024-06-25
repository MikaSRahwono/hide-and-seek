//
//  Player.swift
//  goleki
//
//  Created by Muhammad Yusuf on 24/06/24.
//

import Foundation
import UIKit

struct Player: Codable {
    var displayName: String
    var position: CGPoint
    var role: PlayerRole
    var isFound: Bool
}
