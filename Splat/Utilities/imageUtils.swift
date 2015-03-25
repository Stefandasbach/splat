//
//  imageUtils.swift
//  Splat
//
//  Created by Aaron Tainter on 3/14/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

let PURPLE_SELECTED: UInt = 0xaa2ef0
let PURPLE_UNSELECTED: UInt = 0xe8d8f0
let TOOLBAR_GREY: UInt = 0xf4f4f4
let BACKGROUND_GREY: UInt = 0xe9e9e9

func UIColorFromRGB(rgbHexValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbHexValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbHexValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbHexValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

//Scales image to size while keeping aspect ratio
func scaleImage(image: UIImage!, size: CGSize) ->UIImage! {
    if (image == nil) {
        return nil
    }
    
    var scaledSize = size
    var scaleFactor: CGFloat = 1.0
    
    if (image.size.width > image.size.height) {
        scaleFactor = image.size.width / image.size.height
        scaledSize.width = size.width
        scaledSize.height = size.height / scaleFactor
        
    } else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = size.height;
        scaledSize.width = size.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
    
    let scaledImageRect = CGRectMake(0, 0, scaledSize.width, scaledSize.height)
    image.drawInRect(scaledImageRect)
    var scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
}
