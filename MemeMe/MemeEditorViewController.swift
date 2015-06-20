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
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: 1.0,
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
 
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let newMeme = memeStore.createMeme(textLabelTop.text, text2: textLabelBottom.text, memeName: "meme1") { () -> UIImage in
            UIGraphicsBeginImageContextWithOptions(self.imageScrollView.bounds.size, false, UIScreen.mainScreen().scale)
            let ctx = UIGraphicsGetCurrentContext()
            let offset: CGPoint = self.imageScrollView.contentOffset
            CGContextTranslateCTM(ctx, -offset.x, -offset.y)
            self.textLabelTop.layer.renderInContext(ctx)
            self.imageScrollView.layer.renderInContext(ctx)
            CGContextConcatCTM(ctx, self.imageScrollView.transform)
            self.textLabelTop.layer.renderInContext(ctx)

            self.imageForMeme = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()
            
            return self.imageForMeme
        }
        memeStore.saveMeme(newMeme)
        self.showActivityViewController()
    }
  
    func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed(sender: AnyObject) {
        println("donebuttonpressed:")
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
        let activityViewController = UIActivityViewController(activityItems:[self.imageForMeme], applicationActivities: nil)
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
        println("\(scrollView)")
        return self.imageView
    }
}


