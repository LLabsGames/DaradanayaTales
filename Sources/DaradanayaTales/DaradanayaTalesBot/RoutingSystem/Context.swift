//
//  TGContext.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 11.07.2024.
//

import Foundation
import Dispatch
import SwiftTelegramSdk

public class TGContext {
	typealias T = TGContext
		
	public let bot: TGBot
    public let name: TGBotName
	public let update: TGUpdate
    
	/// `update.message` shortcut. Make sure that the message exists before using it,
	/// otherwise it will be empty. For paths supported by Router the message is guaranteed to exist.
	public var message: TGMessage? {
        if let message = update.editedMessage ?? update.message {
            return message
        } else {
            if let message = update.callbackQuery?.message {
                switch message {
                case .message(let message):
                    return message
                case .inaccessibleMessage(_):
                    return nil
                }
            } else {
                return nil
            }
        }
    }

    /// Command starts with slash (useful if you want to skip commands not starting with slash in group chats)
    public let slash: Bool
    public let command: String
    public let args: Arguments

	public var privateChat: Bool {
        guard let message = message else { return false }
        return message.chat.type == .private
    }
	public var chatId: Int64? { return message?.chat.id ??
        update.callbackQuery?.message?.chat.id
    }
	public var fromId: Int64? {
        return update.message?.from?.id ?? (update.editedMessage?.from?.id ?? update.callbackQuery?.from.id)
    }
    public var properties: [String: AnyObject]
	
    init(bot: TGBot, name: TGBotName, update: TGUpdate, scanner: Scanner, command: String, startsWithSlash: Bool, properties: [String: AnyObject] = [:]) {
		self.bot = bot
        self.name = name
		self.update = update
        self.slash = startsWithSlash
        self.command = command
        self.args = Arguments(scanner: scanner)
        self.properties = properties
	}
}

extension TGContext {
    var session: Session { return properties["session"] as! Session }
}
