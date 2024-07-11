//
//  Arguments.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 11.07.2024.
//

import Foundation

public class Arguments {
	typealias T = Arguments
	
	public let scanner: Scanner
	
	public var isAtEnd: Bool {
		return scanner.isAtEnd
	}

	static let whitespaceAndNewline = CharacterSet.whitespacesAndNewlines
	
	init(scanner: Scanner) {
		self.scanner = scanner
	}
	
	public func scanWord() -> String? {
        return scanner.scanUpToCharacters(from: T.whitespaceAndNewline)
	}
	
	public func scanWords() -> [String] {
		var words = [String]()
		while let word = scanWord() {
			words.append(word)
		}
		return words
	}
	
	public func scanInteger() -> Int? {
		guard let word = scanWord() else {
			return nil
		}
		let validator = Scanner(string: word)
		validator.charactersToBeSkipped = nil
		guard let value = validator.scanInt(), validator.isAtEnd else {
			return nil
		}
		return value
	}
	
    public func scanInt64() -> Int64? {
        guard let word = scanWord() else {
            return nil
        }
        let validator = Scanner(string: word)
        validator.charactersToBeSkipped = nil
        guard let value = validator.scanInt64(), validator.isAtEnd else {
            return nil
        }
        return value
    }
    
	public func scanDouble() -> Double? {
		guard let word = scanWord() else {
			return nil
		}
		let validator = Scanner(string: word)
		validator.charactersToBeSkipped = nil
		guard let value = validator.scanDouble(), validator.isAtEnd else {
			return nil
		}
		return value
	}
	
	public func scanRestOfString() -> String {
		guard let restOfString = scanner.scanUpTo("") else {
			return ""
		}
		return restOfString
	}
	
	public func skipRestOfString() {
		scanner.skipUpTo("")
	}
}
