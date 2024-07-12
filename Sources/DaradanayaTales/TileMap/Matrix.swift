//
//  Matrix<T>.swift
//  Orion-Nebula
//
//  Created by Maxim Lanskoy on 06.03.2021.
//

import Foundation

struct Matrix<T:Codable>: Codable {
    let rows: Int, columns: Int
    var grid: [T]
    
    init(rows: Int, columns: Int, defaultValue: T) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: defaultValue, count: rows * columns)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> T {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case rows
        case columns
        case grid
    }
    
    init(from decoder: Decoder) throws {
        let values  = try decoder.container(keyedBy: CodingKeys.self)
        rows      = try values.decode(Int.self,       forKey: .rows)
        columns = try values.decode(Int.self,         forKey: .columns)
        grid  = try values.decode([T].self,           forKey: .grid)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rows,    forKey: .rows)
        try container.encode(columns, forKey: .columns)
        try container.encode(grid,    forKey: .grid)
    }
    
    func normalizeIndex(row: Int, col: Int) -> (row: Int, col: Int) {
        var universalCol: Int
        var universalRow: Int
        if col >= 0 && col < self.columns {
            universalCol = col
        } else if col >= self.columns {
            universalCol = col - self.columns
        } else /*if col < 0*/ {
            universalCol = self.columns + col
        }
        if row >= 0 && row < self.rows {
            universalRow = row
        } else if row >= self.rows {
            universalRow = row - self.rows
        } else /*if row < 0*/ {
            universalRow = self.rows + row
        }
        return (universalRow, universalCol)
    }
}

extension Matrix {
    func createOutputForPlayer(allUsers: [Session], session: Session?, mobs: [PlanetaryMonster], elites: [PlanetaryElite], resources: [PlanetaryResource], dungeons: [PlanetaryDungeonEntrance], full: Bool = false) -> String? {
        var message: String = ""
        let index: (Int, Int)
        let halfOfArea: Int
        if let safeSession = session {
            index = (safeSession.location.coordinates.x, safeSession.location.coordinates.y)
        } else {
            index = (Int(round(Float(columns)/2.0)), Int(round(Float(rows)/2.0)))
        }
        if let safeSession = session {
            halfOfArea = Int(round(Float(safeSession.settings.emojiMapsize)/2.0))
        } else {
            halfOfArea = Int(round(Float(columns)/2.0))
        }
        
        // Adjusted range calculation with wrap-around support
        let rangeCol: ClosedRange<Int> = session != nil ? ((index.0 - halfOfArea) + 1)...((index.0 + halfOfArea) - 1) : 0...columns-1
        let rangeRow: ClosedRange<Int> = session != nil ? ((index.1 - halfOfArea) + 1)...((index.1 + halfOfArea) - 1) : 0...rows-1

        for col in rangeCol {
            for row in rangeRow {
                // Normalizing the index with wrap-around
                let normalized = normalizeIndex(row: row % rows, col: col % columns)
                let universalCol: Int = normalized.col
                let universalRow: Int = normalized.row
                guard let land = self[universalRow,universalCol] as? LandType else { continue }
                
                //MARK: - Test and decide needed or not.
                var symbol = land.emoji()
                if index == (universalCol, universalRow) {
                    symbol = /*session?.generateSubClassIcon()*/"🤴"// ?? land.emoji()
                } else if let user = allUsers.first(where: {
                    normalizeIndex(row: $0.location.coordinates.x % rows, col: $0.location.coordinates.y % columns) == (universalRow, universalCol) && $0.id != session?.id
                }) {
                    symbol = "🤴"//user.generateSubClassIcon()
                }
                if let resource = resources.first(where: {
                    normalizeIndex(row: $0.position.r % rows, col: $0.position.c % columns) == (universalRow, universalCol) && !$0.isDead
                }) {
                    symbol = resource.icon
                }
                if let monster = mobs.first(where: {
                    normalizeIndex(row: $0.position.r % rows, col: $0.position.c % columns) == (universalRow, universalCol) && !$0.isDead
                }) {
                    symbol = monster.icon
                }
                if let elite = elites.first(where: {
                    normalizeIndex(row: $0.position.r % rows, col: $0.position.c % columns) == (universalRow, universalCol) && !$0.isDead
                }) {
                    symbol = elite.icon
                }
                if let dungeon = dungeons.first(where: {
                    normalizeIndex(row: $0.position.r % rows, col: $0.position.c % columns) == (universalRow, universalCol)
                }) {
                    symbol = dungeon.icon
                }
                message.append(symbol)
            }
            guard message.count > 0 else { continue }
            message.append("\n")
        }
        guard message.count > 0 else { return nil }
        return message
    }
    
    private func normalizeIndex(row: Int, col: Int, mapWidth: Int, mapHeight: Int) -> (row: Int, col: Int) {
        let normalizedRow = (row + mapHeight) % mapHeight
        let normalizedCol = (col + mapWidth) % mapWidth
        return (normalizedRow, normalizedCol)
    }
    
    func canMoveCharacter(session: Session, to direction: Direction) -> WorldPosition? {
        let index = (session.location.coordinates.x, session.location.coordinates.y)
        var newIndex: (Int, Int)? = nil
        switch direction {
        case .up:
            newIndex = (index.0, index.1 - 1)
        case .down:
            newIndex = (index.0, index.1 + 1)
        case .left:
            newIndex = (index.0 - 1, index.1)
        case .right:
            newIndex = (index.0 + 1, index.1)
        case .upLeft:
            newIndex = (index.0 - 1, index.1 - 1)
        case .upRight:
            newIndex = (index.0 + 1, index.1 - 1)
        case .downLeft:
            newIndex = (index.0 - 1, index.1 + 1)
        case .downRight:
            newIndex = (index.0 + 1, index.1 + 1)
        }
        //guard let nextIndex = newIndex else { return nil }
        //MARK: - Test and decide needed or not.
        guard let safeIndex = newIndex else { return nil }
        let nextIndex = normalizeIndex(row: safeIndex.0, col: safeIndex.1)
        //guard nextIndex.0 < self.rows   else { return nil }
        //guard nextIndex.1 < self.columns else { return nil }
        guard let icon = self[nextIndex.0, nextIndex.1] as? LandType else { return nil }
        guard icon == LandType.ground else { return nil }
        //guard icon == groundTile /*|| icon == "📦" || icon == "💞"*/ else { return false }
        //let position = WorldPosition(c: index.0, r: index.1)
        //let isChest  = chests.first(where: {$0.c == position.c && $0.r == position.r}) != nil
        //let isHeal   = heals.first(where: {$0.c == position.c && $0.r == position.r}) != nil
        //var prevIcon = groundTile
        //if isChest { prevIcon = "📦" }; if isHeal { prevIcon = "💞" }
        //tileMap[index.0,     index.1    ] = prevIcon
        //tileMap[nextIndex.0, nextIndex.1] = user.icon
        //user.position = WorldPosition(c: nextIndex.0, r: nextIndex.1)
        return WorldPosition(c: nextIndex.1, r: nextIndex.0)
    }
}
