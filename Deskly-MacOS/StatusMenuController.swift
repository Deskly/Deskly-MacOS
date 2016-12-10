//
//  StatusMenuController.swift
//  Deskly-MacOS
//
//  Created by Keith Toh on 9/12/16.
//  Copyright © 2016 Kaioru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class StatusMenuController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var generateMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func generateClicked(_ sender: NSMenuItem) {
        let notification = NSUserNotification()
        notification.title = "Deskly"
        notification.subtitle = "Searching for Desktop Image on Reddit.."
        notification.soundName = NSUserNotificationDefaultSoundName
        let center = NSUserNotificationCenter.default
        center.deliver(notification)
        attemptGenerateDesktopPicture(attempts: 0, maxAttempts: 5)
    }
    
    @IBAction func copyClicked(_ sender: Any) {
        let workspace = NSWorkspace.shared()
        NSPasteboard.general().setString((workspace.desktopImageURL(for: NSScreen.main()!)?.absoluteString)!, forType: NSStringPboardType)
    }
    
    func attemptGenerateDesktopPicture(attempts: Int, maxAttempts: Int) {
        generateMenuItem.isEnabled = false
        
        if (attempts < maxAttempts) {
            print("Attempt #\(attempts + 1)/\(maxAttempts) to generate wallpaper from /r/earthporn")
            Alamofire.request("https://www.reddit.com/r/earthporn/.json?sort=hot&limit=50").responseJSON { response in switch response.result {
            case .success(let data):
                let json = JSON(data)
                let posts = json["data"]["children"]
                let post = posts[Int(arc4random_uniform(UInt32(posts.count)))]["data"]
                
                let id = post["id"]
                let url = post["url"]
                let hint = post["post_hint"]
                if url != JSON.null && hint == "image" {
                    if let image = NSImage(contentsOf: URL(string: url.stringValue)!) {
                        let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
                        let path = downloads.appendingPathComponent("\(id).png")
                        do {
                            try image.savePNG(path: path)
                            do {
                                let workspace = NSWorkspace.shared()
                                if let screen = NSScreen.main() {
                                    try workspace.setDesktopImageURL(path, for: screen, options: [:])
                                    let notification = NSUserNotification()
                                    notification.title = "Deskly"
                                    notification.contentImage = image
                                    notification.subtitle = "Enjoy your new desktop image from /r/earthporn!"
                                    notification.soundName = NSUserNotificationDefaultSoundName
                                    let center = NSUserNotificationCenter.default
                                    center.deliver(notification)
                                    self.generateMenuItem.isEnabled = true
                                } else {
                                    self.attemptGenerateDesktopPicture(attempts: attempts + 1, maxAttempts: maxAttempts)
                                }
                            } catch {
                                print("Failed to set desktop image")
                                self.attemptGenerateDesktopPicture(attempts: attempts + 1, maxAttempts: maxAttempts)
                            }
                        } catch {
                            print("Failed to save image to \(path.absoluteString)")
                            self.attemptGenerateDesktopPicture(attempts: attempts + 1, maxAttempts: maxAttempts)
                        }
                    } else {
                        print("Failed to get image from \(url.stringValue)")
                        self.attemptGenerateDesktopPicture(attempts: attempts + 1, maxAttempts: maxAttempts)
                    }
                } else {
                    print("Failed to use '\(url)' ('\(hint)') skipping..")
                    self.attemptGenerateDesktopPicture(attempts: attempts + 1, maxAttempts: maxAttempts)
                }
                break
            default: break
                }
            }
        } else {
            generateMenuItem.isEnabled = true
        }
    }
    
}
