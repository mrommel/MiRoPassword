//
//  PasswordItem+CoreDataProperties.swift
//  
//
//  Created by Michael Rommel on 30.12.16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PasswordItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PasswordItem> {
        return NSFetchRequest<PasswordItem>(entityName: "PasswordItem");
    }

    @NSManaged public var hint: String?
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var username: String?

}
