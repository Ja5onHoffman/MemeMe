//
//  TransparentModalViewController.swift
//  MemeMe
//
//  Created by Jason Hoffman on 6/8/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit

class TransparentModalViewController: UIViewController {
    
    @IBOutlet weak var instructionLabel: UILabel!
    static let TransparentModal = TransparentModalViewController()
    var selection = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0.7
        if selection == true {
            self.instructionLabel.text = "Select an image using your camera or photo library with the buttons below."
        } else {
            self.instructionLabel.text = "Pinch and drag to place your photo, then press done to edit the meme text."
        }
    }

    @IBAction func okButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true 
    }
    

}
