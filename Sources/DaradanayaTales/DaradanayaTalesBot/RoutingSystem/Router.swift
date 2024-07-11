//
//  TGRouter.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 11.07.2024.
//

import Foundation
import SwiftTelegramSdk

public class TGRouter {
	public typealias Handler = (_ context: TGContext) throws -> Bool
	public typealias Path = (contentType: ContentType, handler: Handler)
	
    public var caseSensitive = false
    public var charactersToBeSkipped: CharacterSet? = CharacterSet.whitespacesAndNewlines

    var bot: TGBot

	public lazy var partialMatch: Handler? = { context in
		//TODO: - FIX ME!
        //context.respondAsync("❗ Part of your input was ignored: \(context.args.scanRestOfString())")
        context.bot.log.error("❗ Part of your input was ignored: \(context.args.scanRestOfString())")
		return true
	}
	
	public lazy var unmatched: Handler? = { context in
        //TODO: - FIX ME!
        guard context.privateChat else { return false }
        guard let command = context.args.scanWord() else { return false }
		//context.respondAsync("Unrecognized command: \(command). Type /help for help.")
        context.bot.log.error("Unrecognized command: \(command). Type /help for help.")
		return true
	}

	public lazy var unsupportedContentType: Handler? = { context in
        //TODO: - FIX ME!
        guard context.privateChat else { return false }
        if !context.args.isAtEnd {
            //context.respondAsync("Unsupported action.")
            context.bot.log.error("Unsupported action.")
        } else {
            //context.respondAsync("Unsupported content type.")
            context.bot.log.error("Unsupported content type.")
        }
		return true
	}
    
    public var handler: Handler {
        return { [weak self] context in
            try self?.process(update: context.update, botName: context.name)
            return true
        }
    }

    init(bot: TGBot) {
        self.bot = bot
    }
    
    convenience init(bot: TGBot, setup: (_ router: TGRouter)->()) {
        self.init(bot: bot)
        setup(self)
    }
	
	public func add(_ contentType: ContentType, _ handler: @escaping (TGContext) throws -> Bool) {
		paths.append(Path(contentType, handler))
	}
	
	public func add(_ command: Command, _ handler: @escaping (TGContext) throws -> Bool) {
		paths.append(Path(.command(command), handler))
	}

    public func add(_ commands: [Command], _ handler: @escaping (TGContext) throws -> Bool) {
        paths.append(Path(.commands(commands), handler))
    }
    
	@discardableResult
    public func process(update: TGUpdate, botName: TGBotName, properties: [String: AnyObject] = [:]) throws -> Bool {
		let string = update.message?.extractCommand(for: botName) ?? ""
        let scanner = Scanner(string: string)
        scanner.caseSensitive = caseSensitive
        scanner.charactersToBeSkipped = charactersToBeSkipped
		let originalScanLocation = scanner.currentIndex
		
		for path in paths {
			var command = ""
            var startsWithSlash = false
            if !match(contentType: path.contentType, update: update, commandScanner: scanner, userCommand: &command, startsWithSlash: &startsWithSlash) {
				scanner.currentIndex = originalScanLocation
				continue;
			}
			
            let context = TGContext(bot: bot, name: botName, update: update, scanner: scanner, command: command, startsWithSlash: startsWithSlash, properties: properties)
			let handler = path.handler

			if try handler(context) {
				try checkPartialMatch(context: context)
                return true
			}

			scanner.currentIndex = originalScanLocation
		}

		if update.message != nil && !string.isEmpty {
			if let unmatched = unmatched {
                let context = TGContext(bot: bot, name: botName, update: update, scanner: scanner, command: "", startsWithSlash: false, properties: properties)
				return try unmatched(context)
			}
		} else {
			if let unsupportedContentType = unsupportedContentType {
                let context = TGContext(bot: bot, name: botName, update: update, scanner: scanner, command: "", startsWithSlash: false, properties: properties)
				return try unsupportedContentType(context)
			}
		}
		
		return false
    }
	
    func match(contentType: ContentType, update: TGUpdate, commandScanner: Scanner, userCommand: inout String, startsWithSlash: inout Bool) -> Bool {
		if let message = update.message {
            switch contentType {
            case .command(let command):
                guard let result = command.fetchFrom(commandScanner, caseSensitive: caseSensitive) else {
                    return false // Does not match path command
                }
                userCommand = result.command
                startsWithSlash = result.startsWithSlash
                return true
            case .commands(let commands):
                let originalScanLocation = commandScanner.currentIndex
                for command in commands {
                    guard let result = command.fetchFrom(commandScanner, caseSensitive: caseSensitive) else {
                        commandScanner.currentIndex = originalScanLocation
                        continue
                    }
                    userCommand = result.command
                    startsWithSlash = result.startsWithSlash
                    return true
                }
                return false
            case .from: return message.from != nil
            case .forwardFrom: return if case .messageOriginUser = message.forwardOrigin { true } else { false }
            case .forwardFromChat: return if case .messageOriginChat = message.forwardOrigin { true } else { false }
            //TODO: - case .forwardDate: return message.forwardDate != nil
            case .replyToMessage: return message.replyToMessage != nil
            case .editDate: return message.editDate != nil
            case .text: return message.text != nil
            case .entities: return !(message.entities?.isEmpty ?? true)
            case .audio: return message.audio != nil
            case .document: return message.document != nil
            case .photo: return !(message.photo?.isEmpty ?? true)
            case .sticker: return message.sticker != nil
            case .video: return message.video != nil
            case .voice: return message.voice != nil
            case .caption: return message.caption != nil
            case .contact: return message.contact != nil
            case .location: return message.location != nil
            case .venue: return message.venue != nil
            case .newChatMembers: return (message.newChatMembers?.count ?? 0) > 0
            case .leftChatMember: return message.leftChatMember != nil
            case .newChatTitle: return message.newChatTitle != nil
            case .newChatPhoto: return !(message.newChatPhoto?.isEmpty ?? true)
            case .deleteChatPhoto: return message.deleteChatPhoto ?? false
            case .groupChatCreated: return message.groupChatCreated ?? false
            case .supergroupChatCreated: return message.supergroupChatCreated ?? false
            case .channelChatCreated: return message.channelChatCreated ?? false
            case .migrateToChatId: return message.migrateToChatId != nil
            case .migrateFromChatId: return message.migrateFromChatId != nil
            case .pinnedMessage: return message.pinnedMessage != nil
            default: break
            }
        } else if let message = update.editedMessage {
            switch contentType {
            case .editedFrom: return message.from != nil
            case .editedForwardFrom: return if case .messageOriginUser = message.forwardOrigin { true } else { false }
            case .editedForwardFromChat: return if case .messageOriginChat = message.forwardOrigin { true } else { false }
            //TODO: - case .editedForwardDate: return message.forwardDate != nil
            case .editedReplyToMessage: return message.replyToMessage != nil
            case .editedEditDate: return message.editDate != nil
            case .editedText: return message.text != nil
            case .editedEntities: return !(message.entities?.isEmpty ?? true)
            case .editedAudio: return message.audio != nil
            case .editedDocument: return message.document != nil
            case .editedPhoto: return !(message.photo?.isEmpty ?? true)
            case .editedSticker: return message.sticker != nil
            case .editedVideo: return message.video != nil
            case .editedVoice: return message.voice != nil
            case .editedCaption: return message.caption != nil
            case .editedContact: return message.contact != nil
            case .editedLocation: return message.location != nil
            case .editedVenue: return message.venue != nil
            default: break
            }
        } else {
            switch contentType {
            case .callback_query(let data):
                if let data = data {
                    return update.callbackQuery?.data == data
                }
                return update.callbackQuery != nil
            default: break
            }
        }
        return false
	}
	
	// After processing the command, check that no unprocessed text is left
    @discardableResult
	func checkPartialMatch(context: TGContext) throws -> Bool {

		// Note that scanner.atEnd automatically ignores charactersToBeSkipped
		if !context.args.isAtEnd {
			// Partial match
			if let handler = partialMatch {
				return try handler(context)
			}
		}
		
		return true
	}
	
	var paths = [Path]()
}
