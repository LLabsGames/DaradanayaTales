//
//  MainController.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import Foundation
import SwiftTelegramSdk

class MainController {
    typealias T = MainController

    init(bot: TGBot) {
//        routers["main"] = TGRouter(bot: bot) { router in
//            router[Commands.start] = onStart
//            router[Commands.stop] = onStop
//            // router[Commands.help] = onHelp
//            // router[Commands.add] = onAdd
//            // router[Commands.delete] = onDelete
//            // router[Commands.list] = onList
//            // router[Commands.support] = onSupport
//            // router[.newChatMembers] = onNewChatMember
//            // router[.callback_query(data: nil)] = onCallbackQuery
//        }
    }
    
    func onStart(context: TGContext) async throws -> Bool {
        try await showMainMenu(context: context, text: "Please choose an option.")
        return true
    }
    
    func onStop(context: TGContext) async throws -> Bool {
        guard let rawChatId = context.chatId ?? context.session.id else { return true }
        let chatId = TGChatId.chat(rawChatId)
        let replyTo = context.privateChat ? nil : context.message?.messageId
        let delete = TGReplyKeyboardRemove(removeKeyboard: true, selective: replyTo != nil)
        let markup = TGReplyMarkup.replyKeyboardRemove(delete)
        let reply = replyTo != nil ? TGReplyParameters(messageId: replyTo!) : nil
        let params = TGSendMessageParams(chatId: chatId, text: "Stopping.", replyParameters: reply, replyMarkup: markup)
        try await context.bot.sendMessage(params: params)
        return true
    }

    // func onHelp(context: TGContext) throws -> Bool {
    //     let text = "Usage:\n" +
    //         "/add name - add a new item to list\n" +
    //         "/list - list items\n" +
    //         "/delete - delete purchased items from list\n" +
    //         "/support - join the support group"
    //     try showMainMenu(context: context, text: text)
    //     return true
    // }
    
    // func onAdd(context: TGContext) throws -> Bool {
    //     guard let chatId = context.chatId else { return false }
    //     let name = context.args.scanRestOfString()
    //     if name.isEmpty {
    //         addController.showHelp(context: context)
    //         context.session.routerName = "add"
    //         try context.session.save()
    //     } else {
    //         try Item.add(name: name, chatId: chatId)
    //         context.respondAsync("Added: \(name)")
    //     }
    //     return true
    // }
    
    // func onDelete(context: TGContext) throws -> Bool {
    //     deleteController.showConfirmationKeyboard(context: context, text: "Delete purchased items? /confirm_deletion or /cancel")
    //     context.session.routerName = "delete"
    //     try context.session.save()
    //     return true
    // }
    
    // func onList(context: TGContext) -> Bool {
    //     guard let markup = itemListInlineKeyboardMarkup(context: context) else { return false }
    //     context.respondAsync("Item List:",
    //                          replyMarkup: markup)
    //     return true
    // }

    // func onSupport(context: TGContext) -> Bool {
    //     // Please update support group name to point to your group!
    //     // Don't send people to Zabiyaka Support group.
    //     // Delete this guard condition when this is done.
    //     guard bot.username.lowercased().hasPrefix("shopster") else {
    //         context.respondAsync("Invalid support URL.")
    //         return true
    //     }
    //
    //     var button = InlineKeyboardButton()
    //     button.text = "Join Zabiyaka Support"
    //     button.url = "https://telegram.me/zabiyaka_support"
    //
    //     var markup = InlineKeyboardMarkup()
    //     let keyboard = [[button]]
    //     markup.inlineKeyboard = keyboard
    //
    //     context.respondAsync("Please click the button below to join *Zabiyaka Support* group.", parseMode: "Markdown", replyMarkup: markup)
    //
    //     return true
    // }

    // func onNewChatMember(context: TGContext) -> Bool {
    //     guard let newChatMembers = context.message?.newChatMembers,
    //         newChatMembers.first?.id == bot.user.id else { return false }
    //
    //     context.respondAsync("Hi All. I'll maintain your shared shopping list. Type /start to start working with me.")
    //     return true
    // }
    
    // func onCallbackQuery(context: TGContext) throws -> Bool {
    //     guard let callbackQuery = context.update.callbackQuery else { return false }
    //     guard let chatId = callbackQuery.message?.chat.id else { return false }
    //     guard let messageId = callbackQuery.message?.messageId else { return false }
    //     guard let data = callbackQuery.data else { return false }
    //     let scanner = Scanner(string: data)
    //
    //     // "toggle 1234567"
    //     guard scanner.skipString("toggle") else { return false }
    //     guard let itemId = scanner.scanInt64() else { return false }
    //
    //     guard let item = try Item.item(itemId: itemId, from: chatId) else {
    //         context.respondAsync("This item no longer exists.")
    //         return true
    //     }
    //     item.purchased = !item.purchased
    //     try item.save()
    //
    //     if let markup = itemListInlineKeyboardMarkup(context: context) {
    //         bot.editMessageReplyMarkupAsync(chatId: chatId, messageId: messageId, replyMarkup: markup)
    //     }
    //     return true
    // }
    
    func showMainMenu(context: TGContext, text: String) async throws {
        // Use replies in group chats, otherwise bot won't be able to see the text typed by user.
        // In private chats don't clutter the chat with quoted replies.
        let replyTo = context.privateChat ? nil : context.message?.messageId
        guard let rawChatId = context.chatId ?? context.session.id else { return }
        let chatId = TGChatId.chat(rawChatId)
        
        let keyboard = [[TGKeyboardButton(text: "Add"), 
                         TGKeyboardButton(text: "List"),
                         TGKeyboardButton(text: "Delete")], 
                        [TGKeyboardButton(text: "Help"),
                         TGKeyboardButton(text: "Support")]]
        var replyMarkup = TGReplyKeyboardMarkup(keyboard: keyboard)
        //markup.one_time_keyboard = true
        replyMarkup.resizeKeyboard = true
        replyMarkup.selective = replyTo != nil
        
        let markup = TGReplyMarkup.replyKeyboardMarkup(replyMarkup)
        let reply = replyTo != nil ? TGReplyParameters(messageId: replyTo!) : nil
        
        let params = TGSendMessageParams(chatId: chatId, text: text, replyParameters: reply, replyMarkup: markup)
        try await context.bot.sendMessage(params: params)
    }

    // func itemListInlineKeyboardMarkup(context: TGContext) -> InlineKeyboardMarkup? {
    //     guard let chatId = context.chatId else { return nil }
    //     let items = Item.allItems(in: chatId)
    //     var keyboard = [[InlineKeyboardButton]]()
    //     for item in items {
    //         var button = InlineKeyboardButton()
    //         button.text = "\(item.purchased ? "✅" : "◻️") \(item.name)"
    //         // A hack to left-align the text:
    //         button.text +=
    //             "                                              " +
    //             "                                              " +
    //         "                                              ."
    //         button.callbackData = "toggle \(item.itemId!)"
    //         keyboard.append([button])
    //     }
    //
    //     var markup = InlineKeyboardMarkup()
    //     markup.inlineKeyboard = keyboard
    //     return markup
    // }
}
