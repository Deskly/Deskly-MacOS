//
//  AppDelegate.swift
//  Deskly
//
//  Copyright © 2017 Deskly. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Make a status bar that has variable length (as opposed to being a standard square size)
        // -1 to indicate "variable length"
        self.statusItem = NSStatusBar.system().statusItem(withLength: -1)
        
        // Set the text that appears in the menu bar
        self.statusItem!.title = "Deskly"
        // image should be set as tempate so that it changes when the user sets the menu bar to a dark theme
        self.statusItem?.image?.isTemplate = true
        
        // Set the menu that should appear when the item is clicked
        self.statusItem!.menu = self.menu
        
        // Set if the item should change color when clicked
        self.statusItem!.highlightMode = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

