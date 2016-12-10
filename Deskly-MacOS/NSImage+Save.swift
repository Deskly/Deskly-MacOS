//
//  NSImage+Save.swift
//  Deskly-MacOS
//
//  Created by Keith Toh on 10/12/16.
//  Copyright © 2016 Kaioru. All rights reserved.
//

import Cocoa

extension NSImage {
    var imagePNGRepresentation: Data {
        return NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .PNG, properties: [:])!
    }
    func savePNG(path: URL) throws {
        try imagePNGRepresentation.write(to: path)
    }
}
