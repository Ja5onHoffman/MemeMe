//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Jason Hoffman on 5/22/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

import UIKit
import QuartzCore 

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    let memeStore = MemeStore.sharedStore
    let imagePicker = UIImagePickerController()
    var imageForMeme: UIImage?
    var activeField: UITextField?
    var editable = false
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabelTop: UITextField!
    @IBOutlet weak var textLabelBottom: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var topNavigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribeToKeyboardNotifications()
        self.navigationController?.navigationBarHidden = true
        self.shareButton.enabled = false
        self.addCancelButton()
        
        let memeTextAttributes: Dictionary = [
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSStrokeColorAttributeName: UIColor.redColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: 5.0
        ]
        
        self.imagePicker.delegate = self

        self.textLabelTop.delegate = self
        self.textLabelBottom.delegate = self
        self.textLabelTop.defaultTextAttributes = memeTextAttributes
        self.textLabelTop.textAlignment = .Center
        self.textLabelBottom.defaultTextAttributes = memeTextAttributes
        self.textLabelBottom.textAlignment = .Center
        self.textLabelTop.text = "TOP"
        self.textLabelBottom.text = "BOTTOM"
        
        let modal = self.storyboard!.instantiateViewControllerWithIdentifier("TransparentModal") as! TransparentModalViewController
        // iOS 8 only 
        modal.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.presentViewController(modal, animated: true, completion: nil)
        modal.selection = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // viewWillAppear is called when orientation changes.
        // Need to configure scrollview here to work in landscape mode.
        self.imageScrollView.minimumZoomScale = 0.5
        self.imageScrollView.maximumZoomScale = 6.0
        self.imageScrollView.contentSize = self.imageView.bounds.size
        self.imageScrollView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
 
    @IBAction func shareButtonPressed(sender: AnyObject) {
        var memedImage: UIImage!

        let newMeme = memeStore.createMeme(textLabelTop.text, text2: textLabelBottom.text, memeName: "meme1") { () -> UIImage in
            self.imageView.addSubview(self.textLabelTop)
            self.imageView.addSubview(self.textLabelBottom)
            UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, false, 0.0)
            let ctx = UIGraphicsGetCurrentContext()
            self.imageView.layer.renderInContext(ctx)
            
            /*
            /  My original attempt to add the text fields to the image view
            /  had to do with translating the points from the view to the
            /  context. I was getting close, but discovered that adding the
            /  text fields to imageView as subviews also works. Is this a hack?
            /
            let point1 = self.textLabelTop.superview!.convertPoint(self.textLabelTop.frame.origin, toView: self.imageView)
            CGContextTranslateCTM(ctx, point1.x, point1.y)
            self.textLabelTop.layer.renderInContext(ctx)
            let point2 = self.textLabelBottom.superview!.convertPoint(self.textLabelBottom.frame.origin, toView: self.imageView)
            CGContextTranslateCTM(ctx, point2.x, point2.y)
            self.textLabelBottom.layer.renderInContext(ctx)
            println("point1: \(point1)\npoint2: \(point2)\ntop superview: \(self.textLabelTop.superview!)\nbottom superview \(self.textLabelBottom.superview!)")
            */
            
            memedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return memedImage
        }
        memeStore.saveMeme(newMeme)
        
        let activities = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToFlickr, UIActivityTypeSaveToCameraRoll, UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypeAssignToContact, UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard]
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
  
    func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed(sender: AnyObject) {
        self.imageScrollView.scrollEnabled = false
        self.editable = true
        self.addCancelButton()
    }
    
    func addCancelButton() {
        // Clear current UIBarButtonItem
        self.topNavigationBar.rightBarButtonItem = nil
        self.topNavigationBar.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonPressed:")
    
    }
    
    func addDoneButton() {
        // Clear current UIBarButtonItem
        self.topNavigationBar.rightBarButtonItem = nil
        self.topNavigationBar.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneButtonPressed:")
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageView.image = image
        self.shareButton.enabled = true 
        self.dismissViewControllerAnimated(true, completion: nil)
        self.addDoneButton()
        self.presentInstructions()
    }
    
    @IBAction func pickImage(sender: UIBarButtonItem) {
        if sender.tag == 200 {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                imagePicker.sourceType = .Camera
                imagePicker.showsCameraControls = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "No camera?", message: "Your camera doesn't seem to be available.", preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(alertAction)
                self.presentViewController(alertController, animated: true, completion:nil)
                
                // TODO: Get rid of alert before presenting imagePicker
                
            }
        } else if sender.tag == 201 {
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func presentInstructions() {
        let modal = self.storyboard!.instantiateViewControllerWithIdentifier("TransparentModal") as! TransparentModalViewController
        self.presentViewController(modal, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return editable
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeField = textField 
        textField.text = ""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Keyboard Notifications
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo as NSDictionary!
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize!.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = view.frame
        aRect.size.height -= kbSize!.height
        
        if (!CGRectContainsPoint(aRect, self.activeField!.frame.origin) ) {
            let scrollPoint:CGPoint = CGPointMake(0.0, activeField!.frame.origin.y - kbSize!.height)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets:UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}


