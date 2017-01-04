//
//  ItemsViewController.swift
//  MiRoPassword
//
//  Created by Michael Rommel on 04.01.17.
//  Copyright © 2017 MiRo Soft. All rights reserved.
//

import Cocoa

class ItemsViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet weak var statusLabel: NSTextField?
    
    var passwordItems: [PasswordItem]? = []
    var passwordItemManager: PasswordItemManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let context = self.appDelegate.managedObjectContext
        self.passwordItemManager = PasswordItemManager.init(managedObjectContext: context)
        
        self.reloadPasswordList()
    }
    
    func reloadPasswordList() {
        
        self.passwordItems = self.passwordItemManager?.getPasswordItems()
        self.statusLabel?.stringValue = "\((self.passwordItems?.count)!) Items"
        self.tableView?.reloadData()
    }
    
    @IBAction func addPasswordAction(_ sender: AnyObject?) {
        print("add: ")
        
        self.passwordItemManager?.createPasswordItem(withName: "abc")
        
        self.reloadPasswordList()
    }
    
    @IBAction func closeAction(_ sender: AnyObject?) {
        print("close: ")
        
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
