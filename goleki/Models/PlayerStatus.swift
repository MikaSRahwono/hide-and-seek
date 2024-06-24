//
//  PlayerStatus.swift
//  goleki
//
//  Created by Muhammad Yusuf on 24/06/24.
//

import Foundation
import UIKit

enum PlayerStatus: String, Codable {
    case idle
    case attack
    case hit
    
    func image(player: PlayerType) -> UIImage {
        return UIImage(named: "\(player.rawValue)_\(self.rawValue)")!
    }
}
