//
//  ProceduralMonster.swift
//  Orion-Nebula
//
//  Created by Maxim Lanskoy on 04.04.2021.
//

import Foundation

final class ProceduralMonster {
    let icon: String
    var position: WorldPosition
    var aimToUser: Int64?
    
    enum CodingKeys: String, CodingKey {
        case icon
        case position
    }
    
    init(icon: String = "🐺", level: Int, position: WorldPosition) {
        self.icon = icon
        self.position = position
    }
    
    required init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        icon = try container.decode(String.self, forKey: .icon)
        position = try container.decode(WorldPosition.self, forKey: .position)
    }
}
