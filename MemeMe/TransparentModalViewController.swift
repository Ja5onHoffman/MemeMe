//
//  TransparentModalViewController.swift
//  MemeMe
//
//  Created by Jason Hoffman on 6/8/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit

class TransparentModalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func okButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
