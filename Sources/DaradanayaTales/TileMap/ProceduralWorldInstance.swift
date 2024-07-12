//
//  ProceduralWorldInstance.swift
//  Orion-Nebula
//
//  Created by Maxim Lanskoy on 04.04.2021.
//

import Foundation
import SwiftTelegramSdk

final class ProceduralWorldInstance {
    var dungeonId:     Int64
    var owner:         Int64
    let map:           ProceduralMap
    //var caveType:      CaveType
    var initializationDate: Date
    var deadUsers:     [ProceduralUser] = []
    var usersMessages: [(Int64, Int)] = []
    var users: [ProceduralUser] { didSet { if users.count == 0 { dungeonIsLost() } } }
    
    //static func generateNewDungeonInstance(owner: Int64, users: [DungeonUser], level: Int, caveType: CaveType) -> DungeonInstance {
    //    let dungnId = Date().currentTimeMillis()
    //    let dungeonRanges = [1...5, 6...10, 11...15, 16...20, 21...25, 26...29, 30...30]
    //    let dungeonRSizes = [  20,    30,      40,      50,      60,      70,      80  ]
    //    let size = dungeonRSizes[dungeonRanges.firstIndex(where: {$0.contains(level)})!]
    //    let dungeon = DungeonInstance(dungeonId: "\(dungnId)", owner: owner, users: users, size: size, level: level, caveType: caveType)
    //    return dungeon
    //}
    
    init(owner: Int64, users: [Session]/*, caveType: CaveType*/) {
        self.owner = owner
        //self.caveType = caveType
        let creationDate = Date()
        let size = 1//caveType.getLevelSize()
        self.initializationDate = creationDate
        let level = 1//caveType.getLevelsRange().lowerBound
        self.dungeonId = Int64(creationDate.timeIntervalSince1970)
        let map = ProceduralMap(columns: size, rows: size, tile1: "⬜️", tile2: "⬛️", level: level)
        self.map = map
        let respawn = map.respawn
        let proceduralUsers: [ProceduralUser] = users.compactMap({
            guard let userId = $0.id else { return nil }
            let level = 1//$0.player.level
            let size = $0.settings.emojiMapsize
            let icon = "🤴"//$0.generateSubClassIcon()
            return ProceduralUser(userId: userId, position: respawn, icon: icon, level: level, mapVisibleSize: size)
        })
        self.users = proceduralUsers
    }
    
    func dungeonIsLost() {
        //let squads = DungeonCollectorController.dungeonCollectorGroups
        //guard let users = squads.first(where: {$0.dungeonId == dungeonId})?.users else { return }
        //let userIds = users.compactMap({$0.userId})
        //for userId in userIds {
        //    bot.sendQueuedMessageAsync(chatId: userId, text: "🕸 К сожалению ваша группа потерпела поражение в Логове Пауков. Опыт, полученный за убийство монстров останется с вами, но дополнительная награда за прохождение не получена.")
        //}
        //dungeonLandController.dungeonInstances.removeAll(where: {$0.dungeonId == dungeonId})
    }
    
    static func lastMobDied(dungeonId: String) {
//        let squads = DungeonCollectorController.dungeonCollectorGroups
//        guard let dungeonInstance = dungeonLandController.dungeonInstances.first(where: {$0.dungeonId == dungeonId}) else { return }
//        guard let users = squads.first(where: {$0.dungeonId == dungeonId})?.users else { return }
//        let userIds = users.compactMap({$0.userId})
//        let maxLiveExprc = dungeonInstance.users.sorted(by: {$0.exp   > $1.exp}).first?.exp ?? 0
//        let maxLiveMoney = dungeonInstance.users.sorted(by: {$0.money > $1.money}).first?.money ?? 0
//        let maxDeadExprc = dungeonInstance.diedPlayers.sorted(by: {$0.exp   > $1.exp}).first?.exp ?? 0
//        let maxDeadMoney = dungeonInstance.diedPlayers.sorted(by: {$0.money > $1.money}).first?.money ?? 0
//        let exp = maxLiveExprc > maxDeadExprc ? maxLiveExprc : maxDeadExprc
//        let money = maxLiveMoney > maxDeadMoney ? maxLiveMoney : maxDeadMoney
//        Session.sessions(withIDs: userIds) { (sessions) in
//            guard let sessions = sessions else { return }
//            for session in sessions {
//                var session = session
//                session.location.routerName = "dungeonCollector"
//                if let index = blockedUsers.firstIndex(where: {$0 == session.userId}) { blockedUsers.remove(at: index) }
//
//                let levelsDifference = (dungeonInstance.caveType.getLevelsRange().min() ?? 0) - (session.player.level)
//                var sessionExp: Double = levelsDifference <= 2 ? Double(exp) : Double(Double(exp)/Double(levelsDifference)/200)
//                var sessionMon = levelsDifference <= 2 ? money : money/Float(levelsDifference)/200
//
//                if session.userData.isPremiumHost {
//                    sessionMon   = sessionMon + (sessionMon * 0.5)
//                    sessionExp   = sessionExp   + (sessionExp   * 0.3)
//                }
//                var text = """
//                🎊 Вы успешно завершили прохождение 📿 Аномалии Логова!
//
//                Доп. Добыча: 💰 \(Int(sessionMon))
//                Доп. Опыт: 📖 \(Int(sessionExp))
//                """
//                let dropString = PvEController.generateDropForDungeon(session: &session)
//                if dropString.count > 0 { text.append("\n\n\(dropString)") }
//                session.statsHistory.dungeonFinished += 1
//                session.saveSession()
//                dungeonCollectorController.showDungeonCreatorMenuLogic(session: session, text: text)
//                if session.addExperienceAndMoney(exp: sessionExp, money: sessionMon) {
//                    let fileInfo = InputFile.init(filename: "", data: try! Data.init(contentsOf: )
//                    bot.sendQueuedVideoAsync(chatId: ChatId.chat(actionsChannelId), video: fileInfo, caption: "🏅 Игрок \(session.player.nickName) получает \(session.player.level ?? -1) уровень!")
//                    bot.sendCustomMessage(session: session, text: """
//                    🎊 Поздравляю, Вы получили новый уровень! 🎊
//                    """) { message, error in
//                        guard let messageId = message?.messageId else { return }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
//                            bot.deleteQueuedMessageAsync(chatId: ChatId.chat(session.userId), messageId: messageId)
//                        }
//                    }
//                }
//            }
//            dungeonLandController.dungeonInstances.removeAll(where: {$0.dungeonId == dungeonId})
//        }
    }
}
