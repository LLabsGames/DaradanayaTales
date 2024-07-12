//
//  FreeLandGenerator.swift
//  
//
//  Created by Maxim Lanskoy on 26.08.2022.
//

import Foundation

class FreeLevelGenerator {
    static let defaultMapSize = isTest ? 100 : 100
    
    static func gen(type: PlanetType, width: Int = defaultMapSize, height: Int = defaultMapSize) -> Matrix<LandType> {
        let types: [PlanetType] = [.asteroid, .blackHole, .gasGiant, .gasGiantWithRing, .star]
        if types.contains(type) {
            return Matrix<LandType>(rows: 0, columns: 0, defaultValue: .ground)
        } else {
            var groundTile: LandType
            var secondTile: LandType
            switch type {
            case .terrainWet:
                groundTile = .ground
                secondTile = .water
            case .islands:
                groundTile = .ground
                secondTile = .water
            case .terrainDry, .noAtmosphere:
                groundTile = .ground
                secondTile = .rocks
            case .iceWorld:
                groundTile = .ground
                secondTile = .snow
            case .lavaWorld:
                groundTile = .ground
                secondTile = .lava
            case .asteroid, .blackHole, .gasGiant, .gasGiantWithRing, .star:
                groundTile = .ground
                secondTile = .water
            }
            let aFreeLand = FreeLand(width: width, height: height)
            aFreeLand.applyRules() //aFreeLand.applyRules() //aFreeLand.applyRules()
            //print(aFreeLand.cellmap)
            var map = Matrix<LandType>(rows: width, columns: height, defaultValue: groundTile)
            aFreeLand.cellmap.enumerated().forEach({ (index, booleans) in
                booleans.enumerated().forEach({ (innerIndex, boolean) in
                    map[index, innerIndex] = boolean ? secondTile : groundTile
                })
            })
            return map
        }
    }
}

class FreeLand {
    var cellmap:[[Bool]]
    let chanceToStartAlive = 35
    let deathLimit = 3
    let birthLimit = 4
    var xCell = 100//144//72 // number of cell in x axes
    var yCell = 50//100//50 // number of cell in y axes

    init(width: Int = 100, height: Int = 50){
        xCell = width; yCell = height
        cellmap = Array(repeating: Array(repeating:false, count:width), count:height)
        cellmap = self.initialiseMap(xIndex: width, yIndex:height)
    }

    func initialiseMap(xIndex:Int, yIndex:Int) -> [[Bool]]{
        var map:[[Bool]] = Array(repeating: Array(repeating:false, count:xIndex), count:yIndex)
        for y in 0...(yIndex - 1) {
            for x in 0...(xIndex - 1) {
                let diceRoll = Int.random(in: 0...100)
                if diceRoll < chanceToStartAlive {
                    map[y][x] = true
                } else {
                    map[y][x] = false
                }
            }
        }
        return map
    }

    func countAliveNeighbours(x:Int, y:Int) -> Int{
        var count = 0
        var neighbour_x = 0
        var neighbour_y = 0

        for i in -1...1 {
            for j in -1...1 {

                neighbour_x = x + j
                neighbour_y = y + i

                if i == 0 && j == 0 {
                } else if neighbour_x < 0 || neighbour_y < 0 || neighbour_y >= cellmap.count || neighbour_x >= cellmap[0].count {
                    count = count + 1
                } else if cellmap[neighbour_y][neighbour_x] {
                    count = count + 1
                }
            }
        }
        return count
    }

    func applyRules(){
        var newMap:[[Bool]] = Array(repeating: Array(repeating:false, count:xCell), count:yCell)
        
        for y in 0...(cellmap.count - 1) {
            for x in 0...(cellmap[0].count - 1) {
                let nbs = countAliveNeighbours(x: x, y: y);
                if cellmap[y][x] {
                    if nbs < deathLimit {
                        newMap[y][x] = false;
                    } else{
                        newMap[y][x] = true;
                    }
                } else {
                    if nbs > birthLimit {
                        newMap[y][x] = true;
                    } else{
                        newMap[y][x] = false;
                    }
                }
            }
        }
        cellmap = newMap
    }
}

final class Planet: Codable {
    
    static let elitesCount: Int = 1
    
    let id: Int64
    let name: String
    let router: String
    let type: PlanetType
    var map: Matrix<LandType>
    var respawn: WorldPosition
    var mobLevels: ClosedRange<Int>
    var elites: [PlanetaryElite]
    var monsters: [PlanetaryMonster]
    var resources: [PlanetaryResource]
    var dungeonEntrances: [PlanetaryDungeonEntrance]
    var isWeatherCrysis: Bool
    
    var planetarEntities: [PlanetarEntity] {
        return elites + monsters + resources + dungeonEntrances
    }
    
    //let temperature: Int
    //let radiation: Int
    //let oxygen: Bool
    //let gravity: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, router, mobLevels, map, respawn, isWeatherCrysis, resources
    }
    
    init(name: String, type: PlanetType, levels: ClosedRange<Int>) {
        self.id = Int64(Date().timeIntervalSince1970)
        self.name = name
        self.type = type
        self.router = name
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)?
            .lowercased()
            .replacingOccurrences(of: " ", with: "-") ?? name
        self.mobLevels = levels
        let tileMap = FreeLevelGenerator.gen(type: type)
        self.map = tileMap
        let groundIndicies = Planet.getGroundTiles(tileMap).0
        let respawnPosition = groundIndicies.randomElement() ?? (0,0)
        self.respawn = WorldPosition(c: respawnPosition.0, r: respawnPosition.1)
        self.resources = Planet.generateResources(tileMap: tileMap, levels: levels, respawn: respawn)
        self.elites = Planet.generateEliteMobs(tileMap: tileMap, levels: levels, planet: name, respawn: respawn, resources: resources, encoding: false)
        self.dungeonEntrances = Planet.generateDungeonEntrances(tileMap: tileMap, levels: levels, respawn: respawn, resources: resources, elites: elites)
        self.monsters = Planet.generateMobs(tileMap: tileMap, levels: levels, respawn: respawn, resources: resources, elites: elites, dungeonEntrances: dungeonEntrances)
        self.isWeatherCrysis = false
    }
        
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id   = try values.decode(Int64.self, forKey: .id)
        type = try values.decode(PlanetType.self, forKey: .type)
        name = try values.decode(String.self, forKey: .name)
        router = try values.decode(String.self, forKey: .router)
        mobLevels = try values.decode(ClosedRange<Int>.self, forKey: .mobLevels)
        isWeatherCrysis = try values.decodeIfPresent(Bool.self, forKey: .isWeatherCrysis) ?? false
        if let map = try values.decodeIfPresent(Matrix<LandType>.self, forKey: .map),
           let respawn = try? values.decodeIfPresent(WorldPosition.self, forKey: .respawn) {
            self.map = map
            self.respawn = respawn
        } else {
            let tileMap = FreeLevelGenerator.gen(type: type)
            self.map = tileMap
            let groundIndicies = Planet.getGroundTiles(tileMap).ground
            let respawnPosition = groundIndicies.randomElement() ?? (0,0)
            let respawn = WorldPosition(c: respawnPosition.0, r: respawnPosition.1)
            self.respawn = respawn
        }
        if isTest == false, let resources = try? values.decodeIfPresent([PlanetaryResource].self, forKey: .resources) {
            self.resources = resources
            self.resources.forEach({
                $0.totalTickQuantity = Int.random(in: PlanetaryResource.ticksRange)
                $0.currentQuantity   = Int.random(in: PlanetaryResource.ticksRange)
            })
        } else {
            self.resources = Planet.generateResources(tileMap: map, levels: mobLevels, respawn: respawn)
        }
        self.elites = Planet.generateEliteMobs(tileMap: map, levels: mobLevels, planet: name, respawn: respawn, resources: resources, encoding: true)
        self.dungeonEntrances = Planet.generateDungeonEntrances(tileMap: map, levels: mobLevels, respawn: respawn, resources: resources, elites: elites)
        self.monsters = Planet.generateMobs(tileMap: map, levels: mobLevels, respawn: respawn, resources: resources, elites: elites, dungeonEntrances: dungeonEntrances)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id,  forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type,  forKey: .type)
        try container.encode(map,    forKey: .map)
        try container.encode(router,  forKey: .router)
        try container.encode(respawn,  forKey: .respawn)
        try container.encode(resources, forKey: .resources)
        try container.encode(mobLevels, forKey: .mobLevels)
    }
    
    func getPlanetDescription(isOrbit: Bool = false) -> String {
        var baseMessage = """
        🛰 \(isOrbit ? "Вы на орбите планеты " : "")<b>\(self.name)</b>\(isOrbit ? "." : "")
        
        ☣️ Тип: \(self.type.getTypeDescription().type).
        🌎 Вид: \(self.type.getTypeDescription().desc).
        """
        if mobLevels != 0...0 {
            baseMessage.append("\n🐺 Фауна: 🏅\(mobLevels.lowerBound)-\(mobLevels.upperBound)\n")
            if mobLevels != 1...30 {
                baseMessage.append("\n🌬 Расход: \(getOxygenUsage())")
                baseMessage.append("\n🌐 Расход: \(getDefenderUsage())-\(getDefenderUsage(forBadWeather: true))")
            }
        }
        return baseMessage
    }
    
    static func getGroundTiles(_ map: Matrix<LandType>) -> (ground: [(Int, Int)], walls: [(Int, Int)]) {
        let map = map
        var groundIndicies: [(Int, Int)] = []
        var wallIndicies: [(Int, Int)] = []
        for c in 0..<map.columns {
            for r in 0..<map.rows {
                let index = (c, r)
                let tile  = map[index.1, index.0]
                if tile == .ground {
                    groundIndicies.append(index)
                } else {
                    wallIndicies.append(index)
                }
            }
        }
        return (groundIndicies, wallIndicies)
    }
    
    static func generateResources(tileMap: Matrix<LandType>, levels: ClosedRange<Int>, respawn: WorldPosition) -> [PlanetaryResource] {
        var resources: [PlanetaryResource] = []
        for c in 0..<tileMap.columns {
            for r in 0..<tileMap.rows {
                let worldPosition = WorldPosition(c: c, r: r)
                guard tileMap[r,c] == .ground else { continue }
                guard respawn != WorldPosition(c: c, r: r) else { continue }
                let noResAround = resources.contains(where: { res in
                    res.position.distanceTo(neededPosition: worldPosition).0 < 3
                }) == false
                guard noResAround && Int.random(in: 1...100) <= 7 else { continue }
                //let fishResources = resources.filter({$0.entity == .fishman})
                //let woodResources = resources.filter({$0.entity == .lumberjack})
                //let plntResources = resources.filter({$0.entity == .herbalist})
                //let rockResources = resources.filter({$0.entity == .digger})
                let tuples: [[PlanetaryResource]] = [
                //    (fishResources,   .fishman), (woodResources, .lumberjack),
                //    (plntResources, .herbalist), (rockResources,     .digger),
                ].sorted(by: {$0.count < $1.count})
                guard let lowest: [PlanetaryResource] = tuples.first else { continue }
                let icon = /*lowest.type.getSpaceIcon()*/"📦"
                let ticks = Int.random(in: PlanetaryResource.ticksRange)
                let resource = PlanetaryResource(position: worldPosition, icon: icon, ticks: ticks)
                resources.append(resource)
            }
        }
        return resources
    }
    
    static func generateEliteMobs(tileMap: Matrix<LandType>, levels: ClosedRange<Int>, planet: String, respawn: WorldPosition, resources: [PlanetaryResource], encoding: Bool) -> [PlanetaryElite] {
        let resourcePositions = resources.compactMap({$0.position})
        var monsters: [PlanetaryElite] = []
        var possiblePositions: [WorldPosition] = []
        let icon = "🌟"
        for c in 0..<tileMap.columns {
            for r in 0..<tileMap.rows {
                let worldPosition = WorldPosition(c: c, r: r)
                guard tileMap[r,c] == .ground else { continue }
                guard respawn != WorldPosition(c: c, r: r) else { continue }
                let takenTiles = monsters.compactMap({$0.position}) + resourcePositions
                let noAnythingAround = takenTiles.contains(where: { tile in
                    tile.distanceTo(neededPosition: worldPosition).0 < 3
                }) == false
                guard noAnythingAround else { continue }
                possiblePositions.append(worldPosition)
            }
        }
        for position in possiblePositions.shuffled() {
            guard monsters.count < Planet.elitesCount else { break }
            monsters.append(PlanetaryElite(position: position, icon: icon))
        }
        return monsters
    }
    
    static func generateDungeonEntrances(tileMap: Matrix<LandType>, levels: ClosedRange<Int>, respawn: WorldPosition, resources: [PlanetaryResource], elites: [PlanetaryElite]) -> [PlanetaryDungeonEntrance] {
        let resourcePositions = resources.compactMap({$0.position})
        let elitePositions = elites.compactMap({$0.position})
        var dungeons: [PlanetaryDungeonEntrance] = []
        var possiblePositions: [WorldPosition] = []
        let icon = "🏯"
        for c in 0..<tileMap.columns {
            for r in 0..<tileMap.rows {
                let worldPosition = WorldPosition(c: c, r: r)
                guard tileMap[r,c] == .ground else { continue }
                guard respawn != WorldPosition(c: c, r: r) else { continue }
                let takenTiles = possiblePositions + resourcePositions + elitePositions
                let noAnythingAround = takenTiles.contains(where: { tile in
                    tile.distanceTo(neededPosition: worldPosition).0 < 3
                }) == false
                let noAnotherDungeonNear = possiblePositions.contains(where: { tile in
                    tile.distanceTo(neededPosition: worldPosition).0 < 15
                }) == false
                guard noAnythingAround && noAnotherDungeonNear else { continue }
                possiblePositions.append(worldPosition)
            }
        }
        for position in possiblePositions.shuffled() {
            guard dungeons.count < Planet.elitesCount * 4 else { break }
            let difference:      Int = 5
            let clearMiltiplier: Int = levels.lowerBound / 5
            let trueLowerBound:  Int = clearMiltiplier * difference + 1
            let trueUpperBound:  Int = trueLowerBound + (difference - 1)
            let trueLevels: ClosedRange<Int> = trueLowerBound...trueUpperBound
            let entrance = PlanetaryDungeonEntrance(levels: trueLevels, position: position, icon: icon)
            dungeons.append(entrance)
        }
        return dungeons
    }
    
    static func generateMobs(tileMap: Matrix<LandType>, levels: ClosedRange<Int>, respawn: WorldPosition, resources: [PlanetaryResource], elites: [PlanetaryElite], dungeonEntrances: [PlanetaryDungeonEntrance]) -> [PlanetaryMonster] {
        let resourcePositions = resources.compactMap({$0.position})
        let elitePositions = elites.compactMap({$0.position})
        let dungeonPositions = dungeonEntrances.compactMap({$0.position})
        var monsters: [PlanetaryMonster] = []
        let icons = ["🐺", "🐙", "🐍", "🦑", "🦍"]
        let levelsArray = levels.compactMap({$0})
        for c in 0..<tileMap.columns {
            for r in 0..<tileMap.rows {
                let worldPosition = WorldPosition(c: c, r: r)
                guard tileMap[r,c] == .ground else { continue }
                guard respawn != WorldPosition(c: c, r: r) else { continue }
                let takenTiles = monsters.compactMap({$0.position}) + resourcePositions + elitePositions + dungeonPositions
                let noAnythingAround = takenTiles.contains(where: { tile in
                    tile.distanceTo(neededPosition: worldPosition).0 < 3
                }) == false
                guard noAnythingAround else { continue }
                let chance = Int.random(in: 1...100)
                if chance <= 60 {
                    guard var icon = icons.randomElement() else { continue }
                    for (index, level) in levelsArray.enumerated() {
                        guard icons.count > index else { continue }
                        icon = icons[index]
                    }
                    monsters.append(PlanetaryMonster(position: worldPosition, icon: icon))
                }
            }
        }
        return monsters
    }
    
    func findFreePlaceNearPosition(position: WorldPosition? = nil) -> WorldPosition {
        // Used for general purpose free place searching.
        let groundIndicies = Planet.getGroundTiles(self.map)
        let potentialFreeIndicies = groundIndicies.ground.filter({ position in
            let isNotTakenByElite = elites.contains(where: {$0.position == position}) == false
            let isNotTakenByDnD = dungeonEntrances.contains(where: {$0.position == position}) == false
            let tmpPosition = WorldPosition(c: position.1, r: position.0)
            let isNotNearToWall = groundIndicies.walls.contains(where: { tile in
                let tilePos = WorldPosition(c: tile.1, r: tile.0)
                return tilePos.distanceTo(neededPosition: tmpPosition).0 < 3
            }) == false
            return isNotTakenByElite && isNotTakenByDnD && isNotNearToWall
        }).shuffled()
        let neededPositions = potentialFreeIndicies.filter({ index in
            let tmpPosition = WorldPosition(c: index.1, r: index.0)
            var isNearNeededPlace = true
            var isNotTooFar = true
            if let neededPos = position {
                isNearNeededPlace = tmpPosition.distanceTo(neededPosition: neededPos).0 >= 1
                isNotTooFar = tmpPosition.distanceTo(neededPosition: neededPos).0 <= 10
            }
            let isNotTakenByElite = elites.contains(where: {$0.position == position}) == false
            let isNotTakenByDnD = dungeonEntrances.contains(where: {$0.position == position}) == false
            let isNotNearToWall = groundIndicies.walls.contains(where: { tile in
                let tilePos = WorldPosition(c: tile.1, r: tile.0)
                return tilePos.distanceTo(neededPosition: tmpPosition).0 < 3
            }) == false
            return isNearNeededPlace && isNotTooFar && isNotTakenByElite && isNotTakenByDnD && isNotNearToWall
        }).shuffled()
        return self.assignNewPosition(possibleVariants: neededPositions, fallbackGroundTiles: potentialFreeIndicies)
    }
    
    func findCloseFreePlaceNear(position: WorldPosition? = nil) -> WorldPosition {
        // Used only for ship calling by portable receiver.
        let position = position ?? self.respawn
        let groundIndicies = Planet.getGroundTiles(self.map).ground.sorted(by: { indexOne, indexTwo in
            let distanceOne = position.distanceTo(neededPosition: indexOne).0
            let distanceTwo = position.distanceTo(neededPosition: indexTwo).0
            return distanceOne < distanceTwo
        })
        let potentialFreeIndicies = groundIndicies.filter({ position in
            let isNotTakenByElite = elites.contains(where: {$0.position == position}) == false
            let isNotTakenByDnD = dungeonEntrances.contains(where: {$0.position == position}) == false
            return isNotTakenByElite && isNotTakenByDnD
        })
        let neededPositions = potentialFreeIndicies.filter({ index in
            let tmpPosition = WorldPosition(c: index.1, r: index.0)
            let isNotTooFar = tmpPosition.distanceTo(neededPosition: position).0 <= 3
            return isNotTooFar
        })
        return self.assignNewPosition(possibleVariants: neededPositions, fallbackGroundTiles: potentialFreeIndicies)
    }
    
    func findSomeRandomPlace() -> WorldPosition {
        // Used only for generating new position for elites after fight is finished.
        var possiblePositions: [(Int,Int)] = []
        var groundIndicies: [(Int,Int)] = []
        for c in 0..<self.map.columns {
            for r in 0..<self.map.rows {
                let worldPosition = WorldPosition(c: c, r: r)
                guard self.map[r,c] == .ground else { continue }
                guard respawn != WorldPosition(c: c, r: r) else { continue }
                groundIndicies.append((c,r))
                let takenTiles = planetarEntities.compactMap({$0.position})
                let noAnythingAround = takenTiles.contains(where: { tile in
                    tile.distanceTo(neededPosition: worldPosition).0 < 3
                }) == false
                guard noAnythingAround else { continue }
                possiblePositions.append((c,r))
            }
        }
        return self.assignNewPosition(possibleVariants: possiblePositions, fallbackGroundTiles: groundIndicies)
    }
    
    private func assignNewPosition(possibleVariants: [(Int, Int)], fallbackGroundTiles: [(Int, Int)]) -> WorldPosition {
        if let newPosition = possibleVariants.randomElement() {
            monsters.removeAll(where: {$0.position.distanceTo(neededPosition: newPosition).0 <= 1})
            resources.removeAll(where: {$0.position.distanceTo(neededPosition: newPosition).0 <= 1})
            return WorldPosition(c: newPosition.1, r: newPosition.0)
        } else if let index = fallbackGroundTiles.randomElement() {
            monsters.removeAll(where: {$0.position.distanceTo(neededPosition: index).0 <= 1})
            resources.removeAll(where: {$0.position.distanceTo(neededPosition: index).0 <= 1})
            return WorldPosition(c: index.1, r: index.0)
        } else {
            return WorldPosition(c: Int(map.columns/2), r: Int(map.rows/2))
        }
    }
    
    func getOxygenUsage() -> Int {
        switch type {
        case .terrainWet, .islands, .terrainDry, .iceWorld, .lavaWorld:
            return 1
        case .star, .asteroid, .blackHole, .gasGiantWithRing, .gasGiant, .noAtmosphere:
            return 2
        }
    }
    
    func getDefenderUsage(forBadWeather: Bool = false) -> Int {
        if PlanetType.getGoodPlanets().contains(type) {
            return isWeatherCrysis || forBadWeather ? 1 : 0
        } else {
            return isWeatherCrysis || forBadWeather ? 2 : 1
        }
    }
}

public enum PlanetType: String, CaseIterable, Codable {
    case terrainWet  = "Wet Terrains"
    case islands      = "Islalds Worlds"
    case terrainDry    = "Dry Terrains"
    case noAtmosphere   = "No Atmospheres"
    case gasGiant        = "Gas Giants"
    case gasGiantWithRing = "Ringed Gas Giants"
    case iceWorld        = "Ice Worlds"
    case lavaWorld      = "Lava Worlds"
    case asteroid      = "Asteroids"
    case blackHole    = "Black Holes"
    case star        = "Stars"
    
    func getTypeDescription() -> (type: String, desc: String) {
        switch self {
        case .terrainWet:
            return ("Благоприятный", "Материковая, Влажная")
        case .islands:
            return ("Благоприятный", "Островная")
        case .terrainDry:
            return ("Благоприятный", "Материковая, Сухая")
        case .noAtmosphere:
            return ("Неблагоприятный", "Безатмосферная")
        case .gasGiant:
            return ("Неблагоприятный", "Газовый Гигант")
        case .gasGiantWithRing:
            return ("Неблагоприятный", "Газовый Гигант")
        case .iceWorld:
            return ("Неблагоприятный", "Замерзший мир")
        case .lavaWorld:
            return ("Неблагоприятный", "Выжженый мир")
        case .asteroid:
            return ("Неблагоприятный", "Астероид")
        case .blackHole:
            return ("Неблагоприятный", "Черная Дыра")
        case .star:
            return ("Неблагоприятный", "Звезда")
        }
    }
    
    func getNonGroundTileType() -> LandType {
        switch self {
        case .terrainWet:
            return .water
        case .islands:
            return .water
        case .terrainDry, .noAtmosphere:
            return .rocks
        case .iceWorld:
            return .snow
        case .lavaWorld:
            return .lava
        case .asteroid, .blackHole, .gasGiant, .gasGiantWithRing, .star:
            return .water
        }
    }
    
    static func getGoodPlanets() -> [PlanetType] {
        return [.terrainWet, .islands, .terrainDry]
    }
}

class PlanetGenerator {
    typealias PlanetHolder = (tileNumber: Int, planet: Planet)
    typealias TypeHolder   =  (ids: [Int],  type: PlanetType)
    
    static var defaultPlanets: [PlanetHolder] = [
        PlanetHolder(tileNumber:   0, planet: Planet(name: "Орион", type: .terrainWet,           levels: 01...30)),
        
        PlanetHolder(tileNumber:  47, planet: Planet(name: "Кассиопея", type: .terrainWet,       levels: 36...38)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "Эрида", type: .terrainWet)),
        
        PlanetHolder(tileNumber:  14, planet: Planet(name: "Атлон", type: .islands,              levels: 31...33)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "", type: .islands)),
        
        PlanetHolder(tileNumber:  55, planet: Planet(name: "Пиреис", type: .terrainDry,          levels: 38...40)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "", type: .terrainDry)),
        
        PlanetHolder(tileNumber:  23, planet: Planet(name: "Таурус", type: .noAtmosphere,        levels: 33...36)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "", type: .noAtmosphere)),
        
        PlanetHolder(tileNumber: 137, planet: Planet(name: "Терра", type: .gasGiant,             levels: 44...46)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "", type: .gasGiant)),
        
        PlanetHolder(tileNumber: 159, planet: Planet(name: "Липперхей", type: .gasGiantWithRing, levels: 46...48)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "", type: .gasGiantWithRing)),
        
        PlanetHolder(tileNumber:  86, planet: Planet(name: "Хорвус", type: .iceWorld,           levels: 40...42)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "", type: .iceWorld)),
        
        PlanetHolder(tileNumber:  62, planet: Planet(name: "Хот", type: .lavaWorld,           levels: 42...44)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "", type: .lavaWorld)),
        
        PlanetHolder(tileNumber: 142, planet: Planet(name: "Черная Дыра", type: .blackHole,  levels: 51...55)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "", type: .blackHole)),
        
        PlanetHolder(tileNumber: 155, planet: Planet(name: "Проксима", type: .star,        levels: 48...50)),
        //PlanetHolder(tileNumber: 0, planet: Planet(name: "Генезиз", type: .star)),
        
        PlanetHolder(tileNumber:   6, planet: Planet(name: "Кеплер-17",  type: .asteroid, levels: 0...0)),
        PlanetHolder(tileNumber:   3, planet: Planet(name: "Кеплер-4",   type: .asteroid, levels: 0...0)),
        PlanetHolder(tileNumber:  10, planet: Planet(name: "Кеплер-171", type: .asteroid, levels: 0...0)),
        PlanetHolder(tileNumber:  16, planet: Planet(name: "Кеплер-218", type: .asteroid, levels: 0...0)),
        PlanetHolder(tileNumber:  19, planet: Planet(name: "Кеплер-13",  type: .asteroid, levels: 0...0)),
        PlanetHolder(tileNumber:  28, planet: Planet(name: "Кеплер-8",   type: .asteroid, levels: 0...0)),
        PlanetHolder(tileNumber:  43, planet: Planet(name: "Кеплер-451", type: .asteroid, levels: 0...0)),
        PlanetHolder(tileNumber:  55, planet: Planet(name: "Кеплер-711", type: .asteroid, levels: 0...0))
    ]
}


enum LandType: String, Codable {
    case ground
    case rocks
    case water
    case snow
    case lava
    
    func emoji() -> String {
        switch self {
        case .ground: return "⬛️"
        case .rocks:  return "🏔"
        case .water:  return "🟦"
        case .snow:  return "❄️"
        case .lava: return "🟧"
        }
    }
}

class PlanetarEntity: Codable {
    
    static let respawnTime: TimeInterval = 15 * 60
    
    var position: WorldPosition
    var isDead: Bool {
        didSet { date = Date() }
    }
    var icon: String
    var date: Date?
    
    enum CodingKeys: String, CodingKey {
        case icon, isDead, position, entity, date
        case currentQuantity, totalTickQuantity
        case eliteMonsterId, levels
    }
    
    init(position: WorldPosition, icon: String) {
        self.position = position
        self.isDead = false
        self.icon = icon
        self.date = nil
    }
    required init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        self.position = try container.decode(WorldPosition.self, forKey: .position)
        self.isDead = try container.decode(Bool.self, forKey: .isDead)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position, forKey: .position)
        try container.encode(isDead,  forKey: .isDead)
        try container.encode(icon,  forKey: .icon)
        try container.encode(date,  forKey: .date)
    }
}

final class PlanetaryMonster: PlanetarEntity {
    
    override init(position: WorldPosition, icon: String) {
        super.init(position: position, icon: icon)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
    }
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
    }
}

final class PlanetaryElite: PlanetarEntity {
    
    override init(position: WorldPosition, icon: String) {
        super.init(position: position, icon: icon)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
    }
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
    }
}

final class PlanetaryResource: PlanetarEntity {
    
    static let ticksRange: ClosedRange<Int> = 13...27
    
    var totalTickQuantity: Int
    var currentQuantity: Int
    
    init(position: WorldPosition, icon: String, ticks: Int) {
        self.currentQuantity = ticks
        self.totalTickQuantity = ticks
        super.init(position: position, icon: icon)
    }
    required init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        totalTickQuantity = try container.decode(Int.self, forKey: .totalTickQuantity)
        currentQuantity = try container.decode(Int.self, forKey: .currentQuantity)
        try super.init(from: decoder)
    }
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalTickQuantity, forKey: .totalTickQuantity)
        try container.encode(currentQuantity, forKey: .currentQuantity)
        try super.encode(to: encoder)
    }
}

final class PlanetaryDungeonEntrance: PlanetarEntity {
    let levels: ClosedRange<Int>
    
    init(levels: ClosedRange<Int>, position: WorldPosition, icon: String) {
        self.levels = levels
        super.init(position: position, icon: icon)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        levels = try container.decode(ClosedRange<Int>.self, forKey: .levels)
        try super.init(from: decoder)
    }
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(levels, forKey: .levels)
        try super.encode(to: encoder)
    }
}
