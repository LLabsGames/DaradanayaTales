//
//  Controllers.swift
//  Orion-Nebula
//
//  Created by Maxim Lanskoy on 12.01.2021.
//

import Foundation

struct Controllers {
    //MARK: - Controllers initialization.
    static let mainController = MainController()
    
    static let all: [Any] = [ mainController ]
    
    static func preLoad() {
        //print("📟 Registration controller preloaded: " + String(describing: registrationController))
        print("📟 Controllers preloaded: " + all.debugDescription)
        //let _ = "\(deathController)"
    }
}
