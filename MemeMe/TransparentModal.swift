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
        modal.alpha = 0.0
        modal.backgroundColor = UIColor.darkGrayColor()
        modal.setTranslatesAutoresizingMaskIntoConstraints(false)
        
//        button = UIButton(frame: CGRectMake(0, 0, 116, 50))
//        button.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 1.6)
//        button.backgroundColor = UIColor.lightGrayColor()
//        button.layer.cornerRadius = 4
//        button.setTitle("Ok", forState: UIControlState.Normal)
//        button.addTarget(self, action:"dismiss:", forControlEvents: UIControlEvents.TouchUpInside)
//        modal.addSubview(button)
        
        
        self.label = UILabel(frame: CGRectMake(0, 0, 260, 100))
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.preferredMaxLayoutWidth = 260
        label.numberOfLines = 0
        label.textColor = UIColor.whiteColor()
        label.text = ""
        modal.addSubview(label)
        
        modal.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: modal, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        modal.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: modal, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        
        let tapGesture = UITapGestureRecognizer(target: modal, action: "callDismiss:")
        self.modal.addGestureRecognizer(tapGesture)
        
        if forSelectionOrPlacement == "selection" {
            println("selection")
            label.text = "Select an image using your camera or photo library with the buttons below."
        } else if forSelectionOrPlacement == "placement" {
            println("placement")
            label.text = "Pinch and drag to place your photo, then press done to edit the meme text."
        }
        
        view.addSubview(modal)
        
        view.addConstraint(NSLayoutConstraint(item: modal, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: modal, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: modal, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: modal, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        
        
        self.animateWithDuration(0.5, animations: { () -> Void in
            self.modal.alpha = 0.7
        })
        
        
        return modal
    }
    
    // For use as selector
    func callDismiss(sender: AnyObject) {
        TransparentModal.dismiss(sender)
    }
    
    class func dismiss(sender: AnyObject) {
        self.animateWithDuration(0.2, animations: { () -> Void in
            self.modal.alpha = 0
        }) { (Bool) -> Void in
            self.modal.removeFromSuperview()
//            self.button.removeFromSuperview()
            self.label.removeFromSuperview()
            println("success")
        }
    }
}