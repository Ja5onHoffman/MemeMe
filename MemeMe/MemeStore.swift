//
//  MemeSaver.swift
//  MemeMe
//
//  Created by Jason Hoffman on 5/25/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit

// MemeStore is responsible for creating, deleting and saving memes.
// It's based on a Big Nerd Ranch tutorial I completed about a year ago.
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