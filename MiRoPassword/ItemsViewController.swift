//
//  ItemsViewController.swift
//  MiRoPassword
//
//  Created by Michael Rommel on 04.01.17.
//  Copyright © 2017 MiRo Soft. All rights reserved.
//

import Cocoa
import SwiftyDropbox
import SwiftyJSON

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
            if DropboxClientsManager.authorizedClient != nil {
                self.syncButton?.isEnabled = true
                self.dropboxButton?.title = "Unlink Dropbox"
            }
        }
        
        self.idleTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(ItemsViewController.updateCounter), userInfo: nil, repeats: true)
        self.idleProgress?.intValue = 100
        
        // test
        /*print("raw: lorem ipsom")
        let encryptionManager = EncryptionManager.init()
        let txt = encryptionManager.encrypt("lorem ipsom")
        let txt2 = encryptionManager.decrypt(txt)
        print("decrypted: \(txt2)")*/
        
        self.reloadPasswordList()
    }
    
    func updateCounter() {

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
        
        self.downloadFromDropbox()
    }
    
    func downloadFromDropbox() {
        
        if let dropboxToken = self.passwordItemManager?.getPasswordItem(withName: PasswordItemManager.dropboxToken) {
            
            DropboxClientsManager.reauthorizeClient(dropboxToken.username!)
            
            // Check if the user is logged in
            // If so, try to load dropbox file
            if let client = DropboxClientsManager.authorizedClient {
                
                // Download to Data
                client.files.download(path: "/db.json.enc").response { response, error in
                        if let response = response {
                            
                            let fileContents = response.1
                            //print(fileContents.bytes)
                            
                            let encryptionManager = EncryptionManager.init()
                            let fileContent = encryptionManager.decrypt(fileContents.bytes.toRawString())
                            print("content from backend: #\(fileContent)#")
                            
                            // parse data from backend
                            //var finalJSON = JSON(data: encodedString!)
                            if var data = fileContent.data(using: String.Encoding.utf8) {
                                
                                data.removeLast(8)

                                let jsonObject = JSON(data: data)
                                print("worked +\(jsonObject)+")
                            }
                            
                            // merge
                            
                            self.uploadToDropbox()
                            
                            
                        } else if let error = error {
                            //print(error)
                            
                            // create the file
                        }
                    }
                    .progress { progressData in
                        //print(progressData)
                    }
            }
        }
    }
    
    func uploadToDropbox() {
        
        let dropboxObject = JSON(self.passwordItemManager?.getPasswordItemsDict() as Any)
        let dropboxString = dropboxObject.rawString()!
        
        // encrypt
        let encryptionManager = EncryptionManager.init()
        let encryptedString = encryptionManager.encrypt(dropboxString)
        let encryptedFileData = encryptedString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        
        if let client = DropboxClientsManager.authorizedClient {
        
        _ = client.files.upload(path: "/db.json.enc", mode: Files.WriteMode.overwrite, input: encryptedFileData)
            .response { response, error in
                if response != nil {
                    print("success upload")
                    
                    // show success
                } else if let error = error {
                    print(error)
                    
                    // show error
                }
            }
            .progress { progressData in
                //print(progressData)
            }
        }
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
