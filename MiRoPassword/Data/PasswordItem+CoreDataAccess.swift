//
//  PasswordItem+CoreDataAccess.swift
//  MiRoPassword
//
//  Created by Michael Rommel on 04.01.17.
//  Copyright © 2017 MiRo Soft. All rights reserved.
//

import Foundation

extension PasswordItem {
    
    static let entityName = "PasswordItem"    
    
    func toDict() -> Dictionary<String, AnyObject> {
        return [
            "name": self.name as AnyObject,
            "username": self.username as AnyObject,
            "password": self.password as AnyObject,
            "hint": self.hint as AnyObject,
            "modified": self.modified as AnyObject
        ]
    }
}
