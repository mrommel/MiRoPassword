//
//  ItemsViewController.swift
//  MiRoPassword
//
//  Created by Michael Rommel on 04.01.17.
//  Copyright © 2017 MiRo Soft. All rights reserved.
//

import Cocoa

class ItemsViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("I'm here")
        
        /*
         let context = self.appDelegate.managedObjectContext
         
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PasswordItem")
         //let itemsFetch = PasswordItem.fetchRequest()
         
         do {
         let fetchedItems = try context.fetch(fetchRequest)
         
         print("results: \(fetchedItems.count)")
         } catch {
         fatalError("Failed to fetch employees: \(error)")
         }*/
    }
    
    @IBAction func closeAction(_ sender: AnyObject?) {
        print("close: ")
        
        self.dismiss(nil)
    }

}
