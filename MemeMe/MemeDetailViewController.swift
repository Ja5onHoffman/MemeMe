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
        imageView.image = detailImage
    }
}
