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
    var imageForMeme: UIImage!
    var activeField: UITextField?
    var editable = false
    var memeName: String?
    var alertField = UITextField()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabelTop: UITextField!
    @IBOutlet weak var textLabelBottom: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var topNavigationBar: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribeToKeyboardNotifications()
        self.navigationController?.navigationBarHidden = true
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        shareButton.enabled = false
        addCancelButton()
        navBar.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        let memeTextAttributes: Dictionary = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -1.0,
            NSForegroundColorAttributeName: UIColor.whiteColor()
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
        TransparentModal.modalInView(self.view, forSelectionOrPlacement: "selection")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // viewWillAppear is called when orientation changes.
        // Need to configure scrollview here to work in landscape mode.
        self.imageScrollView.minimumZoomScale = 0.5
        self.imageScrollView.maximumZoomScale = 6.0
        self.imageScrollView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // Hide status bar since editor is a modal
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
 
    @IBAction func shareButtonPressed(sender: AnyObject) {
        activeField?.resignFirstResponder()
        var alertController:UIAlertController?
        
        alertController = UIAlertController(title: "Name your Meme.", message: "What do you want to name your meme?", preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                self.alertField.placeholder = "Meme name"
        })
        
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {[weak self]
                (paramAction:UIAlertAction!) in
                if let textFields = alertController?.textFields{
                    let theTextFields = textFields as! [UITextField]
                    theTextFields[0].resignFirstResponder()
                    self!.memeName = theTextFields[0].text
                }
                self?.createMeme()
                self?.showActivityViewController()
            })
        
        alertController?.addAction(action)
        self.presentViewController(alertController!, animated: true, completion:nil)
    }

    func createMeme() -> Meme {
        let newMeme = memeStore.createMeme(textLabelTop.text, text2: textLabelBottom.text, memeName: self.memeName!) { () -> UIImage in
            var space: CGFloat!
            
            space = 44 // Default
            // Place text correctly if device orientation changes
            if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
                space = 44
            } else if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
                space = 32
            }
            
            UIGraphicsBeginImageContextWithOptions(self.imageScrollView.bounds.size, false, 0)
            let ctx = UIGraphicsGetCurrentContext()
            let offset: CGPoint = self.imageScrollView.contentOffset
            CGContextTranslateCTM(ctx, -offset.x, -offset.y)
            self.imageScrollView.layer.renderInContext(ctx)
            CGContextSaveGState(ctx)
            CGContextTranslateCTM(ctx, offset.x + self.textLabelTop.frame.origin.x, offset.y + self.textLabelTop.frame.origin.y - space)
            self.textLabelTop.layer.renderInContext(ctx)
            CGContextRestoreGState(ctx)
            CGContextSaveGState(ctx)
            CGContextTranslateCTM(ctx, offset.x + self.textLabelBottom.frame.origin.x, offset.y + self.textLabelBottom.frame.origin.y - space)
            self.textLabelBottom.layer.renderInContext(ctx)
            CGContextRestoreGState(ctx)
            self.imageForMeme = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return self.imageForMeme
        }
        return newMeme
    }
  
    func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed(sender: AnyObject) {
        self.imageScrollView.scrollEnabled = false
        self.imageScrollView.userInteractionEnabled = false
        self.editable = true
        self.shareButton.enabled = true
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
    
    func showActivityViewController() {
        let completionItems: UIActivityViewControllerCompletionWithItemsHandler = { (activityType: String!, completed: Bool, returnedItems: [AnyObject]!, activityError: NSError!) -> Void in
            println("\(completed)")
            if completed == true {
                let meme = self.createMeme()
                self.memeStore.saveMeme(meme)
                
                // Dismiss editor if meme is shared
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        let activityViewController = UIActivityViewController(activityItems:[self.imageForMeme], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = completionItems
        activityViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageView.image = image
        self.imageScrollView.scrollEnabled = true
        self.dismissViewControllerAnimated(true, completion: nil)
        self.addDoneButton()
        TransparentModal.modalInView(self.view, forSelectionOrPlacement: "placement")
    }
    
    @IBAction func pickImage(sender: UIBarButtonItem) {
        println("\(self.navBar.frame.size.height)")
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
            }
        } else if sender.tag == 201 {
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return editable
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeField = textField
        // Erase placeholder text when editing begins
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
        
        if let active = self.activeField {
            if (!CGRectContainsPoint(aRect, active.frame.origin) ) {
                let scrollPoint:CGPoint = CGPointMake(0.0, activeField!.frame.origin.y - kbSize!.height)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
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


