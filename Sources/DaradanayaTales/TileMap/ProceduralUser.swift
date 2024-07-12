//
//  ProceduralUser.swift
//  Orion-Nebula
//
//  Created by Maxim Lanskoy on 04.04.2021.
//

import Foundation

final class ProceduralUser: Codable {
    var userId: Int64
    var position: WorldPosition
    var mapVisibleSize: Int
    var icon: String
    var mapMessageId: Int?
    var messageText: String?
    var additionalMessageText: String?
    var level: Int
    var exp: Double = 0
    
    enum CodingKeys: String, CodingKey {
        case userId
        case position
        case icon
        case mapMessageId
        case level
        case mapVisibleSize
    }
    
    init(userId: Int64, position: WorldPosition, icon: String, level: Int, mapVisibleSize: Int) {
        self.userId = userId
        self.position = position
        self.icon       = icon
        self.level        = level
        self.mapVisibleSize = mapVisibleSize
    }
    
    required init(from decoder: Decoder) throws {
        let values   = try decoder.container(keyedBy: CodingKeys.self)
        userId       = try values.decode(Int64.self,         forKey: .userId)
        position     = try values.decode(WorldPosition.self, forKey: .position)
        icon         = try values.decode(String.self,        forKey: .icon)
        mapMessageId = try values.decodeIfPresent(Int.self,  forKey: .mapMessageId)
        level         = try values.decode(Int.self,          forKey: .level)
        mapVisibleSize = try values.decode(Int.self,         forKey: .mapVisibleSize)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId,       forKey: .userId)
        try container.encode(position,     forKey: .position)
        try container.encode(icon,         forKey: .icon)
        try container.encode(mapMessageId, forKey: .mapMessageId)
        try container.encode(level,         forKey: .level)
        try container.encode(mapVisibleSize, forKey: .mapVisibleSize)
    }
}
