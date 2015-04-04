//
//  cameraViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/14/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Photos

protocol cameraViewDelegate {
    func pickedImage(image: UIImage!)
    func cameraCancelSelection()
}

class CameraViewController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var cameraDelegate: cameraViewDelegate!
    
    var gallery: UIButton!
    var galleryImage: UIImageView!
    var capturePictureButton: UIButton!
    var flipCamera:UIButton!
    
    var cameraToolbar: UIToolbar!
    var flashButton:UIButton!
    
    var selectionType = "Camera"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.allowsEditing = true
        initView()
    
        self.delegate = self
    }
    
    func initView() {
        /* Ask for access to camera */
        var cameraEnabled = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if (cameraEnabled == AVAuthorizationStatus.Authorized) {
            //Proceed
        } else {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {(granted) -> Void in
                if(granted){
                    println("Granted camera access")
                } else {
                    println("Not granted camera access")
                    dispatch_async(dispatch_get_main_queue(), {
                        UIAlertView(
                            title: "Could not use camera",
                            message: "Splat does not have permission to use the camera. Please update your privacy settings.",
                            delegate: self,
                            cancelButtonTitle: "OK").show()
                    })
                }
            })
        }
        
        /* Ask for access to photos */
        var photosEnabled = PHPhotoLibrary.authorizationStatus()
        
//        if (photosEnabled != PHAuthorizationStatus.Authorized) {
        
        /* Temporary change to always request for authorization */
        PHPhotoLibrary.requestAuthorization({ (status) -> Void in
            if (status != PHAuthorizationStatus.Authorized) {
                dispatch_async(dispatch_get_main_queue(), {
                    println("Not authorized")
                })
            }
            else {
                println("Authorized")
                dispatch_async(dispatch_get_main_queue(), {
                    //check if the camera is available
                    if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
                        self.sourceType = UIImagePickerControllerSourceType.Camera
                        self.showsCameraControls = false
                        self.selectionType = "Camera"
                        self.renderCameraElements()
                        
                    } else {
                        self.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                        self.selectionType = "Library"
                    }
                })
            }
        })
        

        

    }
    
    override func viewDidAppear(animated: Bool) {
        //Kind of a hack. Want to reinit the camera settings
         if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            if (self.sourceType == UIImagePickerControllerSourceType.Camera) {
                orientCamera(flipCamera)
                setFlash(flashButton)
            }
        }
    }
    
    func requestAccessToPhotoLibrary() {
        
    }
    
    func renderCameraElements() {
        //CONSTANTS
        let captureButtonSize:CGFloat = 80
        let sideButtonSize:CGFloat = 50
        let bottomPadding:CGFloat = 40
        
        //GALLERY BUTTON
        gallery = UIButton(frame: CGRectMake(self.view.frame.width - sideButtonSize - bottomPadding, self.view.frame.height - sideButtonSize - bottomPadding, sideButtonSize, sideButtonSize))
        gallery.addTarget(self, action: Selector("changePictureMode"), forControlEvents: UIControlEvents.TouchUpInside)
        galleryImage = UIImageView(frame: gallery.frame)
        galleryImage.contentMode = UIViewContentMode.ScaleAspectFill
        galleryImage.clipsToBounds = true
        
        //set gallery image thumbnail
        getGalleryThumbnail()
        
        
        //CAPTURE BUTTON
        capturePictureButton = UIButton(frame: CGRectMake(self.view.frame.width/2 - bottomPadding, self.view.frame.height - captureButtonSize - bottomPadding, captureButtonSize, captureButtonSize))
        capturePictureButton.setImage(UIImage(named: "captureButtonInner.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        capturePictureButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
        
        var captureButtonEdge = UIImageView(image: UIImage(named: "captureButtonEdge.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        captureButtonEdge.tintColor = UIColor.whiteColor()
        captureButtonEdge.frame = CGRectMake(0, 0, capturePictureButton.frame.width, capturePictureButton.frame.height)
        
        capturePictureButton.addSubview(captureButtonEdge)
        
        //call the uiimagepickercontroller method takePicture()
        capturePictureButton.addTarget(self, action: Selector("capture:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        //FLIP CAMERA BUTTON
        flipCamera = UIButton(frame: CGRectMake(bottomPadding, self.view.frame.height - sideButtonSize - bottomPadding, sideButtonSize, sideButtonSize))
        flipCamera.addTarget(self, action: Selector("flipCamera:"), forControlEvents: UIControlEvents.TouchUpInside)
        flipCamera.setImage(UIImage(named: "flipCameraIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        flipCamera.tintColor = UIColor.whiteColor()
        
        
        //CAMERA TOOLBAR
        cameraToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.width, 60))
        cameraToolbar.barStyle = UIBarStyle.BlackTranslucent
        cameraToolbar.translucent = true
        let exitButton = UIButton(frame: CGRectMake(0, 10, 40, 40))
        exitButton.setImage(UIImage(named: "exitIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        exitButton.tintColor = UIColor.whiteColor()
        exitButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        exitButton.addTarget(self, action: Selector("exitButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        cameraToolbar.addSubview(exitButton)
        
        flashButton = UIButton(frame: CGRectMake(self.view.frame.width - 40, 10, 40, 40))
        flashButton.setImage(UIImage(named: "flashIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        flashButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flashButton.tintColor = UIColor.whiteColor()
        flashButton.addTarget(self, action: Selector("toggleFlash:"), forControlEvents: UIControlEvents.TouchUpInside)
        cameraToolbar.addSubview(flashButton)
        
        //ADD ELEMENTS TO SUBVIEW
        addCameraElements()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var myImage = info[UIImagePickerControllerEditedImage] as UIImage!
        
        if myImage == nil {
            myImage = info[UIImagePickerControllerOriginalImage] as UIImage!
        }
        
        if (cameraDelegate != nil) {
            cameraDelegate.pickedImage(myImage)
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        if (selectionType == "Camera" || !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            cameraDelegate.cameraCancelSelection()
        } else if (selectionType == "Library") {
            changePictureMode()
        }
    }
    
    //button listeners
    func changePictureMode() {
        if (selectionType == "Camera") {
             selectionType = "Library"
            removeCameraElements()
            self.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        } else if (selectionType == "Library") {
            selectionType = "Camera"
            addCameraElements()
            self.sourceType = UIImagePickerControllerSourceType.Camera
            
            orientCamera(flipCamera)
            setFlash(flashButton)
        }

    }
    
    func exitButtonPressed() {
        cameraDelegate.cameraCancelSelection()
    }
    
    func getGalleryThumbnail() {
        var fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors =  [NSSortDescriptor(key: "creationDate", ascending: true)]
        var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        var lastAsset = fetchResult.lastObject as PHAsset
        var requestOptions = PHImageRequestOptions()
        requestOptions.version = PHImageRequestOptionsVersion.Current
        PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: self.galleryImage.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions) { (image, info) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.galleryImage.image = image
            })
        }
    }
    
    func addCameraElements() {
        if (self.selectionType == "Camera") {
            self.view.addSubview(galleryImage)
            self.view.addSubview(gallery)
            self.view.addSubview(flipCamera)
            self.view.addSubview(capturePictureButton)
            self.view.addSubview(cameraToolbar)
        }
    }
    
    func removeCameraElements() {
        if (self.selectionType != "Camera") {
            galleryImage.removeFromSuperview()
            gallery.removeFromSuperview()
            flipCamera.removeFromSuperview()
            capturePictureButton.removeFromSuperview()
            cameraToolbar.removeFromSuperview()
        }
    }
    
    func capture(sender: UIButton) {
        self.takePicture()
    }
    
    func toggleFlash(sender: UIButton) {
        if (sender.selected == false) {
            sender.tintColor = UIColorFromRGB(PURPLE_SELECTED)
            sender.selected = true
        } else {
            sender.tintColor = UIColor.whiteColor()
            sender.selected = false
        }
        
        setFlash(sender)
    }
    
    func flipCamera(sender: UIButton) {
        if (sender.selected == false) {
            sender.tintColor = UIColorFromRGB(PURPLE_SELECTED)
            sender.selected = true
        } else {
            sender.tintColor = UIColor.whiteColor()
            sender.selected = false
        }
        
        orientCamera(sender)

    }
    
    func orientCamera(sender:UIButton) {
        if (sender.selected == true) {
            self.cameraDevice = UIImagePickerControllerCameraDevice.Front
        } else {
            self.cameraDevice = UIImagePickerControllerCameraDevice.Rear
        }
    }
    
    func setFlash(sender: UIButton) {
        if (sender.selected == true) {
            self.cameraFlashMode = UIImagePickerControllerCameraFlashMode.On
        } else {
            self.cameraFlashMode = UIImagePickerControllerCameraFlashMode.Off
        }
    }
    
    // TODO:
    //add autofocus bounding box
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

    }
    
    
    
}