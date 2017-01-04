//
//  PasswordItemManager.swift
//  MiRoPassword
//
//  Created by Michael Rommel on 04.01.17.
//  Copyright © 2017 MiRo Soft. All rights reserved.
//

import Foundation
import CoreData

class PasswordItemManager : NSObject {

    private let managedObjectContext : NSManagedObjectContext
    
    init(managedObjectContext : NSManagedObjectContext)
    {
        self.managedObjectContext = managedObjectContext
        super.init()
    }
    
    func createPasswordItem(withName name: String) -> PasswordItem
    {
        let passwordItem = NSEntityDescription.insertNewObject(forEntityName: PasswordItem.entityName,
                                                       into: self.managedObjectContext) as! PasswordItem
        passwordItem.name = name
        return passwordItem
    }
    
    func getPasswordItems() -> [PasswordItem] {
        let request : NSFetchRequest<PasswordItem> = PasswordItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try! managedObjectContext.fetch(request)
    }
    
}
