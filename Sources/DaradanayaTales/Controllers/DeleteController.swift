//
//  DeleteController.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

//import Foundation
//import SwiftTelegramSdk
//
//class DeleteController {
//    typealias T = DeleteController
//    
//    init(bot: TGBot) {
//        routers["delete"] = TGRouter(bot: bot) { router in
//            router[Commands.help] = onHelp
//            router[Commands.cancel] = onCancel
//            router[Commands.confirmDeletion] = onConfirmDeletion
//            router.unmatched = onCancel // safe default
//        }
//    }
//    
//    func onHelp(context: TGContext) -> Bool {
//        let text = "/confirm_deletion Confirm deletion\n" +
//            "/cancel Cancel"
//        showConfirmationKeyboard(context: context, text: text)
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
//    func onConfirmDeletion(context: TGContext) throws -> Bool {
//        guard let chatId = context.chatId else { return false }
//        try Item.deletePurchased(in: chatId)
//        try mainController.showMainMenu(context: context, text: "Purchased items were deleted.")
//        context.session.routerName = "main"
//        try context.session.save()
//        return true
//    }
//    
//    func showConfirmationKeyboard(context: TGContext, text: String) {
//        let replyTo = context.privateChat ? nil : context.message?.messageId
//        let cancel = TGKeyboardButton(text: Commands.cancel[0])
//        let confirm = TGKeyboardButton(text: Commands.confirmDeletion[0])
//        var markup = TGReplyKeyboardMarkup(keyboard: [[cancel, confirm]])
//        //markup.one_time_keyboard = true
//        markup.resizeKeyboard = true
//        markup.selective = replyTo != nil
//        context.respondAsync(text,
//                             replyToMessageId: replyTo,
//                             replyMarkup: markup)
//    }
//}
