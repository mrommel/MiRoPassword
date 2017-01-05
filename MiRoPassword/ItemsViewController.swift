//
//  ItemsViewController.swift
//  MiRoPassword
//
//  Created by Michael Rommel on 04.01.17.
//  Copyright © 2017 MiRo Soft. All rights reserved.
//

import Cocoa
import SwiftyDropbox

class ItemsViewController: NSViewController {
    
    var idleTimer: Timer?
    var idleCounter: Int32 = 100
    
    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet weak var statusLabel: NSTextField?
    @IBOutlet weak var idleProgress: NSLevelIndicator?
    @IBOutlet weak var dropboxButton: NSButton?
    @IBOutlet weak var syncButton: NSButton?
    
    var passwordItems: [PasswordItem]? = []
    var passwordItemManager: PasswordItemManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let context = self.appDelegate.managedObjectContext
        self.passwordItemManager = PasswordItemManager.init(managedObjectContext: context)
        
        if let dropboxToken = self.passwordItemManager?.getPasswordItem(withName: PasswordItemManager.dropboxToken) {
            
            DropboxClientsManager.reauthorizeClient(dropboxToken.username!)
            
            // Check if the user is logged in
            // If so, try to load dropbox file
            if let client = DropboxClientsManager.authorizedClient {
                
                self.syncButton?.isEnabled = true
                self.dropboxButton?.title = "Unlink Dropbox"
                
                // List contents of app folder
                _ = client.files.listFolder(path: "").response { response, error in
                    if let result = response {
                        print("Folder contents:")
                        for entry in result.entries {
                            print(entry.name)
                            
                            // Check that file is an encrypted db (by file extension)
                            if entry.name.hasSuffix(".enc") {
                                //self.filenames?.append(entry.name)
                            }
                        }
                    }
                }
            }
        }
        
        self.idleTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(ItemsViewController.updateCounter), userInfo: nil, repeats: true)
        self.idleProgress?.intValue = 100
        
        // test
        print("raw: lorem ipsom")
        let encryptionManager = EncryptionManager.init()
        let txt = encryptionManager.encrypt("lorem ipsom")
        let txt2 = encryptionManager.decrypt(txt)
        print("decrypted: \(txt2)")
        
        self.reloadPasswordList()
    }
    
    func updateCounter() {
        print("updateCounter \(self.idleCounter)")
        
        self.idleCounter -= 1
        self.idleProgress?.intValue = self.idleCounter
        
        if self.idleCounter <= 0 {
            self.closeAction(nil)
        }
    }
    
    func reloadPasswordList() {
        
        self.passwordItems = self.passwordItemManager?.getPasswordItems()
        self.statusLabel?.stringValue = "\((self.passwordItems?.count)!) Items"
        self.tableView?.reloadData()
    }
    
    func resetCounter() {
        self.idleCounter = 100
        self.idleProgress?.intValue = self.idleCounter
    }
    
    @IBAction func doubleClickAction(_ sender: AnyObject?) {
        print("click: ")
        
        self.resetCounter()
    }
    
    @IBAction func syncAction(_ sender: AnyObject?) {
        print("sync: ")
        
        self.resetCounter()
    }
    
    @IBAction func dropboxAction(_ sender: AnyObject?) {
        // Check if the user is logged in
        // If so, try to load dropbox file
        if DropboxClientsManager.authorizedClient != nil {
            
            print("unlink dropbox: ")
            
            self.resetCounter()
            
            DropboxClientsManager.unlinkClients()
            
            let context = self.appDelegate.managedObjectContext
            self.passwordItemManager = PasswordItemManager.init(managedObjectContext: context)
            
            if (self.passwordItemManager?.getPasswordItem(withName: PasswordItemManager.dropboxToken)) != nil {
                self.passwordItemManager?.deletePasswordItem(withName: PasswordItemManager.dropboxToken)
            }
            
        } else {
            print("link dropbox: ")
            
            self.resetCounter()
            
            DropboxClientsManager.authorizeFromController(sharedWorkspace: NSWorkspace.shared(),
                                                          controller: self,
                                                          openURL: { (url: URL) -> Void in
                                                            NSWorkspace.shared().open(url)
            })
        }
    }
    
    @IBAction func addPasswordAction(_ sender: AnyObject?) {
        print("add: ")
        
        self.resetCounter()
        
        _ = self.passwordItemManager?.createPasswordItem(withName: "abc", username: "def", password: "pwd", andHint: "hint")
        
        self.reloadPasswordList()
    }
    
    @IBAction func closeAction(_ sender: AnyObject?) {
        print("close: ")
        
        self.idleTimer?.invalidate()
        self.dismiss(nil)
    }

}

extension ItemsViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.passwordItems?.count ?? 0
    }
}

extension ItemsViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
        //static let DateCell = "DateCellID"
        //static let SizeCell = "SizeCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        
        // 1
        guard let item = self.passwordItems?[row] else {
            return nil
        }
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            image = nil
            text = item.name!
            cellIdentifier = CellIdentifiers.NameCell
        }/* else if tableColumn == tableView.tableColumns[1] {
            text = dateFormatter.string(from: item.date)
            cellIdentifier = CellIdentifiers.DateCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.isFolder ? "--" : sizeFormatter.string(fromByteCount: item.size)
            cellIdentifier = CellIdentifiers.SizeCell
        }*/
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }
}
