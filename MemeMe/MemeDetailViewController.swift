//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Jason Hoffman on 5/22/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var detailImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.detailImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
