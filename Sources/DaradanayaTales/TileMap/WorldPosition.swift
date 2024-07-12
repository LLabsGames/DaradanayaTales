//
//  DungeonPosition.swift
//  Orion-Nebula
//
//  Created by Maxim Lanskoy on 04.04.2021.
//

import Foundation

struct WorldPosition: Codable, Equatable {
    
    static let Zero = WorldPosition(c: -1, r: -1)
    
    var c: Int
    var r: Int
    
    func distanceTo(neededPosition: WorldPosition) -> (Int, Direction) {
        let currentPosition = self
        
        // Horizontal Distance and Direction
        let directXDistance = abs(currentPosition.c - neededPosition.c)
        let wrapXDistance = FreeLevelGenerator.defaultMapSize - directXDistance
        let xDistance = min(directXDistance, wrapXDistance)
        var isDownWards = currentPosition.c > neededPosition.c
        if wrapXDistance < directXDistance {
            isDownWards = !isDownWards
        }
        
        // Vertical Distance and Direction
        let directYDistance = abs(currentPosition.r - neededPosition.r)
        let wrapYDistance = FreeLevelGenerator.defaultMapSize - directYDistance
        let yDistance = min(directYDistance, wrapYDistance)
        var isRightWards = currentPosition.r < neededPosition.r
        if wrapYDistance < directYDistance {
            isRightWards = !isRightWards
        }
        
        // Return if only horizontal or vertical movement is needed
        guard yDistance != 0 else { return (xDistance, isDownWards ? .up : .down) }
        guard xDistance != 0 else { return (yDistance, isRightWards ? .right : .left) }
        
        // Diagonal Distance and Direction
        let xFloat = Float(xDistance); let yFloat = Float(yDistance)
        let hipotenuzeDistance = (xFloat * xFloat + yFloat * yFloat).squareRoot()
        var diagonalDirection: Direction = .down
        if isDownWards && !isRightWards {
            diagonalDirection = .upLeft
        } else if !isDownWards && isRightWards {
            diagonalDirection = .downRight
        } else if isDownWards && isRightWards {
            diagonalDirection = .upRight
        } else if !isDownWards && !isRightWards {
            diagonalDirection = .downLeft
        }
        
        return (Int(hipotenuzeDistance), diagonalDirection)
    }
    
    func distanceTo(neededPosition: (Int, Int)) -> (Int, Direction) {
        let tmpPosition = WorldPosition(c: neededPosition.1, r: neededPosition.0)
        return distanceTo(neededPosition: tmpPosition)
    }
}

func ==(lhs: WorldPosition, rhs: WorldPosition) -> Bool {
    return lhs.c == rhs.c && lhs.r == rhs.r
}
func ==(lhs: WorldPosition, rhs: (Int,Int)) -> Bool {
    return lhs.c == rhs.1 && lhs.r == rhs.0
}
func !=(lhs: WorldPosition, rhs: WorldPosition) -> Bool {
    return lhs.c != rhs.c && lhs.r != rhs.r
}

enum Direction: String, Codable, CaseIterable {
    case up        = "⬆️"
    case down      = "⬇️"
    case left      = "⬅️"
    case right     = "➡️"
    
    case upLeft    = "↖️"
    case upRight   = "↗️"
    case downLeft  = "↙️"
    case downRight = "↘️"
}
