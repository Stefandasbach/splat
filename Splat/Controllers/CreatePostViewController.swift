//
//  createPostViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/14/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Photos
import Parse

//this is Gloabal to prevent gc problems on upload
var savingPost:Post!

class CreatePostViewController: ResponsiveTextFieldViewController, UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, cameraViewDelegate {
    //constants
    let headerSize:CGFloat = 50
    
    var imageView: UIImageView!
    var imageLabel: UILabel!
    var imageViewButton: UIButton!
    
    var commentBox: CommentBox!
    var commentBoxPlaceholderImage: UIImageView!
    
    var titleLabel: UILabel!
    let maxCharacters = 200
    var numberCharactersLeft: Int!
    
    var cameraVC: CameraViewController!
    
    
    override init() {
        super.init()
        cameraVC = CameraViewController()
        cameraVC.cameraDelegate = self
        
        numberCharactersLeft = maxCharacters
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        cameraVC = CameraViewController()
        cameraVC.cameraDelegate = self
        
        numberCharactersLeft = maxCharacters
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        cameraVC = CameraViewController()
        cameraVC.cameraDelegate = self
        
        numberCharactersLeft = maxCharacters
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background
        self.view.backgroundColor = UIColorFromRGB(BACKGROUND_GREY)
    
        //disable toolbar
        if let nav = self.navigationController as? RootNavViewController {
            nav.disableBottomToolbar()
            self.navigationItem.backBarButtonItem?.enabled = false
            nav.navigationBar.translucent = false
        }
       
        //init nav
        renderNavbar()
        
        //image view
        imageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.width))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
        self.view.addSubview(imageView)
        
        imageLabel = UILabel(frame: imageView.frame)
        imageLabel.text = "TAP TO ADD PICTURE"
        imageLabel.font = UIFont.boldSystemFontOfSize(24.0)
        imageLabel.textColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        imageLabel.textAlignment = NSTextAlignment.Center
        imageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        imageLabel.numberOfLines = 2
        
        self.view.addSubview(imageLabel)
        
        imageViewButton = UIButton(frame: imageView.frame)
        imageViewButton.addTarget(self, action: Selector("getPicture"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(imageViewButton)
        
        if let navbar = self.navigationController?.navigationBar {
            commentBox = CommentBox(frame: CGRectMake(10, imageView.frame.maxY+5, self.view.frame.width-20, self.view.frame.height - (imageView.frame.maxY+20) - navbar.frame.maxY))
        } else {
            commentBox = CommentBox(frame: CGRectMake(10, imageView.frame.maxY+5, self.view.frame.width-20, self.view.frame.height - imageView.frame.maxY+20))
        }
        commentBox.textViewDelegate = self
        self.view.addSubview(commentBox)
        
        var commentBoxImageFrame = commentBox.frame
        commentBoxImageFrame.origin.y += commentBox.caretSize
        commentBoxImageFrame.origin.x = 40
        commentBoxImageFrame.size.width = commentBox.frame.width-80
        commentBoxPlaceholderImage = UIImageView(frame: commentBoxImageFrame)
        commentBoxPlaceholderImage.image = UIImage(named: "CommentBoxPlaceholder.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        commentBoxPlaceholderImage.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        commentBoxPlaceholderImage.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(commentBoxPlaceholderImage)

    }
    
    func renderNavbar() {
        var backItem = BackNavItem(orientation: BackNavItemOrientation.Left)
        backItem.button.addTarget(self, action: "backButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var doneItem = DoneNavItem()
        doneItem.button.addTarget(self, action: "doneButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
    
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFontOfSize(20.0)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "\(numberCharactersLeft)"
        titleLabel.sizeToFit()
        
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationItem.rightBarButtonItem = doneItem
        self.navigationItem.titleView = titleLabel
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        var stringLength = count(textView.text)
        var textLength = count(text)
        var characters = stringLength + (textLength - range.length)
        
        if (characters <= maxCharacters) {
            numberCharactersLeft = maxCharacters - characters
        }
        if let title = self.navigationItem.titleView as? UILabel {
            title.text = "\(numberCharactersLeft)"
        }
        return characters <= maxCharacters;
    }
    
    override func textViewDidBeginEditing(textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        if (textView.text == "") {
            commentBoxPlaceholderImage.removeFromSuperview()
        }
    }
  
    override func textViewDidEndEditing(textView: UITextView) {
        super.textViewDidEndEditing(textView)
        
        if (textView.text == "") {
            self.view.addSubview(commentBoxPlaceholderImage)
        }
    }
    
    func pickedImage(image: UIImage!) {
        self.imageView.image = image
        imageLabel.removeFromSuperview()
        
        if (cameraVC != nil) {
            cameraVC.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func cameraCancelSelection() {
        //just dismiss for now
        cameraVC.dismissViewControllerAnimated(false, completion: nil)
        //sendToPreviousController()
    }
    
    func sendToPreviousController() {
        //re-enable toolbar
        if let nav = self.navigationController as? RootNavViewController {
            nav.enableBottomToolbar()
            nav.popVC(.Right)
        }
    
    }
    
    func getPicture() {
        if (cameraVC == nil) {
            cameraVC = CameraViewController()
            cameraVC.cameraDelegate = self
        }
        
        if cameraEnabled() && photosEnabled() {
            self.presentViewController(cameraVC, animated: true, completion: nil)
        }
    }
    
    func cameraEnabled() -> Bool {
        /* Ask for access to camera */
        var cameraStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if (cameraStatus != AVAuthorizationStatus.Authorized) {
            self.showAlert("Use your camera?", message: "SplatIt does not have permission to use the camera. Please update your privacy settings to get in on the fun!", yesTitle: "Yes", noTitle: "No")
            return false
        }
        /* If we reached here, either cameraStatus was authorized, or
        the alertview was accepted */
        return true
    }
    
    func photosEnabled() -> Bool {
        /* Ask for access to photos */
        var photosEnabled = PHPhotoLibrary.authorizationStatus()
        if (photosEnabled != PHAuthorizationStatus.Authorized) {
            showAlert("Use Images from Photos?", message: "SplatIt needs access to your photos so you can upload from your camera roll", yesTitle: "Yes", noTitle: "Later")
            return false
        }
        /* Authorized photos access */
        return true
    }
    
    func showAlert(title: String, message: String, yesTitle: String, noTitle: String) {
        var alertController = UIAlertController (title: title, message: message, preferredStyle: .Alert)
        
        var settingsAction = UIAlertAction(title: yesTitle, style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        var cancelAction = UIAlertAction(title: noTitle, style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        self.presentViewController(alertController, animated: true, completion: nil);
    }
    
    func backButtonListener(sender: UIButton) {
        sendToPreviousController()
    }
    
    func doneButtonListener(sender: UIButton) {
        //create post
        if (validatePost()) {
            savingPost = Post()
            var resizedImage = scaleImage(imageView.image, CGSize(width: 256, height: 256))
            let pngImage = UIImagePNGRepresentation(resizedImage)
            
            savingPost.setPicture(pngImage)
            savingPost.setScore(0)
            savingPost.setFlags(0)
            savingPost.setComment(commentBox.getComment())
            
            PFGeoPoint.geoPointForCurrentLocationInBackground({ (geopoint, error) -> Void in
                if (error != nil) {
                    println(error)
                    //alert
                    var alert = UIAlertView(title: "Cannot Post", message: "Error: you must enable location services to post!", delegate: self, cancelButtonTitle: "Okay, got it.")
                    alert.show()
                    return
                }
                if let geo = geopoint {
                    savingPost.setGeopoint(geo)
                }
                
                if let state = NSUserDefaults.standardUserDefaults().objectForKey("state") as? String {
                    if state == "foreign" {
                        if let country = NSUserDefaults.standardUserDefaults().objectForKey("country") as? String {
                            savingPost.setState(country)
                        }
                    } else {
                        savingPost.setState(state)

                    }
                }
                
                savingPost.saveObjectInBackgroundForCurrentUser { (success) -> Void in
                    if success {
                        
                        println("Success creating post!")
                    NSNotificationCenter.defaultCenter().postNotificationName("DoneAddingPost", object: nil)
                        
                    } else {
                        println("Error creating post!")
                        var alert = UIAlertView(title: "Error", message: "There was an error when trying to post. Please make sure you are connected to a network.", delegate: self, cancelButtonTitle: "Okay, got it.")
                        alert.show()
                    }
                }
            })
            
            self.sendToPreviousController()
            
        }
       
    }
    
    ///this function is used to validate the post data
    func validatePost() -> Bool {
        if (imageView.image == nil) {
            
            var alert = UIAlertView(title: "Cannot Post", message: "Error: you must add a picture to post", delegate: self, cancelButtonTitle: "Okay, got it.")
            alert.show()
            
            return false
        }
        
        return true
    }
    
}
