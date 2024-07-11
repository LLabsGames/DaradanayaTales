//
//  AddController.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

//import Foundation
//import SwiftTelegramSdk
//
//class AddController {
//    typealias T = AddController
//    
//    init(bot: TGBot) {
//        routers["add"] = TGRouter(bot: bot) { router in
//            router[Commands.help, .slashRequired] = onHelp
//            router[Commands.cancel, .slashRequired] = onCancel
//            router.unmatched = addItem
//        }
//    }
//    
//    func onHelp(context: TGContext) -> Bool {
//        showHelp(context: context)
//        return true
//    }
//
//    func onCancel(context: TGContext) throws -> Bool {
//        try mainController.showMainMenu(context: context, text: "Cancelled")
//        context.session.routerName = "main"
//        try context.session.save()
//        return true
//    }
//    
//    func addItem(context: TGContext) throws -> Bool {
//        guard let chatId = context.chatId else { return false }
//        let name = context.args.scanRestOfString()
//        guard name != Commands.add[0] else { return false } // Button pressed twice in a row
//        try Item.add(name: name, chatId: chatId)
//        try mainController.showMainMenu(context: context, text: "Added: \(name)")
//        context.session.routerName = "main"
//        try context.session.save()
//        return true
//    }
//    
//    func showHelp(context: TGContext) {
//        let text = "Type a name to add or /cancel to cancel."
//        
//        if context.privateChat {
//            context.respondAsync(text, replyMarkup: ReplyKeyboardRemove())
//        } else {
//            let replyTo = context.message?.messageId
//            var markup = ForceReply()
//            markup.selective = replyTo != nil
//            context.respondAsync(text,
//                replyToMessageId: replyTo,
//                replyMarkup: markup)
//        }
//    }
//}
