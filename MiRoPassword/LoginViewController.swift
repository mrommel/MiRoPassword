//
//  ViewController.swift
//  MiRoPassword
//
//  Created by Michael Rommel on 30.12.16.
//  Copyright © 2016 MiRo Soft. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {

    @IBOutlet weak var loginTextField: NSTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginAction(_ sender: AnyObject?) {
        print("login: \((self.loginTextField?.stringValue)!)")
        
        self.appDelegate.dbPassword = (self.loginTextField?.stringValue)!
        self.loginTextField?.stringValue = ""
        
        do {
            _ = try self.appDelegate.verifyPassword()
            
            print("great")
            
            self.presentItemsViewController()
        } catch {
            print("wrong")
        }
    }

}

