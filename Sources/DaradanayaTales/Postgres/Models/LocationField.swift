//
//  LocationField.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import FluentKit

final class Location: Fields, @unchecked Sendable {
    @Field(key: "universe")
    var universe: String

    @Field(key: "galaxy")
    var galaxy: String

    @Field(key: "planet")
    var planet: String

    @Field(key: "route")
    var route: String

    init() { }

    init(universe: String = "Euclid", galaxy: String = "IO-1", planet: String = "Kassiopea", route: String) {
        self.universe = universe
        self.galaxy = galaxy
        self.planet = planet
        self.route = route
    }
}
