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
    
    static let dropboxToken = "dropboxToken"
    
    init(managedObjectContext : NSManagedObjectContext)
    {
        self.managedObjectContext = managedObjectContext
        super.init()
    }
    
    func currentTimeMillis() -> Int64{
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble * 1000)
    }
    
    func createPasswordItem(withName name: String, username: String, password: String, andHint hint: String) -> PasswordItem
    {
        let passwordItem = NSEntityDescription.insertNewObject(forEntityName: PasswordItem.entityName,
                                                       into: self.managedObjectContext) as! PasswordItem
        passwordItem.name = name
        passwordItem.username = username
        passwordItem.password = password
        passwordItem.hint = hint
        passwordItem.modified = currentTimeMillis()
        
        do {
            if self.managedObjectContext.hasChanges {
                try self.managedObjectContext.save()
            }
        } catch {
            let nserror = error as NSError
            print("could not save new password item: \(name)")
            print("  error: \(nserror)")
        }
        
        return passwordItem
    }
    
    func getPasswordItem(withName name: String) -> PasswordItem? {
        
        let passwordItems = self.getPasswordItems()
        let filteredArray = passwordItems.filter( { (passwordItem: PasswordItem) -> Bool in
            return passwordItem.name == PasswordItemManager.dropboxToken
        })
        
        if filteredArray.count == 1 {
            return filteredArray[0]
        }
        
        return nil
    }
    
    func getPasswordItems() -> [PasswordItem] {
        let request : NSFetchRequest<PasswordItem> = PasswordItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try! managedObjectContext.fetch(request)
    }
    
    func getPasswordItemsDict() -> Dictionary<String, AnyObject> {
    
        var dict: Dictionary<String, AnyObject> = [:]
        var itemArr = [Dictionary<String, AnyObject>]()
        
        for passwordItem in self.getPasswordItems() {
            itemArr.append(passwordItem.toDict())
        }
        
        dict["items"] = itemArr as AnyObject?
    
        return dict
    }
    
    func deletePasswordItem(withName name: String) {
        if let passwordItem = self.getPasswordItem(withName: name) {
            self.managedObjectContext.delete(passwordItem)
            
            do {
                try self.managedObjectContext.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }
}
