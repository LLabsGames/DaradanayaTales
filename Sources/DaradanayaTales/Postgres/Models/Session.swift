//
//  Session.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import FluentKit
import Foundation
import HummingbirdFluent
import Hummingbird

final class Coordinates: Fields, @unchecked Sendable {
    @Field(key: "latitude")
    var latitude: Double
    
    @Field(key: "longitude")
    var longitude: Double
    
    // Initialization
    init() { }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

final class Session: Model, @unchecked Sendable {
    static let schema = "sessions"
    
    @ID(custom: "chat_id", generatedBy: .user)
    var id: Int64?
    
    @Field(key: "name")
    var name: String
    
    @Group(key: "coordinates")
    var coordinates: Coordinates
    
    init() {}
    
    init(id: Int64, name: String, coordinates: Coordinates) {
        self.id = id
        self.name = name
        self.coordinates = coordinates
    }
}

extension Session: ResponseCodable, Codable {}
