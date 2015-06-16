//
//  TransparentModal.swift
//  ReusableModalTest
//
//  Created by Jason Hoffman on 6/13/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit
import Foundation

class TransparentModal: UIView {
    
    static var button: UIButton!
    static var label: UILabel!
    static let modal = TransparentModal()
    
    class func modalInView(view: UIView, forSelectionOrPlacement: String) -> TransparentModal {
        let f = CGRectMake(0, view.bounds.size.height, view.bounds.size.width, view.bounds.size.height)
        println("modal created")
        modal.frame = f
        modal.alpha = 0.7
        modal.backgroundColor = UIColor.darkGrayColor()
        
        button = UIButton(frame: CGRectMake(0, 0, 116, 50))
        button.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 1.6)
        button.backgroundColor = UIColor.lightGrayColor()
        button.layer.cornerRadius = 4
        button.setTitle("Ok", forState: UIControlState.Normal)
        button.addTarget(self, action:"dismiss:", forControlEvents: UIControlEvents.TouchUpInside)
        modal.addSubview(button)
        
        self.label = UILabel(frame: CGRectMake(0, 0, 260, 100))
        label.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 3)
        label.numberOfLines = 0
        label.text = ""
        modal.addSubview(label)
        
        if forSelectionOrPlacement == "selection" {
            println("selection")
            label.text = "Select an image using your camera or photo library with the buttons below."
        } else if forSelectionOrPlacement == "placement" {
            println("placement")
            label.text = "Pinch and drag to place your photo, then press done to edit the meme text."
        }

        view.addSubview(modal)
        
        self.animateWithDuration(0.5, animations: { () -> Void in
            self.modal.frame.origin.y -= view.bounds.size.height
        })
        
        return modal
    }
    
    class func dismiss(sender: UIButton) {
        self.animateWithDuration(0.2, animations: { () -> Void in
            self.modal.alpha = 0
        }) { (Bool) -> Void in
            self.modal.removeFromSuperview()
            self.button.removeFromSuperview()
            self.label.removeFromSuperview()
            println("success")
        }
    }
}