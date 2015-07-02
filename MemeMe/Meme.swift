//
//  Meme.swift
//  MemeMe
//
//  Created by Jason Hoffman on 5/21/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit

class Meme: NSObject, NSCoding {
    // Meme array persists
    static var ar = [Dictionary<String, String>]()
    
    var t1: String?
    var t2: String?
    var memeName: String?
    var memeImage: UIImage?
    
    override init() {
        super.init()
    }
    
    init(text1: String, text2: String, memeName: String, memeImage: UIImage) {
        t1 = text1
        t2 = text2
        self.memeName = memeName
        self.memeImage = memeImage 
    }
    
    // Core Data to save memes 
    required convenience init(coder decoder: NSCoder) {
        self.init()
        let imageData = decoder.decodeObjectForKey("memeImage") as! NSData
        t1 = decoder.decodeObjectForKey("t1") as? String
        t2 = decoder.decodeObjectForKey("t2")as? String
        memeName = decoder.decodeObjectForKey("memeName") as? String
        memeImage = UIImage(data:imageData)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        let encodedImage: NSData = UIImagePNGRepresentation(self.memeImage)
        coder.encodeObject(self.t1, forKey: "t1")
        coder.encodeObject(self.t2, forKey: "t2")
        coder.encodeObject(self.memeName, forKey: "memeName")
        coder.encodeObject(encodedImage, forKey: "memeImage")
    }
}
