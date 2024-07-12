//
//  TGRouter+Helpers.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 11.07.2024.
//

import Foundation

extension TGRouter {
	// add() taking string
	
	public func add(_ commandString: String, _ options: Command.Options = [], _ handler: @escaping (TGContext) throws -> Bool) {
		add(Command(commandString, options: options), handler)
	}
		
	// Subscripts taking ContentType
	
	public subscript(_ contentType: ContentType) -> (TGContext) throws->Bool {
		get { fatalError("Not implemented") }
		set { add(contentType, newValue) }
	}
	
	// Subscripts taking Command
	
	public subscript(_ command: Command) -> (TGContext) throws->Bool {
		get { fatalError("Not implemented") }
		set { add(command, newValue) }
	}

    public subscript(_ commands: [Command]) -> (TGContext) throws->Bool {
        get { fatalError("Not implemented") }
        set { add(commands, newValue) }
    }
    
    public subscript(_ commands: Command...) -> (TGContext) throws->Bool {
        get { fatalError("Not implemented") }
        set { add(commands, newValue) }
    }
    
	// Subscripts taking String

	public subscript(_ commandString: String, _ options: Command.Options) -> (TGContext) throws -> Bool {
		get { fatalError("Not implemented") }
        set { add(Command(commandString, options: options), newValue) }
	}
    
    public subscript(_ commandString: String) -> (TGContext) throws -> Bool {
        get { fatalError("Not implemented") }
        set { add(Command(commandString), newValue) }
    }

    public subscript(_ commandStrings: [String], _ options: Command.Options) -> (TGContext) throws -> Bool {
        get { fatalError("Not implemented") }
        set {
            let commands = commandStrings.map { Command($0, options: options) }
            add(commands, newValue)
        }
    }
    
    public subscript(commandStrings: [String]) -> (TGContext) throws -> Bool {
        get { fatalError("Not implemented") }
        set {
            let commands = commandStrings.map { Command($0) }
            add(commands, newValue)
        }
    }

// Segmentation fault
//    public subscript(commandStrings: String..., _ options: Command.Options) -> (TGContext) throws -> Bool {
//        get { fatalError("Not implemented") }
//        set {
//            let commands = commandStrings.map { Command($0, options: options) }
//            add(commands, newValue)
//        }
//    }

    public subscript(commandStrings: String...) -> (TGContext) throws -> Bool {
        get { fatalError("Not implemented") }
        set {
            let commands = commandStrings.map { Command($0) }
            add(commands, newValue)
        }
    }
}
