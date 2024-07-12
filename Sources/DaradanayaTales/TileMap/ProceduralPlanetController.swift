////
////  ProceduralPlanetController.swift
////  Orion-Nebula
////
////  Created by Maxim Lanskoy on 17.05.2021.
////
//
//import SwiftTelegramSdk
//import Foundation
//
//final class ProceduralPlanetController {
//    typealias T = ProceduralPlanetController
//    
//    let localButtons: [KeyboardButton] = [
//        KeyboardButton(text: "🔥 Старт"),
//        KeyboardButton(text: "🚀 Мой корабль"),
//        KeyboardButton(text: "🗺 Исследовать"),
//    ]
//    let planetRouters = PlanetGenerator.defaultPlanets.compactMap({$0.planet.router})
//    
//    init() {
//        super.init(routerNames: planetRouters)
//        for planet in planetRouters {
//            routers[planet] = Router(bot: mainBot) { router in
//                router[Commands.cancel.button.text] = onCancel
//                router[localButtons[0].text] = onStart
//                router[localButtons[1].text] = onSpaceship
//                router[localButtons[2].text] = onExplore
//                
//                router[Commands.attackWarrior.button.text] = onEliteAttack
//                router[Commands.attackRanger.button.text]  = onEliteAttack
//                router[Commands.attackMage.button.text]    = onEliteAttack
//                router[Commands.eliteMobHelp.button.text]  = onEliteHelp
//                router[Commands.eliteMobCry.button.text]   = onEliteHelp
//                router[Commands.liveMobStatus.button.text] = onLiveMobStatus
//                
//                router.unmatched = unmatched
//                router[.callback_query(data: nil)] = onCallbackQuery
//            }
//        }
//    }
//    
//    func onCancel(context: Context) -> Bool {
//        return true
//    }
//    
//    func onEliteAttack(context: Context) -> Bool {
//        guard let msgId = context.update.message?.messageId else { return true }
//        guard let fight = Controllers.allLandsController.eliteMonsterGroups.first(where: {($0.users + $0.deadUsers).contains(context.session.userId)}) ?? Controllers.allLandsController.simpleMonsterGroups.first(where: {($0.users + $0.deadUsers).contains(context.session.userId)}) else { return true }
//        StepPvEInputController.processSomeOneSimpleAttack(session: context.session, fight: fight, messageId: msgId)
//        return true
//    }
//    
//    func onEliteHelp(context: Context) -> Bool {
//        let player = context.session.generatePlayerStats()
//        guard let fight = Controllers.allLandsController.eliteMonsterGroups.first(where: {($0.users + $0.deadUsers).contains(context.session.userId)}) ?? Controllers.allLandsController.simpleMonsterGroups.first(where: {($0.users + $0.deadUsers).contains(context.session.userId)}) else {
//            mainBot.sendCustomMessage(session: context.session, text: "⏱ Битва еще не началась!")
//            return true
//        }
//        guard player.getCurrentHealth() > 0 else {
//            mainBot.sendCustomMessage(session: context.session, text: "💀 Вы мертвы!")
//            return false
//        }
//        let lastUsage = context.session.flags.lastHelpUsageDate
//        let interval = Date().timeIntervalSince(lastUsage)
//        guard interval > 9 else {
//            mainBot.sendCustomMessage(session: context.session, text: """
//                ⚠️ Просить помощь можно только раз в 10 секунд!
//                
//                ⏱ Осталось ожидать: \(Int(10 - interval)) cекунд(-y).
//                """)
//            return true
//        }
//        guard let msgId = context.update.message?.messageId ?? context.update.callbackQuery?.message?.messageId else { return true }
//        context.session.flags.lastHelpUsageDate = Date()
//        context.session.save(.lastHelpUsageDate)
//        Session.sessions(withIDs: fight.users) { sessions in
//            guard let sessions = sessions, sessions.count > 0 else { return }
//            for session in sessions {
//                if session.player.playerClass.rebornClass == .priest {
//                    let skill = AbilityTrees.priest.abilities.first!
//                    let check = Controllers.allLandsController.processEliteFightButtonsCheck(session: session, skill: skill, silent: true, messageId: msgId)
//                    if check.0 {
//                        mainBot.sendCustomMessage(session: session, text: """
//                        💬 Игроку \(player.shortName)\n(\(player.getHealthString(of: context.session))) нужна помощь! /\(skill.id)_\(context.session.userId)
//                        """)
//                    } else {
//                        mainBot.sendCustomMessage(session: session, text: """
//                        💬 Игроку \(player.shortName)\n(\(player.getHealthString(of: context.session))) нужна помощь!
//                        """)
//                    }
//                } else {
//                    mainBot.sendCustomMessage(session: session, text: """
//                    💬 Игроку \(player.shortName)\n(\(player.getHealthString(of: context.session))) нужна помощь!
//                    """)
//                }
//            }
//        }
//        return true
//    }
//    
//    func onLiveMobStatus(context: Context) -> Bool {
//        let player = context.session.generatePlayerStats()
//        guard let fight = Controllers.allLandsController.eliteMonsterGroups.first(where: {($0.users + $0.deadUsers).contains(context.session.userId)}) ?? Controllers.allLandsController.simpleMonsterGroups.first(where: {($0.users + $0.deadUsers).contains(context.session.userId)}) else {
//            mainBot.sendCustomMessage(session: context.session, text: "⏱ Битва еще не началась!")
//            return true
//        }
//        guard player.getCurrentHealth() > 0 else {
//            mainBot.sendCustomMessage(session: context.session, text: "💀 Вы мертвы!")
//            return false
//        }
//        let callBackQueryId = context.update.callbackQuery?.message?.messageId
//        guard let msgId = context.update.message?.messageId ?? callBackQueryId else { return true }
//        StepPvEInputController.customScenario(fight: fight, sesh: context.session, skill: nil, msgId: msgId, text: "")
//        return true
//    }
//    
//    func unmatched(context: Context) -> Bool {
//        guard let message = context.update.message?.text else { return true }
//        guard let messageId = context.update.message?.messageId else { return true }
//        mainBot.deleteQueuedMessageAsync(chatId: ChatId.chat(context.session.userId), messageId: messageId)
//        guard let data = context.message?.text else { return true }
//        let galaxy = context.session.location.galaxyName
//        let index = context.session.location.spaceTileId
//        guard let hexes = galaxies.first(where: {$0.folderName == galaxy})?.spaceMap.hexes else { return true }
//        guard let planet = hexes.first(where: {$0.spiralIndex == index})?.planet else { return true }
//        if data == "/map" {
//            showMapManually(session: context.session, planetEntity: planet)
//        } else if data == "/scan" {
//            SpaceShip.ship(forId: context.session.spaceShip) { unsafeShip in
//                guard let ship = unsafeShip else {
//                    mainBot.sendCustomMessage(session: context.session, text: "⚠️ У вас нет активного космического корабля.")
//                    return
//                }
//                guard ship.elementalVision != nil else {
//                    mainBot.sendCustomMessage(session: context.session, text: "⚠️ У вас нет Элементального Сканера.")
//                    return
//                }
//                guard ship.mapPosition.distanceTo(neededPosition: context.session.location.mapPosition).0 < 3 else {
//                    mainBot.sendCustomMessage(session: context.session, text: "⚠️ Вы далеко от корабля.")
//                    return
//                }
//                let buff = TimeBuff(type: .elementalFeeling, percents: 100, seconds: 60)
//                buff.applyDate = Date()
//                context.session.effects.timeBuffs.append(buff)
//                context.session.save(.effects)
//                let msg = "🌟 Вы активировали сканер и видите на экране схематическое изображение поверхности планеты, а так же нити течения сил стихий. Некоторые потоки кажутся сильнее других... Сосредоточившись на них, кажется можно найти сильное создание! /map"
//                mainBot.sendCustomMessage(session: context.session, text: msg)
//            }
//        } else if let direction = Direction(rawValue: data), Direction.allCases.contains(direction) {
//            
//            let eliteAndGolemUsers = Controllers.allLandsController.eliteMonsterGroups.flatMap({$0.users + $0.deadUsers})
//            let simpleFightUsers = Controllers.allLandsController.simpleMonsterGroups.flatMap({$0.users + $0.deadUsers})
//            let dungeonUsers = Controllers.dungeonPlaceController.dndFightGroups.flatMap({$0.users + $0.deadUsers})
//            let allCaptionGroups = Controllers.disctrictCaptureController.districtsCaptionGroups.flatMap({$0.allUsers})
//            let allPossibleEvents = eliteAndGolemUsers + dungeonUsers + simpleFightUsers + allCaptionGroups
//            guard allPossibleEvents.contains(context.session.userId) == false else { return true }
//            
//            let ships = [context.session.spaceShip, context.session.location.lastVisitedShip]
//            SpaceShip.ships(withIDs: ships.compactMap({$0})) { unsafeSpaceShips in
//                let selfShip = unsafeSpaceShips?.first(where: {$0.uniqueId == context.session.spaceShip})
//                let otherShip = unsafeSpaceShips?.first(where: {$0.uniqueId == context.session.location.lastVisitedShip})
//                let currLoc = context.session.location.routerName
//                if let ship = selfShip, let other = otherShip, ship.location == currLoc, other.location == currLoc {
//                    let distanceOne = context.session.location.mapPosition.distanceTo(neededPosition: ship.mapPosition).0
//                    let distanceTwo = context.session.location.mapPosition.distanceTo(neededPosition: other.mapPosition).0
//                    if distanceOne < distanceTwo {
//                        self.handleCruise(session: context.session, direction: direction, ship: ship, planetEntity: planet)
//                    } else if distanceOne > distanceTwo {
//                        self.handleCruise(session: context.session, direction: direction, ship: other, planetEntity: planet)
//                    } else {
//                        self.handleCruise(session: context.session, direction: direction, ship: ship, planetEntity: planet)
//                    }
//                } else if let ship = selfShip, ship.location == currLoc {
//                    self.handleCruise(session: context.session, direction: direction, ship: ship, planetEntity: planet)
//                } else if let other = otherShip, other.location == currLoc {
//                    self.handleCruise(session: context.session, direction: direction, ship: other, planetEntity: planet)
//                } else {
//                    self.handleCruise(session: context.session, direction: direction, ship: nil, planetEntity: planet)
//                }
//            }
//        } else if data == "🚀⚔️🏔️" {
//            let nearbySortedEntities = searchNearbyEntitiesAndSort(session: context.session, planet: planet)
//            SpaceShip.ship(forId: context.session.spaceShip) { [weak self] unsafeShip in
//                guard let self = self else { return }
//                if let ship = unsafeShip, context.session.location.mapPosition.distanceTo(neededPosition: ship.mapPosition).0 <= 1 {
//                    context.session.techData.mapMessageId = nil
//                    context.session.save(.techData)
//                    let text = "🚀 Меню корабля"
//                    let markup = self.generateControllerKB(session: context.session)
//                    mainBot.sendCustomMessage(session: context.session, text: text, parseMode: .html, replyMarkup: markup)
//                } else if let dungeon: PlanetaryDungeonEntrance = nearbySortedEntities.first as? PlanetaryDungeonEntrance {
//                    self.generalDungeonSwitcher(dungeon: dungeon, session: context.session, planet: planet)
//                } else if let elite: PlanetaryElite = nearbySortedEntities.first as? PlanetaryElite {
//                    self.showPvEMenu(session: context.session, monster: elite)
//                    //PvEController.showPvEInlineMenu(session: session, monster: safeMonster, message: message, noEdit: true)
//                    //fightWithMob(monster: monster, player: player, dungeonPlayer: dungeonPlayer, context: context)
//                } else if let monster: PlanetaryMonster = nearbySortedEntities.first as? PlanetaryMonster {
//                    self.showPvEMenu(session: context.session, monster: monster)
//                    //PvEController.showPvEInlineMenu(session: session, monster: safeMonster, message: message, noEdit: true)
//                    //fightWithMob(monster: monster, player: player, dungeonPlayer: dungeonPlayer, context: context)
//                } else if let resource: PlanetaryResource = nearbySortedEntities.first as? PlanetaryResource {
//                    self.showResourceMenu(session: context.session, resource: resource)
//                }
//            }
//        } else if let fight = Controllers.allLandsController.eliteMonsterGroups.first(where: {($0.users + $0.deadUsers).contains(context.session.userId)}) ?? Controllers.allLandsController.simpleMonsterGroups.first(where: {($0.users + $0.deadUsers).contains(context.session.userId)}) {
//            let skills = AbilityTrees.allSkills.flatMap({$0.abilities})
//            if let skill = skills.first(where: { skill in
//                let cutted = String(message.components(separatedBy: " ").dropFirst().joined(separator: " "))
//                let tmp = message.contains("⏳") ? cutted : message
//                return skill.name == tmp
//            }) {
//                StepPvEInputController.processPvESkillCommand(session: context.session, pveFight: fight, skill: skill, messageId: messageId)
//            } else if message.starts(with: "/") {
//                StepPvEInputController.processPvETextCommand(session: context.session, fight: fight, message: message, messageId: messageId)
//            } else {
//                Controllers.dungeonCollectorController.processEliteMessageChat(from: context.session, message: message, messageId: messageId)
//            }
//        }
//        return true
//    }
//    
//    private func handleCruise(session: Session, direction: Direction, ship: SpaceShip?, planetEntity: Planet?, passthrough: Bool = false) {
//        let fall: ((Session)->Void) = { session in session.settings.isCruisingNow = nil; session.save(.settings) }
//        let unsafePlanet: Planet?
//        if let safePlanet = planetEntity { unsafePlanet = safePlanet } else {
//            let galaxy = session.location.galaxyName; let index = session.location.spaceTileId
//            guard let hexes = galaxies.first(where: {$0.folderName == galaxy})?.spaceMap.hexes else { fall(session); return }
//            guard let safePlanet = hexes.first(where: {$0.spiralIndex == index})?.planet else { fall(session); return }
//            unsafePlanet = safePlanet
//        }
//        guard let planet = unsafePlanet else { fall(session); return }
//        guard let position = planet.map.canMoveCharacter(session: session, to: direction) else { fall(session); return }
//        let planetaryCheck = session.performPlanetaryMoveCheck(planet: planet)
//        guard planetaryCheck.result else { fall(session); return }
//        session.location.mapPosition = position
//        session.player.setCurrentHealth(planetaryCheck.player.getCurrentHealth())
//        session.checkSpaceHealCondition(ship: ship)
//        self.generatePlayerMap(planet: planet, session: session, ship: ship)
//        guard session.settings.cruiseIsEnabled else {
//            session.settings.isCruisingNow = nil
//            session.save(([.settings, .mapPosition, .currentHealth] + planetaryCheck.policies).unique)
//            return
//        }
//        if passthrough == false, let currentDir = session.settings.isCruisingNow, currentDir == direction {
//            if session.settings.isCruisingNow != nil {
//                session.settings.isCruisingNow = nil
//                session.save(([.settings, .mapPosition, .currentHealth] + planetaryCheck.policies).unique)
//            } else {
//                session.save(([.mapPosition, .currentHealth] + planetaryCheck.policies).unique)
//            }
//        } else {
//            if passthrough == false && direction != session.settings.isCruisingNow {
//                session.settings.isCruisingNow = direction
//                session.save(([.settings, .mapPosition, .currentHealth] + planetaryCheck.policies).unique)
//            } else {
//                session.save(([.mapPosition, .currentHealth] + planetaryCheck.policies).unique)
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
//                Session.session(forChatId: session.userId) { unsafeSession in
//                    guard let fresh = unsafeSession, let self = self else { return }
//                    guard let dir = fresh.settings.isCruisingNow, dir == direction else { return }
//                    self.handleCruise(session: fresh, direction: direction, ship: ship, planetEntity: planet, passthrough: true)
//                }
//            }
//        }
//    }
//    
//    func showMapManually(session: Session, planetEntity: Planet?, additionalMessage: String? = nil, messageId: Int? = nil) {
//        let planet: Planet?
//        if let safePlanet = planetEntity {
//            planet = safePlanet
//        } else {
//            let galaxy = session.location.galaxyName
//            let index = session.location.spaceTileId
//            guard let hexes = galaxies.first(where: {$0.folderName == galaxy})?.spaceMap.hexes else { return }
//            guard let safePlanet = hexes.first(where: {$0.spiralIndex == index})?.planet else { return }
//            planet = safePlanet
//        }
//        guard let planet = planet else { return }
//        SpaceShip.ship(forId: session.spaceShip) { ship in
//            Session.sessions(forLocation: session.location.routerName) { allSessions in
//                SpaceShip.ships(forLocation: session.location.routerName) { [weak self] allShips in
//                    guard let self = self, let sessions = allSessions, let ships = allShips else { return }
//                    var text = self.generateMessageHeader(session: session, planet: planet, ship: ship) ?? ""
//                    let mapOutput = planet.map.createOutputForPlayer(allUsers: sessions, ships: ships, session: session,
//                                                                     mobs: planet.monsters, elites: planet.elites,
//                                                                     resources: planet.resources, dungeons: planet.dungeonEntrances)
//                    guard let map = mapOutput else { return }
//                    text.append((text == "" ? "" : "\n\n") + map)
//                    if let footer = additionalMessage { text.append("\n\(footer)") }
//                    if let messageToDelete = messageId {
//                        mainBot.deleteQueuedMessageAsync(chatId: ChatId.chat(session.userId), messageId: messageToDelete) { _,_ in
//                            mainBot.sendCustomMessage(session: session, text: text, parseMode: .html) { newMessage, _ in
//                                guard let newMessage = newMessage else { return }
//                                session.techData.mapMessageId = newMessage.messageId
//                                session.save(.techData)
//                            }
//                        }
//                    } else {
//                        mainBot.sendCustomMessage(session: session, text: text, parseMode: .html) { newMessage, _ in
//                            guard let newMessage = newMessage else { return }
//                            session.techData.mapMessageId = newMessage.messageId
//                            session.save(.techData)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    private func showPvEMenu(session: Session, monster: PlanetaryMonster) {
//        let fight = "space pve:\(monster.position.r):\(monster.position.c)"
//        //let stepFight = "toggle step-pve:\(monster.level):\(monster.monsterType)"
//        let variants = ["🤺 Напасть", "🤺 Hапасть", "🤺 Нaпасть", "🤺 Напaсть", "🤺 Напаcть", "🤺 Нaпacть",
//                        "🤺 Haпасть", "🤺 Hапaсть", "🤺 Hапаcть", "🤺 Haпаcть", "🤺 Hапacть", "🤺 Haпacть"]
//        let button1 = InlineKeyboardButton(text: variants.randomElement() ?? "🤺 Напасть")
//        let button2 = InlineKeyboardButton(text: "🔙 Назад", callbackData: "space pve:cancel")
//        button1.callbackData = fight
//        let inlineKeyboardClassButtons = [[button1, button2]]
//        let inline = InlineKeyboardMarkup(inlineKeyboard: inlineKeyboardClassButtons)
//        let markup = ReplyMarkup.inlineKeyboardMarkup(inline)
//        let monsterClass = Class(rawValue: monster.entity.monsterType.lowercased())
//        let icon = monsterClass == .warrior ? "⚔️" : (monsterClass == .archer ? "🏹" : "🔮")
//        let playerStats = session.generatePlayerStats()
//        let playerName = "\(playerStats.getHealthString(of: session))"
//        let text = """
//        \(PvEController.randomGreetingMessage)\(icon)<b>\(monster.entity.name) Ур:\(monster.entity.level) ❤️\(Int(monster.entity.hP))</b>
//        
//        🧬 Ваше здоровье: \(playerName)
//        🕹 Выберите действие?
//        """
//        mainBot.sendCustomMessage(session: session, text: text, parseMode: .html, replyMarkup: markup)
//    }
//    
//    private func showPvEMenu(session: Session, monster: PlanetaryElite) {
//        guard let eliteMob = EliteMonstersHelper.planetaryElites.first(where: {$0.id == monster.eliteMonsterId}) else { return }
//        guard eliteMob.isAlive == true else {
//            mainBot.sendCustomMessage(session: session, text: "⚠️ К сожалению противник уже мертв!")
//            return
//        }
//        var healthPreMessage = ""
//        if let fight = Controllers.allLandsController.eliteMonsterGroups.first(where: {$0.currentMobs.contains(where: {$0.id == eliteMob.id})}), let mob = fight.currentMobs.first(where: {$0.stats.monsterType == "Ancient"}) {
//            healthPreMessage = "\(Int(mob.currentHealth))/"
//        }
//        let fight = "space elite:\(monster.position.r):\(monster.position.c):\(monster.eliteMonsterId)"
//        let button1 = InlineKeyboardButton(text: "🤺 Начать бой с боссом")
//        button1.callbackData = fight
//        let inlineKeyboardClassButtons: [[InlineKeyboardButton]] = [[button1]]
//        let markup = ReplyMarkup.inlineKeyboardMarkup(InlineKeyboardMarkup(inlineKeyboard: inlineKeyboardClassButtons))
//        let monsterClass = Class(rawValue: eliteMob.stats.monsterType.lowercased())
//        let icon = monsterClass == .warrior ? "⚔️" : (monsterClass == .archer ? "🏹" : "🔮")
//        let text = """
//        \(PvEController.randomEliteGreetingMessage)\(icon)<b>\(eliteMob.name) Ур:\(eliteMob.stats.level) ❤️\(healthPreMessage)\(Int(eliteMob.stats.hP))</b>
//        
//        📜 \(eliteMob.stats.description)
//
//        ☝️ Этот монстр является элитным и бой не будет происходить автоматически. Подробнее в разделе "Элитные монстры" (/help).
//        """
//        mainBot.sendCustomMessage(session: session, text: text, parseMode: .html, replyMarkup: markup)
//    }
//    
//    private func showResourceMenu(session: Session, resource: PlanetaryResource) {
//        let gathering = "space gather:\(resource.position.r):\(resource.position.c)"
//        guard let icon = resource.entity.getSpaceIcon() else { return }
//        guard let name = resource.entity.getSpaceName() else { return }
//        let button2 = InlineKeyboardButton(text: "🔙 Назад", callbackData: "space pve:cancel")
//        let tool = session.inventory.tools.first(where: {$0.id == Resources.AdvancedTools.multitool.resource.id})
//        var text: String
//        var markup: ReplyMarkup
//        if let tool = tool {
//            let button1 = InlineKeyboardButton(text: "🔫 Собирать", callbackData: gathering)
//            let inline = InlineKeyboardMarkup(inlineKeyboard: [[button1, button2]])
//            markup = ReplyMarkup.inlineKeyboardMarkup(inline)
//            text = """
//            \(icon) <b>\(name)</b>
//            
//            ⏱️ Размер: \(resource.currentQuantity)
//            🔫 Мультитул: ⛽️(\(tool.health)/\(tool.maxHealth))
//            """
//        } else {
//            let inline = InlineKeyboardMarkup(inlineKeyboard: [[button2]])
//            markup = ReplyMarkup.inlineKeyboardMarkup(inline)
//            text = """
//            \(icon)<b>\(name)</b>
//            
//            ⏱️ Размер: \(resource.currentQuantity)
//            🔫 Мультитул: Отсутствует
//            """
//        }
//        var users: Int
//        let predicate: (MultitoolGathering) -> Bool = { entity in
//            guard let location = entity.location else { return false }
//            let samePosition = location.location == session.location.mapPosition
//            let sameRouter = location.router == session.location.routerName
//            return samePosition && sameRouter
//        }
//        switch resource.entity {
//        case .fishman: users = AFKProfessionsRunLoop.shrd.multitoolFishing.filter(predicate).count
//        case .lumberjack: users = AFKProfessionsRunLoop.shrd.multitoolLumbers.filter(predicate).count
//        case .herbalist: users = AFKProfessionsRunLoop.shrd.multitoolHerbals.filter(predicate).count
//        case .digger: users = AFKProfessionsRunLoop.shrd.multitoolDiggers.filter(predicate).count
//        default: users = 0
//        }
//        text.append("\n👥 Пилотов: \(users)")
//        mainBot.sendCustomMessage(session: session, text: text, parseMode: .html, replyMarkup: markup)
//    }
//    
//    func onSpaceship(context: Context) -> Bool {
//        ProcessesOutOfController.handleShipProfileCommand(session: context.session)
//        return true
//    }
//    
//    func onStart(context: Context) -> Bool {
//        context.session.checkSpaceHealCondition(ship: nil, forcedKick: true)
//        AFKProfessionsRunLoop.shrd.removeFromAFK(session: context.session)
//        return Controllers.starPlatformController.onStart(context: context)
//    }
//    
//    private func onLanding(context: Context) -> Bool {
//        SpaceShip.ship(forId: context.session.spaceShip) { [weak self] unsafeShip in
//            guard let self = self, let ship = unsafeShip else { return }
//            self.landingLogic(session: context.session, ship: ship)
//        }
//        return true
//    }
//    
//    func landingLogic(session: Session, ship: SpaceShip, _ forcedPosition: WorldPosition? = nil) {
//        let galaxy = session.location.galaxyName
//        let index = session.location.spaceTileId
//        guard let hexes = galaxies.first(where: {$0.folderName == galaxy})?.spaceMap.hexes else { return }
//        guard let planet = hexes.first(where: {$0.spiralIndex == index})?.planet else { return }
//        let messages  = Controllers.starPlatformController.generateLandMessages()
//        let uniqIndentifier = "\(session.userId)-\(Date().currentTimeMillis())"
//        let queue     = DispatchQueue(label: "games.llabs.orionnebula.spaceShipLand-\(uniqIndentifier)")
//        let waitQueue = DispatchQueue(label: "games.llabs.orionnebula.spaceShipLandWaiting-\(uniqIndentifier)")
//        let markup    = self.generateControllerKB(session: session)
//        queue.async {
//            var messageId: Int?
//            for (index, message) in messages.enumerated() {
//                let queueSemaphore = DispatchSemaphore(value: 0)
//                waitQueue.asyncAfter(deadline: .now() + .milliseconds(300)) {
//                    if let messageId = messageId {
//                        let chatId = ChatId.chat(session.userId)
//                        mainBot.editQueuedMessageAsync(chatId: chatId, messageId: messageId, text: message) { _, _ in
//                            queueSemaphore.signal()
//                        }
//                    } else {
//                        mainBot.sendCustomMessage(session: session, text: message, parseMode: .html) { message, _ in
//                            messageId = message?.messageId
//                            queueSemaphore.signal()
//                        }
//                    }
//                }
//                queueSemaphore.wait()
//                if index == messages.count - 1 {
//                    let optPosition = self.getAvailablePosition(session: session, planet: planet, ship: ship, forced: true)
//                    let position = forcedPosition ?? optPosition
//                    session.location.mapPosition = position
//                    if forcedPosition != nil, ship.location == session.location.routerName {
//                        ship.mapPosition = position
//                        ship.save(.mapPosition)
//                    }
//                    print("🚀\(ship.name) - \(session.player.nickName) - \(planet.name) - Landed")
//                    session.techData.mapMessageId = nil
//                    session.save([.mapPosition, .techData])
//                    var text = "🌏 Вы приземлились на планету <b>\(planet.name)</b>."
//                    if forcedPosition != nil { text.append("\n🤔 Это было тут все это время?") }
//                    mainBot.sendCustomMessage(session: session, text: text, parseMode: .html, replyMarkup: markup)
//                    if ship.passengers.count > 0 {
//                        ship.passengers.forEach { passenger in
//                            mainBot.sendQueuedMessageAsync(chatId: ChatId.chat(passenger), text: text, parseMode: .html)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func onExplore(context: Context) -> Bool {
//        self.onExploreLogic(session: context.session)
//        return true
//    }
//    
//    func onExploreLogic(session: Session) {
//        let galaxy = session.location.galaxyName
//        let index = session.location.spaceTileId
//        guard let hexes = galaxies.first(where: {$0.folderName == galaxy})?.spaceMap.hexes else { return }
//        guard let planet = hexes.first(where: {$0.spiralIndex == index})?.planet else { return }
//        let ships = [session.spaceShip, session.location.lastVisitedShip]
//        SpaceShip.ships(withIDs: ships.compactMap({$0})) { unsafeSpaceShips in
//            let selfShip = unsafeSpaceShips?.first(where: {$0.uniqueId == session.spaceShip})
//            let otherShip = unsafeSpaceShips?.first(where: {$0.uniqueId == session.location.lastVisitedShip})
//            let spaceShip: SpaceShip? = selfShip ?? otherShip
//            if let ship = spaceShip {
//                guard self.exosChecks(session: session, planet: planet, ship: ship) else { return }
//            }
//            let position = self.getAvailablePosition(session: session, planet: planet, ship: spaceShip)
//            session.location.mapPosition = position
//            session.techData.mapMessageId = nil
//            session.checkSpaceHealCondition(ship: spaceShip)
//            session.save([.location, .techData])
//            self.generatePlayerMap(planet: planet, session: session, ship: spaceShip)
//        }
//    }
//    
//    func getAvailablePosition(session: Session, planet: Planet, ship: SpaceShip?, forced: Bool = false) -> WorldPosition {
//        var position: WorldPosition
//        if session.location.mapPosition != WorldPosition.Zero && forced == false {
//            let groundIndicies = Planet.getGroundTiles(planet.map)
//            //let takenTiles = planet.planetarEntities.compactMap({$0.position})
//            if groundIndicies.0.contains(where: { (c, r) in
//                let isExactCol = c == session.location.mapPosition.c
//                let isExactRow = r == session.location.mapPosition.r
//                //let isNotTaken = takenTiles.contains(WorldPosition(c: c, r: r)) == false
//                return isExactCol && isExactRow// && isNotTaken
//            }) {
//                position = session.location.mapPosition
//            } else {
//                position = planet.findFreePlaceNearPosition()
//                if let ship = ship, ship.location == session.location.routerName {
//                    ship.mapPosition = position
//                    ship.save(.mapPosition)
//                }
//            }
//        } else {
//            position = planet.findFreePlaceNearPosition()
//            if let ship = ship, ship.location == session.location.routerName {
//                ship.mapPosition = position
//                ship.save(.mapPosition)
//            }
//        }
//        return position
//    }
//    
//    func exosChecks(session: Session, planet: Planet, ship: SpaceShip, additionalRecipient: Int64? = nil) -> Bool {
//        let oxygenId = Resources.ExoSkeleton.oxygenProvider.resource.id
//        let defenderId = Resources.ExoSkeleton.defenceProvider.resource.id
//        if let lifeSaver = session.inventory.tools.first(where: {$0.id == oxygenId}) {
//            guard lifeSaver.health > planet.getOxygenUsage() else {
//                mainBot.sendCustomMessage(session: session, text: """
//                🚀 Система обнаружения угроз корабля \(ship.name):
//                - <code>Ваша "🌬 Cистема Жизнеобеспечения" разряжена. Шлюз не был открыт, так как в противном случае Вы умрете от недостатка кислорода.</code>
//                """, parseMode: .html)
//                if let shipOwner = additionalRecipient {
//                    mainBot.sendQueuedMessageAsync(chatId: ChatId.chat(shipOwner), text: """
//                    🚀 Система обнаружения угроз корабля \(ship.name):
//                    - <code>"🌬 Cистема Жизнеобеспечения" пассажира \(session.player.shortName) разряжена. Шлюз не был открыт, так как в противном случае пассажир умрет от недостатка кислорода.</code>
//                    """, parseMode: .html)
//                }; return false
//            }
//        } else {
//            mainBot.sendCustomMessage(session: session, text: """
//            🚀 Система обнаружения угроз корабля \(ship.name):
//            - <code>Вы попытались покинуть корабль без "🌬 Cистемы Жизнеобеспечения". Шлюз не был открыт, так как в противном случае Вы умрете от недостатка кислорода.</code>
//            """, parseMode: .html)
//            if let shipOwner = additionalRecipient {
//                mainBot.sendQueuedMessageAsync(chatId: ChatId.chat(shipOwner), text: """
//                🚀 Система обнаружения угроз корабля \(ship.name):
//                - <code>Пассажир \(session.player.shortName) попытался покинуть корабль без "🌬 Cистемы Жизнеобеспечения". Шлюз не был открыт, так как в противном случае пассажир умрет от недостатка кислорода.</code>
//                """, parseMode: .html)
//            }; return false
//        }
//        if let defender = session.inventory.tools.first(where: {$0.id == defenderId}) {
//            if PlanetType.getGoodPlanets().contains(planet.type) && defender.health <= planet.getDefenderUsage() {
//                if planet.isWeatherCrysis {
//                    mainBot.sendCustomMessage(session: session, text: """
//                    🚀 Система обнаружения угроз корабля \(ship.name):
//                    - <code>Система "🌐 Защиты От Вредных Факторов" разряжена. Шлюз не был открыт, так как сейчас на планете неблагоприятные условия. Зарядите систему, или же подождите немного.</code>
//                    """, parseMode: .html)
//                    if let shipOwner = additionalRecipient {
//                        mainBot.sendQueuedMessageAsync(chatId: ChatId.chat(shipOwner), text: """
//                        🚀 Система обнаружения угроз корабля \(ship.name):
//                        - <code>Система "🌐 Защиты От Вредных Факторов" пассажира \(session.player.shortName) разряжена. Шлюз не был открыт, так как сейчас на планете неблагоприятные условия. Зарядите систему, или же подождите немного.</code>
//                        """, parseMode: .html)
//                    }; return false
//                } else {
//                    mainBot.sendCustomMessage(session: session, text: """
//                    🚀 Система обнаружения угроз корабля \(ship.name):
//                    - <code>Система "🌐 Защиты От Вредных Факторов" разряжена. Шлюз был открыт, однако в случае ухудшения планетарных условий, Вы можете попасть в несовместимые с жизнью условия.</code>
//                    """, parseMode: .html)
//                    if let shipOwner = additionalRecipient {
//                        mainBot.sendQueuedMessageAsync(chatId: ChatId.chat(shipOwner), text: """
//                        🚀 Система обнаружения угроз корабля \(ship.name):
//                        - <code>Система "🌐 Защиты От Вредных Факторов" пассажира \(session.player.shortName) разряжена. Шлюз был открыт, однако в случае ухудшения планетарных условий, пассажир может попасть в несовместимые с жизнью условия.</code>
//                        """, parseMode: .html)
//                    }; return true
//                }
//            } else if defender.health <= planet.getDefenderUsage() {
//                mainBot.sendCustomMessage(session: session, text: """
//                🚀 Система обнаружения угроз корабля \(ship.name):
//                - <code>Система "🌐 Защиты От Вредных Факторов" разряжена. Шлюз не был открыт, так как в противном случае Вы умрете от планетарных условий, несовместимых с жизнью.</code>
//                """, parseMode: .html)
//                if let shipOwner = additionalRecipient {
//                    mainBot.sendQueuedMessageAsync(chatId: ChatId.chat(shipOwner), text: """
//                    🚀 Система обнаружения угроз корабля \(ship.name):
//                    - <code>Система "🌐 Защиты От Вредных Факторов" пассажира \(session.player.shortName) разряжена. Шлюз не был открыт, так как в противном случае пассажир умрет от планетарных условий, несовместимых с жизнью.</code>
//                    """, parseMode: .html)
//                }; return false
//            }
//        } else if PlanetType.getGoodPlanets().contains(planet.type) {
//            mainBot.sendCustomMessage(session: session, text: """
//            🚀 Система обнаружения угроз корабля \(ship.name):
//            - <code>Вы покидаете корабль без "🌐 Защиты От Вредных Факторов". Шлюз был открыт, однако в случае ухудшения планетарных условий, Вы можете попасть в несовместимые с жизнью условия.</code>
//            """, parseMode: .html)
//            if let shipOwner = additionalRecipient {
//                mainBot.sendQueuedMessageAsync(chatId: ChatId.chat(shipOwner), text: """
//                🚀 Система обнаружения угроз корабля \(ship.name):
//                - <code>Пассажир \(session.player.shortName) покидает корабль без "🌐 Защиты От Вредных Факторов". Шлюз был открыт, однако в случае ухудшения планетарных условий, пассажир может попасть в несовместимые с жизнью условия.</code>
//                """, parseMode: .html)
//            }; return true
//        } else {
//            mainBot.sendCustomMessage(session: session, text: """
//            🚀 Система обнаружения угроз корабля \(ship.name):
//            - <code>Вы попытались покинуть корабль без "🌐 Защиты От Вредных Факторов". Шлюз не был открыт, так как в противном случае Вы умрете от планетарных условий, несовместимых с жизнью.</code>
//            """, parseMode: .html)
//            if let shipOwner = additionalRecipient {
//                mainBot.sendQueuedMessageAsync(chatId: ChatId.chat(shipOwner), text: """
//                🚀 Система обнаружения угроз корабля \(ship.name):
//                - <code>Пассажир \(session.player.shortName) попытался покинуть корабль без "🌐 Защиты От Вредных Факторов". Шлюз не был открыт, так как в противном случае пассажир умрет от планетарных условий, несовместимых с жизнью.</code>
//                """, parseMode: .html)
//            }; return false
//        }
//        return true
//    }
//    
//    func generatePlayerMap(planet: Planet, session: Session, ship: SpaceShip?, forcedNew: Bool = false) {
//        Session.sessions(forLocation: session.location.routerName) { allSessions in
//            SpaceShip.ships(forLocation: session.location.routerName) { [weak self] allShips in
//                guard let self = self, let sessions = allSessions, let ships = allShips else { return }
//                guard planet.map.rows > 0 && planet.map.columns > 0 else {
//                    let error = "⚠️ Мир не был сгенерирован и вы находитесь в черном, холодном вакууме. "
//                    let errorDetails = "Случилась ужасная, непростительная ошибка. Обратитесь за помощью к @BASEL_Support."
//                    mainBot.sendCustomMessage(session: session, text: error + errorDetails)
//                    return
//                }
//                var text = self.generateMessageHeader(session: session, planet: planet, ship: ship) ?? ""
//                let mapOutput = planet.map.createOutputForPlayer(allUsers: sessions, ships: ships, session: session,
//                                                                       mobs: planet.monsters, elites: planet.elites,
//                                                     resources: planet.resources, dungeons: planet.dungeonEntrances)
//                guard let map = mapOutput else {
//                    let error = "⚠️ Мир не был сгенерирован и вы находитесь в черном, холодном вакууме. "
//                    let errorDetails = "Случилась ужасная, непростительная ошибка. Обратитесь за помощью к @BASEL_Support."
//                    mainBot.sendCustomMessage(session: session, text: error + errorDetails)
//                    return
//                }
//                text.append((text == "" ? "" : "\n\n") + map)
//                let chatId = ChatId.chat(session.userId)
//                if let messageId = session.techData.mapMessageId, forcedNew == false {
//                    mainBot.editQueuedMessageAsync(chatId: chatId, messageId: messageId, text: text, parseMode: .html)
//                } else {
//                    let markup = self.generateMapKeyboardMarkup(/*session: session, planet: planet, ship: ship*/)
//                    let planetText = planet.getPlanetDescription(ship: ship)
//                    mainBot.sendCustomMessage(session: session, text: planetText, parseMode: .html, replyMarkup: markup) { _, _ in
//                        mainBot.sendCustomMessage(session: session, text: text, parseMode: .html) { newMessage, _ in
//                            guard let newMessage = newMessage else { return }
//                            session.techData.mapMessageId = newMessage.messageId
//                            session.save(.techData)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    private func generateMessageHeader(session: Session, planet: Planet, ship: SpaceShip?) -> String? {
//        let playerStats = session.generatePlayerStats()
//        var message = ""
//        var lifeSaverString = "Отсутствует"
//        var defenderString = "Отсутствует"
//        let oxygenId = Resources.ExoSkeleton.oxygenProvider.resource.id
//        let defenderId = Resources.ExoSkeleton.defenceProvider.resource.id
//        if let oxySaver = session.inventory.tools.first(where: {$0.id == oxygenId}) {
//            lifeSaverString = "\(oxySaver.health)/\(oxySaver.maxHealth)"
//        }
//        if let defSaver = session.inventory.tools.first(where: {$0.id == defenderId}) {
//            defenderString = "\(defSaver.health)/\(defSaver.maxHealth)"
//        }
//        
//        
//        // Energy Refresh Text Calc Preparations
//        let prevTime = EnergyRunLoop.shared.getLastEnergyEditTime(userId: session.userId)
//        var timeLeft: String? = nil
//        let neededTimeToRefill = session.userData.isPremiumHost ? premEnrgyRefill : energyRefill
//        let timeToRegen = neededTimeToRefill - Int(Date().timeIntervalSince(prevTime))
//        if timeToRegen  >= 1 && timeToRegen <= neededTimeToRefill {
//            let minutes = "\(timeToRegen / 60 >= 10 ? "\(timeToRegen / 60)" : "0\(timeToRegen / 60)")"
//            let seconds = "\(timeToRegen % 60 >= 10 ? "\(timeToRegen % 60)" : "0\(timeToRegen % 60)")"
//            timeLeft = "\(minutes):\(seconds)"
//        }
//        let currentEnergy = EnergyRunLoop.shared.getCurrentEnergy(userId: session.userId)
//        let energyString  = "⚡️: \(currentEnergy)/\(maxEnergy) \((timeLeft == nil || currentEnergy >= maxEnergy) ? "" : "⏱ \(timeLeft!)")"
//        let userIdString  = timeLeft != nil ? "🧬: <code>\(session.userId)</code>" : ""
//        var shipString    = ""
//        if let safeShip   = ship {
//            let shipDistance = session.location.mapPosition.distanceTo(neededPosition: safeShip.mapPosition)
//            shipString    = safeShip.location == session.location.routerName ? "🚀: \(shipDistance.1.rawValue)\(shipDistance.0)" : ""
//        }
//        
//        if session.effects.timeBuffs.contains(where: {$0.type == .elementalFeeling}), let elite = planet.elites.last {
//            let eliteDistance = session.location.mapPosition.distanceTo(neededPosition: elite.position)
//            shipString = "🌟: \(eliteDistance.1.rawValue)\(eliteDistance.0)"
//        }
//        let onOff = session.settings.cruiseIsEnabled ? "Off" : "On"
//        
//        switch session.settings.mapViewType {
//        case .iOS:
//            message.append("""
//            ❤️ HP: \(playerStats.getShortHealthString())  \(shipString)
//            \(energyString)  \(userIdString)
//            🌬 O2: \(lifeSaverString)  🌐: \(defenderString)
//            \(playerStats.starvation > 29 ? (playerStats.starvation <= 300 ? "🍖:" : "🥱:") : "🥣:") \(playerStats.starvation)  📖: \(Int(session.player.currentExp).pretty)
//            🗺 \(session.location.mapPosition.r):\(session.location.mapPosition.c)  /mapSize /mType /cruise\(onOff)
//            """)
//        case .androidLong:
//            message.append("""
//            ❤️ HP: \(playerStats.getShortHealthString())  \(shipString)
//            \(energyString)  \(userIdString)
//            🌬 O2: \(lifeSaverString)  🌐: \(defenderString)
//            \(playerStats.starvation > 29 ? (playerStats.starvation <= 300 ? "🍖:" : "🥱:") : "🥣:") \(playerStats.starvation)  📖: \(Int(session.player.currentExp).pretty)
//            🗺 \(session.location.mapPosition.r):\(session.location.mapPosition.c)  /mapSize /mType /cruise\(onOff)
//            """)
//        case .androidShort:
//            message.append("""
//            ❤️ HP: \(playerStats.getShortHealthString())  \(shipString)
//            〰️〰️〰️〰️〰️〰️〰️〰️
//            \(energyString)  \(userIdString)
//            〰️〰️〰️〰️〰️〰️〰️〰️
//            🌬 O2: \(lifeSaverString)  🌐: \(defenderString)
//            〰️〰️〰️〰️〰️〰️〰️〰️
//            \(playerStats.starvation > 29 ? (playerStats.starvation <= 300 ? "🍖:" : "🥱:") : "🥣:") \(playerStats.starvation)  📖: \(Int(session.player.currentExp).pretty)
//            〰️〰️〰️〰️〰️〰️〰️〰️
//            🗺 \(session.location.mapPosition.r):\(session.location.mapPosition.c)  /mapSize /mType /cruise\(onOff)
//            〰️〰️〰️〰️〰️〰️〰️〰️
//            """)
//        }
//        //let nearbyMonsters = planet.map.monsters.filter({
//        //    $0.position.distanceTo(neededPosition: proceduralUser.position).0 < 3
//        //}).compactMap({
//        //    planet.map.tileMap[$0.position.c, $0.position.r]
//        //})
//        //if nearbyMonsters.count > 0 {
//        //    message.append("\n🐺 Рядом монстры: \(nearbyMonsters.joined())")
//        //}
//        //let nearbyChests = group.map.chests.filter({$0.distanceTo(neededPosition: proceduralUser.position).0 < 3})
//        //if nearbyChests.count > 0 {
//        //    message.append("\n📦 Рядом сундук!")
//        //}
//        //let nearbyHeals = group.map.heals.filter({$0.distanceTo(neededPosition: proceduralUser.position).0 < 3})
//        //if nearbyHeals.count > 0 {
//        //    message.append("\n💞 Рядом целительная энергия!")
//        //}
//        return message
//    }
//    
//    override func generateControllerKB(session: Session? = nil) -> ReplyMarkup? {
//            let markup = ReplyKeyboardMarkup(keyboard: [
//                [   localButtons[0]   ,   localButtons[1]   ],
//                [ Commands.hero.button,   localButtons[2]   ]
//            ], resizeKeyboard: true)
//        return ReplyMarkup.replyKeyboardMarkup(markup)
//    }
//    
//    func generateMapKeyboardMarkup(/*session: Session, planet: Planet, ship: SpaceShip*/) -> ReplyMarkup? {
//        let customIcon: String = "🚀⚔️🏔️"
//        //let shipDistance = session.location.mapPosition.distanceTo(neededPosition: ship.mapPosition)
//        //let nearbySortedMonsters = self.searchNearbyMonstersAndSort(session: session, planet: planet)
//        //if nearbySortedMonsters.count > 0 {
//        //    customIcon = "⚔️💥"
//        //}
//        //if shipDistance.0 <= 1 {
//        //    customIcon = "🚀📟"
//        //}
//        let directionPics: [ String  ] = ["⬆️",   "⬇️",   "⬅️",    "➡️",    "↖️",   "↗️",   "↙️",   "↘️"]
//        let buttons: [[String]] = [
//            [directionPics[4],         directionPics[0],         directionPics[5]],
//            [directionPics[2],            customIcon,            directionPics[3]],
//            [directionPics[6],         directionPics[1],         directionPics[7]],
//        ]
//        let buttonsReady = buttons.compactMap({ $0.compactMap({ KeyboardButton(text: $0) }) })
//        let keyboard = ReplyKeyboardMarkup(keyboard: buttonsReady)
//        keyboard.resizeKeyboard = true
//        return ReplyMarkup.replyKeyboardMarkup(keyboard)
//    }
//    
//    private func searchNearbyEntitiesAndSort(session: Session, planet: Planet) -> [PlanetarEntity] {
//        let userPosition = session.location.mapPosition
//        let posPredicate: (PlanetarEntity) -> Bool = { entity in
//            entity.position.distanceTo(neededPosition: userPosition).0 <= 1
//        }
//        let predicateDistance: (PlanetarEntity, PlanetarEntity) -> Bool = {
//            let oneDistance = $0.position.distanceTo(neededPosition: userPosition).0
//            let twoDistance = $1.position.distanceTo(neededPosition: userPosition).0
//            return oneDistance < twoDistance
//        }
//        let allEntities: [PlanetarEntity] = (planet.elites + planet.monsters + planet.resources + planet.dungeonEntrances).filter(posPredicate)
//        return allEntities.filter({$0.isDead == false}).sorted(by: predicateDistance)
//    }
//}
//
//extension ProceduralPlanetController {
//    func onCallbackQuery(context: Context) throws -> Bool {
//        callBackLogic(session: context.session, update: context.update)
//        return true
//    }
//    
//    func callBackLogic(session: Session, update: Update) {
//        guard let callback_query = update.callbackQuery else { return }
//        guard let data      = callback_query.data else { return }
//        guard let messageId = callback_query.message?.messageId else { return }
//        let galaxy = session.location.galaxyName
//        let index = session.location.spaceTileId
//        guard let hexes = galaxies.first(where: {$0.folderName == galaxy})?.spaceMap.hexes else { return }
//        guard let planet = hexes.first(where: {$0.spiralIndex == index})?.planet else { return }
//        let chatId = ChatId.chat(callback_query.from.id)
//        var command = data
//        if data == "space pve:cancel" || data == "space elite:cancel" || data == "space gather:cancel" {
//            mainBot.deleteQueuedMessageAsync(chatId: chatId, messageId: messageId)
//        } else if data.contains("space pve:") {
//            command = data.replacing("space pve:", with: "")
//            let components = command.components(separatedBy: ":")
//            if components.count == 2, let rStr = components.first, let cStr = components.last {
//                mainBot.deleteQueuedMessageAsync(chatId: chatId, messageId: messageId)
//                guard let r = Int(rStr), let c = Int(cStr) else { return }
//                guard let monster = planet.monsters.first(where: {$0.position == (r,c)})else { return }
//                guard monster.isDead == false else { return }
//                guard monster.position.distanceTo(neededPosition: session.location.mapPosition).0 <= 1 else { return }
//                self.processPVE(with: monster, session: session)
//            }
//        } else if data.contains("space elite:") {
//            command = data.replacing("space elite:", with: "")
//            let components = command.components(separatedBy: ":")
//            if components.count == 3, components[0].count < "\(Int.max)".count, components[1].count < "\(Int.max)".count {
//                mainBot.deleteQueuedMessageAsync(chatId: chatId, messageId: messageId)
//                guard let r = Int(components[0]), let c = Int(components[1]) else { return }
//                guard let mobStr = components.last, let mobId = Int64(mobStr) else { return }
//                guard let monster = planet.elites.first(where: {$0.position == (r,c) && $0.eliteMonsterId == mobId}) else { return }
//                guard monster.isDead == false else { return }
//                guard monster.position.distanceTo(neededPosition: session.location.mapPosition).0 <= 1 else { return }
//                _ = self.processEliteMobsPVECallBackQuery(session: session, mobId: monster.eliteMonsterId, html: .html)
//            }
//        } else if data.contains("space gather:") {
//            command = data.replacing("space gather:", with: "")
//            let components = command.components(separatedBy: ":")
//            if components.count == 2, let rStr = components.first, let cStr = components.last {
//                mainBot.deleteQueuedMessageAsync(chatId: chatId, messageId: messageId)
//                guard let r = Int(rStr), let c = Int(cStr) else { return }
//                startGathering(session: session, position: WorldPosition(c: c, r: r), planetEntity: planet)
//            }
//        } else if data.contains("multitool:try:") {
//            processCallbacksForGathering(session: session, data: data, messageId: messageId)
//        }
//    }
//    
//    func startGathering(session: Session, position: WorldPosition?, planetEntity: Planet?) {
//        var unsafePlanet: Planet? = nil
//        if let entity = planetEntity {
//            unsafePlanet = entity
//        } else {
//            let galaxy = session.location.galaxyName
//            let index = session.location.spaceTileId
//            guard let hexes = galaxies.first(where: {$0.folderName == galaxy})?.spaceMap.hexes else { return }
//            guard let planet = hexes.first(where: {$0.spiralIndex == index})?.planet else { return }
//            unsafePlanet = planet
//        }
//        guard let planet = unsafePlanet else { return }
//        var unsafePosition: WorldPosition? = nil
//        if let entity = position {
//            unsafePosition = entity
//        } else {
//            unsafePosition = planet.resources.filter({
//                $0.position.distanceTo(neededPosition: session.location.mapPosition).0 <= 1 && $0.isDead == false
//            }).sorted(by: {
//                let oneDistance = $0.position.distanceTo(neededPosition: session.location.mapPosition).0
//                let twoDistance = $1.position.distanceTo(neededPosition: session.location.mapPosition).0
//                return oneDistance < twoDistance
//            }).first?.position
//        }
//        guard let position = unsafePosition else { return }
//        let message = "⚠️ У вас нет мультитула.\n\nСначала вам необходимо создать его, или купить у других игроков."
//        guard let resource = planet.resources.first(where: {$0.position == position}) else { return }
//        guard session.inventory.tools.contains(where: {$0.id == 1032}) else {
//            mainBot.sendCustomMessage(session: session, text: message); return
//        }
//        guard resource.position.distanceTo(neededPosition: session.location.mapPosition).0 <= 1 else { return }
//        guard resource.isDead == false && resource.currentQuantity > 0 else { return }
//        let newPosition = GatheringLocation(location: position, router: planet.router)
//        switch resource.entity {
//        case .fishman:
//            FishingPortLocationController.runFishingWithMultitool(session: session, location: newPosition)
//        case .herbalist:
//            ForestryLocationController.runHerbalismWithMultitool(session: session, location: newPosition)
//        case .lumberjack:
//            ForestryLocationController.runWoodCutWithMultitool(session: session, location: newPosition)
//        case .digger:
//            MineDiggerLocation.runDiggingWithMultitool(session: session, location: newPosition)
//        default: return
//        }
//    }
//    
//    private func processPVE(with monster: PlanetaryMonster, session: Session) {
//        var session = session
//        let playerStats = session.generatePlayerStats()
//        guard !blockedUsers.contains(session.userId) else {
//            PvEController.processingSessions.removeAll(where: {$0 == session.userId})
//            return
//        }
//        guard !Controllers.allLandsController.eliteMonsterGroups.contains(where: {$0.users.contains(session.userId)}) else {
//            PvEController.processingSessions.removeAll(where: {$0 == session.userId})
//            return
//        }
//        guard !Controllers.allLandsController.simpleMonsterGroups.contains(where: {$0.users.contains(session.userId)}) else {
//            PvEController.processingSessions.removeAll(where: {$0 == session.userId})
//            return
//        }
//        guard !Controllers.dungeonPlaceController.dndFightGroups.contains(where: {$0.users.contains(session.userId)}) else {
//            PvEController.processingSessions.removeAll(where: {$0 == session.userId})
//            return
//        }
//        let log = PvEController.playerVsMobFightLog(classIcon: session.generateSubClassIcon(), player: playerStats, monster: monster.entity)
//        session.player.setCurrentHealth(log.2.getCurrentHealth())
//        let text = log.0; let isUserWins = log.1; var replyMarkup: ReplyMarkup? = nil
//        if isUserWins == false { replyMarkup = DeathController.generateDeathMarkup() }
//        var exp   = ExperienceProcessor.pVeExperienceLoot(monster: monster.entity)
//        if session.userData.isPremiumHost {
//            exp   = ExperienceProcessor.applyPremiumBonus(exp: exp)
//        }
//        let currentEnergy = EnergyRunLoop.shared.getCurrentEnergy(userId: session.userId)
//        let energyCounter = "\n\n⚡️ Энергия: \(currentEnergy - 1)/\(maxEnergy)"
//        var finalMessage = text + energyCounter
//        if isUserWins {
//            session.statsHistory.mobsInLocationsKilled += 1
//            finalMessage.append("\n\nПолученный опыт 📖: \(Int(exp).pretty)")
//            let dropString = PvEController.generateDrop(session: session, monster: monster.entity)
//            session = dropString.1
//            if dropString.0.count > 0 { finalMessage.append("\n\n\(dropString.0)")}
//        } else {
//            finalMessage.append("\n\nПотерянный опыт 📖: \(Int(ExperienceProcessor.pVeExperienceLost(level: session.player.level)).pretty)")
//        }
//        AFKProfessionsRunLoop.shrd.removeFromAFK(session: session)
//        let operation = EnergyRunLoop.shared.checkEnergyOrDecrease(session: &session)
//        guard operation else {
//            Potions.generateNoEnergyWarning(session: session)
//            PvEController.processingSessions.removeAll(where: {$0 == session.userId})
//            return
//        }
//        if isUserWins, let quest = session.quests.dailyQuests.first(where: {$0.type == DailyType.monsters.rawValue}) {
//            quest.currCounter += 1
//            if quest.currCounter >= quest.neededValue {
//                session = DailyQuests.processSomePrize(session: session, quest: quest)
//            }
//        }
//        let now = Date()
//        session.player.starvation -= 1
//        if session.player.starvation < 0 { session.player.starvation = 0 }
//        session.techData.taskDate = now
//        session.techData.lastActivityTime = now
//        if isUserWins {
//            let result = session.addExperience(exp: exp, cancelSaving: true)
//            result.0?.techData.mapMessageId = nil
//            result.0?.save([.player, .techData, .quests, .statsHistory, .inventory, .settings, .money, .starvation])
//            if let messageId = session.techData.mapMessageId {
//                mainBot.deleteQueuedMessageAsync(chatId: ChatId.chat(session.userId), messageId: messageId)
//            }
//        }
//        mainBot.sendCustomMessage(session: session, text: finalMessage, parseMode: .html, replyMarkup: replyMarkup) { [weak self] _, _ in
//            if isUserWins == false {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    let lostExp = ExperienceProcessor.pVeExperienceLost(level: session.player.level)
//                    PlayerStats.killPlayer(session: session, minusExperience: lostExp)
//                    //supportBot.sendCustomMessage(chatId: ChatId.chat(actionsChannelId), text: """
//                    //    💀 Игрок \(session.generateSubClassIcon())\(session.player.nickName) погибает от:
//                    //    - \(monster.entity.name) 🎖\(monster.entity.level).
//                    //    """, parseMode: .html)
//                    //PvEController.processingSessions.removeAll(where: {$0 == session.userId})
//                }
//            } else if let self = self {
//                PvEController.processingSessions.removeAll(where: {$0 == session.userId})
//                monster.isDead = true
//                let galaxy = session.location.galaxyName
//                let index = session.location.spaceTileId
//                guard let hexes = galaxies.first(where: {$0.folderName == galaxy})?.spaceMap.hexes else { return }
//                guard let planet = hexes.first(where: {$0.spiralIndex == index})?.planet else { return }
//                SpaceShip.ship(forId: session.spaceShip) { [weak self] ship in
//                    guard let self = self else { return }
//                    self.generatePlayerMap(planet: planet, session: session, ship: ship)
//                    session.checkSpaceHealCondition(ship: ship)
//                }
//            }
//        }
//    }
//    
//    private func processEliteMobsPVECallBackQuery(session: Session, mobId: Int64, html: ParseMode, forced: Bool = false) -> Bool {
//        var session = session
//        let afterRestartTime = Date().timeIntervalSince(launched)
//        let spacer: Double = Double(isTest ? 20 : launchedTimeSpacing * 60)
//        guard afterRestartTime > spacer else {
//            mainBot.sendCustomMessage(session: session, text: """
//            ⚠️ Сервер был недавно перезапущен, подождите немного.
//            """)
//            return true
//        }
//        let player = session.player
//        let nickName = player.nickName
//        let alliance = session.player.alliance
//        guard let playerRace = Alliance(rawValue: alliance) else { return true }
//        let icon = session.generateSubClassIcon()
//        guard session.techData.eliteMonstersKilledCounter < 5 || isTest else {
//            mainBot.sendCustomMessage(session: session, text: """
//            ⚠️ Вы достигли лимита убийств Элитных Монстров в сутки.
//            
//            В данный момент максимальное количество равняется пяти.
//            """)
//            return true
//        }
//        guard let eliteMob = EliteMonstersHelper.eliteMonsters.first(where: {$0.id == mobId && ($0.race.lowercased() == playerRace.rawValue.lowercased() || $0.race == Alliance.all.rawValue)}) else { return true }
//        guard eliteMob.isAlive == true else {
//            mainBot.sendCustomMessage(session: session, text: "⚠️ К сожалению противник уже мертв!")
//            return true
//        }
//        guard let monsterRace = Alliance(rawValue: eliteMob.race) else { return true }
//        let playerLevel = session.player.level
//        guard (eliteMob.stats.level > playerLevel - 3 && eliteMob.stats.level <= playerLevel + 2 || isTest) else {
//            var warning = "⚠️ Ваш уровень не позволяет сражаться с этим монстром. Подробнее в разделе \"🌟 Элитные Монстры\" /help.\n\nВы не сможете его атаковать, да и зачем это вам? Вещи выпадут меньше вашего уровня, а опыт с босса подходящего уровня гораздо выше!"
//            if eliteMob.stats.level <= playerLevel - 3 {
//                warning = "⚠️ Ваш уровень слишком высок, чтобы сражаться с этим монстром. Подробнее в разделе \"🌟 Элитные Монстры\" /help.\n\nВы не сможете его атаковать, да и зачем это вам? Вещи выпадут меньше вашего уровня, а опыт с босса подходящего уровня гораздо выше!"
//            } else if eliteMob.stats.level > playerLevel + 2 {
//                warning = "⚠️ Ваш уровень слишком мал, чтобы сражаться с этим монстром. Подробнее в разделе \"🌟 Элитные Монстры\" /help.\n\nВы не сможете его атаковать, да и зачем это вам? Вещи выпадут слишком высокого уровня, а опыт с босса подходящего уровня гораздо выше!"
//            }
//            mainBot.sendCustomMessage(session: session, text: warning)
//            return true
//        }
//        let currentLocation = session.location.routerName
//        guard Controllers.proceduralPlanetController.planetRouters.contains(currentLocation) else {
//            mainBot.sendCustomMessage(session: session, text: """
//            ⚠️ Противник, которого вы пытаетесь одолеть, не принадлежит данной локации!
//            """)
//            return true
//        }
//        let eliteGroups = Controllers.allLandsController.eliteMonsterGroups
//        guard !eliteGroups.contains(where: {$0.users.contains(session.userId)}) else { return true }
//        guard !DistrictLocationController.processingSessions.contains(session.userId) else { return true }
//        DistrictLocationController.processingSessions.append(session.userId)
//        AFKProfessionsRunLoop.shrd.removeFromAFK(session: session)
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//            DistrictLocationController.processingSessions.removeAll(where: {$0 == session.userId})
//        }
//        if let group = Controllers.allLandsController.eliteMonsterGroups.first(where: {$0.currentMobs.contains(where: {$0.id == eliteMob.id}) && ($0.race == monsterRace || $0.race == .all)}) {
//            guard !group.users.contains(session.userId) else {
//                return true
//            }
//            if let mob = group.currentMobs.first(where: {$0.stats.monsterType == "Ancient"}) {
//                
//                guard mob.currentHealth >= ( eliteMob.stats.hP * 0.25 ) else {
//                    mainBot.sendCustomMessage(session: session, text: "⚠️ Вступить в чей-то бой можно только пока у босса больше четверти здоровья!")
//                    return true
//                }
//                
//            }
//            if group.creationDate == nil {
//                group.creationDate = Date()
//            }
//            let operation = EnergyRunLoop.shared.checkEnergyOrDecrease(session: &session)
//            guard operation else {
//                Potions.generateNoEnergyWarning(session: session)
//                return true
//            }
//            group.users.append(session.userId)
//            if let index = group.deadUsers.firstIndex(where: {$0 == session.userId}) {
//                group.deadUsers.remove(at: index)
//            }
//            let powerupTreshold = 3 // (levelRangeOptional?.lowerBound ?? 0) >= 20 ? 3 : 10
//            if group.users.count > powerupTreshold {
//                let oldTotalHp = eliteMob.originalHealthCalc
//                eliteMob.increasedHp += oldTotalHp * 0.2
//                eliteMob.currentHealth += oldTotalHp * 0.2
//                if eliteMob.increasedTimes < 7 {
//                    eliteMob.increasedDmg += Int(Double(eliteMob.originalDmgCalc) * 0.05)
//                    eliteMob.increasedDef += Int(Double(eliteMob.originalDefCalc) * 0.05)
//                    eliteMob.increasedTimes += 1
//                }
//            }
//            let message = "⚔️ Вы вступаете в поединок с \(eliteMob.name)"
//            let markup = Controllers.dungeonPlaceController.generateDungeonFightMarkup(session: session, isDungeon: false)
//            mainBot.sendCustomMessage(session: session, text: message, replyMarkup: markup)
//            session.save([.statsHistory, .starvation, .quests, .settings, .inventory, .money])
//        } else {
//            let operation = EnergyRunLoop.shared.checkEnergyOrDecrease(session: &session)
//            guard operation else {
//                Potions.generateNoEnergyWarning(session: session)
//                return true
//            }
//            let fightGroup = EliteFightGroup(starterUserId: session.userId, monster: eliteMob, race: monsterRace)
//            Controllers.allLandsController.eliteMonsterGroups.append(fightGroup)
//            Session.sessions(forLocation: session.location.routerName) { sessions in
//                var raceString = ""
//                if eliteMob.stats.level < 30 {
//                    raceString = eliteMob.race == Alliance.droid.rawValue ? " [Дроиды]" : " [Люди]"
//                    if eliteMob.race == Alliance.all.rawValue { raceString = "" }
//                }
//                let msg = "⚔️ Игрок \(icon)\(nickName) начал поединок с \(eliteMob.name)\(raceString) 🎖\(eliteMob.stats.level) [\(eliteMob.planetName)]"
//                guard let sessions = sessions?.filter({
//                    $0.userId != session.userId && !blockedUsers.contains($0.userId)
//                }) else { return }
//                let filteredSessions = sessions.filter({$0.player.alliance == session.player.alliance || eliteMob.race == Alliance.all.rawValue})
//                let nearSessions = filteredSessions.filter({$0.location.mapPosition.distanceTo(neededPosition: session.location.mapPosition).0 < 5})
//                for session in nearSessions {
//                    guard !blockedUsers.contains(session.userId) else { continue }
//                    mainBot.sendCustomMessage(session: session, text: msg)
//                }
//                supportBot.sendQueuedMessageAsync(chatId: ChatId.chat(actionsChannelId), text: msg)
//            }
//            let message = "⚔️ Вы вступаете в поединок с \(eliteMob.name) [\(eliteMob.planetName)]"
//            let markup = Controllers.dungeonPlaceController.generateDungeonFightMarkup(session: session, isDungeon: false)
//            mainBot.sendCustomMessage(session: session, text: message, replyMarkup: markup) { _, _ in
//                fightGroup.startTicks()
//            }
//            session.save([.statsHistory, .starvation, .quests, .settings, .inventory, .money])
//        }
//        return true
//    }
//}
