//
//  ProceduralMap.swift
//  Orion-Nebula
//
//  Created by Maxim Lanskoy on 04.04.2021.
//

import Foundation

final class ProceduralMap {
    
    var tileMap: Matrix<String>!
        
    var rooms    = [Room]()
    var hallways = [Room]()
    var leaves   = [Leaf]()
    
    var chests:   [WorldPosition]  = []
    var heals:    [WorldPosition]  = []
    var monsters: [ProceduralMonster] = []
    
    var wallsTile = "🌳"
    var groundTile = "🟫"
    var level: Int
    var respawn: WorldPosition
    
    init(columns: Int, rows: Int, tile1: String, tile2: String, level: Int) {
        self.level = level
        while tileMap == nil {
            rooms = []; hallways = []; leaves = [];
            // First, create leaf to be root of all leaves
            let root = Leaf(X: 0, Y: 0, W: columns, H: rows);
            leaves.append(root)
            var didSplit: Bool = true;
            let maxLeafSize = 20
            
            // Loop through every Leaf in array until no more can be split
            while (didSplit) {
                didSplit = false;
                for leaf in leaves {
                    if leaf.leftChild == nil && leaf.rightChild == nil { // If not split
                        // If this leaf is too big, or 75% chance
                        if leaf.width > maxLeafSize || leaf.height > maxLeafSize || Int.random(in: 0..<100) > 25 {
                            if (leaf.split()) { // split the leaf
                                // If split worked, push child leaves into array
                                leaves.append(leaf.leftChild!)
                                leaves.append(leaf.rightChild!)
                                didSplit = true
                            }
                        }
                    }
                }
            }
            // Next, iterate through each leaf and create room in each one
            root.createRooms()
            
            for leaf in leaves { // Then draw room and hallway (if there is one)
                if leaf.room != nil { rooms.append(leaf.room!) }
                if leaf.hallways.isEmpty != true {
                    for rect in leaf.hallways {
                        hallways.append(rect)
                    }
                }
            }
            
            // Initialize a tile map and give it content to build with
            let tile1 = tile1
            let tile2 = tile2
            wallsTile = tile1
            groundTile = tile2
            var tileMap = Matrix(rows: rows, columns: columns, defaultValue: tile1)
            
            for c in 0..<tileMap.columns {
                for r in 0..<tileMap.rows {
                    for i in rooms { // iterate through each room and carve it out
                        if i.x1 <= c && i.x2 >= c && i.y1 <= r && i.y2 >= r {
                            tileMap[c,r] = tile2
                        } else if tileMap[c,r] != tile2/* && tileMap.tileGroup(atColumn: c, row: r) != tileGroup3*/ {
                            tileMap[c,r] = tile1
                        }
                    }
                    for h in hallways { // iterate through each hallway and carve it out
                        if h.x1 <= c && h.x2 >= c && h.y1 <= r && h.y2 >= r {
                            tileMap[c,r] = tile2
                        } else if tileMap[c,r] != tile2/* && tileMap.tileGroup(atColumn: c, row: r) != tileGroup3*/ {
                            tileMap[c,r] = tile1
                        }
                    }
                }
            }
            self.tileMap = tileMap
        }
        var groundIndicies: [(Int, Int)] = []
        for c in 0..<tileMap.columns {
            for r in 0..<tileMap.rows {
                let index = (r, c)
                let tile  = tileMap[index.0, index.1]
                guard tile == groundTile else { continue }
                groundIndicies.append(index)
            }
        }
        let respawnPosition = groundIndicies.randomElement()!
        self.respawn = WorldPosition(c: respawnPosition.1, r: respawnPosition.0)
        self.generateEnvitonment()
        self.printMap(tileMap: tileMap)
    }
    
    func findFreePlaceNearPosition(position: WorldPosition) -> WorldPosition? {
        var groundIndicies: [(Int, Int)] = []
        for c in 0..<tileMap.columns {
            for r in 0..<tileMap.rows {
                let index = (c, r)
                let tile  = tileMap[index.0, index.1]
                guard tile == groundTile else { continue }
                groundIndicies.append(index)
            }
        }
        let neededPositions = groundIndicies.filter({
            WorldPosition(c: $0.0, r: $0.1).distanceTo(neededPosition: position).0 == 2 ||
            WorldPosition(c: $0.0, r: $0.1).distanceTo(neededPosition: position).0 == 2
        })
        guard let position = neededPositions.randomElement() else { return nil }
        return WorldPosition(c: position.0, r: position.1)
    }
    
    func generateEnvitonment() {
        var roomsSpace: [[WorldPosition]] = []
        for i in rooms {
            var roomSpace: [WorldPosition] = []
            for c in 0..<tileMap.columns {
                for r in 0..<tileMap.rows {
                    guard respawn != WorldPosition(c: c, r: r) else { continue }
                    if i.x1+1 <= c && i.x2-1 >= c && i.y1+1 <= r && i.y2-1 >= r {
                        roomSpace.append(WorldPosition(c: c, r: r))
                    }
                }
            }
            roomsSpace.append(roomSpace)
        }
        guard roomsSpace.count > 0 else { return }
        for room in roomsSpace {
            var monstersInRoom: [WorldPosition] = []
            guard let monster1Pos = room.shuffled().randomElement() else { continue }
            monstersInRoom.append(monster1Pos)
            if let monster2Pos = room.shuffled().filter({
                $0.distanceTo(neededPosition: monster1Pos).0 > 2
            }).randomElement() {
                monstersInRoom.append(monster2Pos)
                let notCloseToMobs = room.shuffled().filter({
                    $0.distanceTo(neededPosition: monster1Pos).0 > 2 &&
                    $0.distanceTo(neededPosition: monster2Pos).0 > 2
                }).randomElement()
                if let chestOrHealPos = notCloseToMobs {
                    if Bool.random() {
                        chests.append(chestOrHealPos)
                    } else {
                        heals.append(chestOrHealPos)
                    }
                }
            }
            var dungeonMonsters: [ProceduralMonster] = []
            for monster in monstersInRoom {
                let icon = ["🐺", "🐙", "🦑", "🐍", "🦍"].randomElement()!
                let proceduralMonster = ProceduralMonster(icon: icon, level: level, position: monster)
                dungeonMonsters.append(proceduralMonster)
            }
            monsters.append(contentsOf: dungeonMonsters)
            for monster in monsters {
                tileMap[monster.position.c, monster.position.r] = monster.icon
            }
            chests.forEach({tileMap[$0.c, $0.r] = "📦"})
            heals.forEach({tileMap[$0.c, $0.r] = "💞"})
        }
    }
    
    func createOutputForPlayer(allUsers: [Session], session: Session) -> String? {
        var message = ""
        let index = (session.location.coordinates.x, session.location.coordinates.y)
        for col in 0..<tileMap.columns {
            for row in 0..<tileMap.rows {
                let halfOfArea: Int = Int(round(Float(session.settings.emojiMapsize) / 2.0))
                guard col < index.0 + halfOfArea && col > index.0 - halfOfArea &&
                    row < index.1 + halfOfArea && row > index.1 - halfOfArea else { continue }
                var symbol = tileMap[col,row]
                if let user = allUsers.first(where: {$0.location.coordinates.x == col && $0.location.coordinates.y == row}) {
                    symbol = "🤴"//user.generateSubClassIcon()
                }
                message.append(symbol)
            }
            guard message.count > 0 else { continue }
            message.append("\n")
        }
        guard message.count > 0 else { return nil }
        return message
    }
    
    func moveCharacter(user: inout ProceduralUser, to direction: Direction) -> Bool? {
        let index = (user.position.c, user.position.r)
        var newIndex: (Int, Int)? = nil
        switch direction {
        case .up:
            newIndex = (index.0 - 1, index.1)
        case .down:
            newIndex = (index.0 + 1, index.1)
        case .left:
            newIndex = (index.0, index.1 - 1)
        case .right:
            newIndex = (index.0, index.1 + 1)
        case .upLeft:
            newIndex = (index.0 - 1, index.1 - 1)
        case .upRight:
            newIndex = (index.0 - 1, index.1 + 1)
        case .downLeft:
            newIndex = (index.0 + 1, index.1 - 1)
        case .downRight:
            newIndex = (index.0 + 1, index.1 + 1)
        }
        guard let nextIndex = newIndex, nextIndex.0 < tileMap.rows && nextIndex.1 < tileMap.columns else { return false }
        let icon = tileMap[nextIndex.0, nextIndex.1]
        guard icon == groundTile /*|| icon == "📦" || icon == "💞"*/ else { return false }
        let position = WorldPosition(c: index.0, r: index.1)
        let isChest  = chests.first(where: {$0.c == position.c && $0.r == position.r}) != nil
        let isHeal   = heals.first(where: {$0.c == position.c && $0.r == position.r}) != nil
        var prevIcon = groundTile
        if isChest { prevIcon = "📦" }; if isHeal { prevIcon = "💞" }
        tileMap[index.0,     index.1    ] = prevIcon
        tileMap[nextIndex.0, nextIndex.1] = user.icon
        user.position = WorldPosition(c: nextIndex.0, r: nextIndex.1)
        return true
    }
    
    func moveMonster(monster: inout ProceduralMonster, to direction: Direction) -> Bool? {
        let index = (monster.position.c, monster.position.r)
        var newIndex: (Int, Int)? = nil
        switch direction {
        case .up:
            newIndex = (index.0 - 1, index.1)
        case .down:
            newIndex = (index.0 + 1, index.1)
        case .left:
            newIndex = (index.0, index.1 - 1)
        case .right:
            newIndex = (index.0, index.1 + 1)
        case .upLeft:
            newIndex = (index.0 - 1, index.1 - 1)
        case .upRight:
            newIndex = (index.0 - 1, index.1 + 1)
        case .downLeft:
            newIndex = (index.0 + 1, index.1 - 1)
        case .downRight:
            newIndex = (index.0 + 1, index.1 + 1)
        }
        guard let nextIndex = newIndex, nextIndex.0 < tileMap.rows && nextIndex.1 < tileMap.columns else { return false }
        let icon = tileMap[nextIndex.0, nextIndex.1]
        guard icon == groundTile /*|| icon == "📦" || icon == "💞"*/ else { return false }
        let position = WorldPosition(c: index.0, r: index.1)
        let isChest  = chests.first(where: {$0.c == position.c && $0.r == position.r}) != nil
        let isHeal   = heals.first(where: {$0.c == position.c && $0.r == position.r}) != nil
        var prevIcon = groundTile
        if isChest { prevIcon = "📦" }; if isHeal { prevIcon = "💞" }
        tileMap[index.0,     index.1    ] = prevIcon
        tileMap[nextIndex.0, nextIndex.1] = monster.icon
        monster.position = WorldPosition(c: nextIndex.0, r: nextIndex.1)
        return true
    }
    
    private func printMap(tileMap: Matrix<String>) {
        var message = ""
        for col in 0..<tileMap.columns {
            for row in 0..<tileMap.rows {
                message.append(tileMap[col,row])
            }
            guard message.count > 0 else { continue }
            message.append("\n")
        }
        guard message.count > 0 else { return }
        message.append("\n📟 - 🏯 Dungeon map terraformed. ✅")
        print(message)
    }
}

