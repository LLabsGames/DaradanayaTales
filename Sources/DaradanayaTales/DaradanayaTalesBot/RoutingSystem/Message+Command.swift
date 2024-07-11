//
//  TGMessage+Command.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 11.07.2024.
//

import Foundation
import SwiftTelegramSdk

extension TGMessage {
    public func extractCommand(for bot: TGBotName) -> String? {
        return text?.without(botName: bot) ?? nil
    }
    
    public func addressed(to bot: TGBotName) -> Bool {
        guard let text = text else { return true }
        return text.without(botName: bot) != nil
    }
}

extension String {
    /// - Parameter botName: bot name to remove.
    /// - Returns: "/command@botName arguments" -> "/command arguments". Nil if bot name does not match `botName` parameter.
    public func without(botName: TGBotName) -> String? {
        let scanner = Scanner(string: self)
        scanner.caseSensitive = false
        scanner.charactersToBeSkipped = nil
        
        let whitespaceAndNewline = CharacterSet.whitespacesAndNewlines
        scanner.skipCharacters(from: whitespaceAndNewline)

        guard scanner.skipString("/") else {
            return self
        }
        
        let alphanumericCharacters = CharacterSet.alphanumerics
        guard scanner.skipCharacters(from: alphanumericCharacters) else {
            return self
        }

        let usernameSeparatorIndex = scanner.scanLocation

        let usernameSeparator = "@"
        guard scanner.skipString(usernameSeparator) else {
            return self
        }

        // A set of characters allowed in bot names
        let usernameCharacters = CharacterSet(charactersIn:
            "abcdefghijklmnopqrstuvwxyz" +
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
            "1234567890_")
        guard let username = scanner.scanCharacters(from: usernameCharacters) else {
            // Empty bot name. Treat as no bot name and process the comamnd.
            return self
        }
        
        guard TGBotName(name: username) == botName else {
            // Another bot's message, skip it.
            return nil
        }
        
        let t = NSString(string: self)
        return t.substring(to: usernameSeparatorIndex) +
            t.substring(from: scanner.scanLocation)
    }
}

extension TGBotName: Equatable {
}

public func ==(lhs: TGBotName, rhs: TGBotName) -> Bool {
    return lhs.name == rhs.name
}

extension TGBotName: Comparable {
}

public func <(lhs: TGBotName, rhs: TGBotName) -> Bool {
    return lhs.name < rhs.name
}

extension String {
    public func hasPrefix(_ prefix: String, caseInsensitive: Bool) -> Bool {
        if caseInsensitive {
            return nil != self.range(of: prefix, options: [.caseInsensitive, .anchored])
        }
        return hasPrefix(prefix)
    }
}
