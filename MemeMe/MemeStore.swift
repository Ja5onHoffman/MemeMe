//
//  MemeSaver.swift
//  MemeMe
//
//  Created by Jason Hoffman on 5/25/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit

class MemeStore: NSObject {
    
    var memeArray = [Meme]()
    static let sharedStore = MemeStore()
    
    override init() {
        super.init()
        let path = self.documentsDirectory()
        if let ar = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [Meme] {
            self.memeArray = ar
        }
    }
    
//    func generateMemeImage() -> UIImage {
//        UIGraphicsBeginImageContext(self.view.frame.size)
//        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
//        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return memedImage
//    }
    
    func createMeme(text1: String, text2: String, memeName: String, memeImage: () -> UIImage) -> Meme {
        let meme = Meme(text1: text1, text2: text2, memeName: memeName, memeImage: memeImage())
        println("\(text1), \(text2), \(memeName), \(memeImage)")
        return meme
    }
    
    func allMemes() -> [Meme] {
        return self.memeArray
    }
    
    func documentsDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!.stringByAppendingPathComponent("memes.db") as String
        
        return documentsFolderPath
    }
    
    func saveMeme(meme: Meme) {
        let path = documentsDirectory()
        self.memeArray.append(meme)
        NSKeyedArchiver.archiveRootObject(self.memeArray, toFile: path)
    }
    
    func deleteMeme(atIndex index: Int) {
        self.memeArray.removeAtIndex(index)
    }
}