//
//  NSViewController+AppDelegate.swift
//  MiRoPassword
//
//  Created by Michael Rommel on 04.01.17.
//  Copyright © 2017 MiRo Soft. All rights reserved.
//

import Cocoa

extension NSViewController {
    var appDelegate: AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
}
