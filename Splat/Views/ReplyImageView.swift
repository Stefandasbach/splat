//
//  ReplyImageView.swift
//  Splat
//
//  Created by Aaron Tainter on 4/4/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class ReplyImageView: UIView {
    var container: ContainerView!
    var image: UIImageView!
    var exitButton: UIButton!
    var currentReply: Reply!
    
    init(reply: Reply) {
        super.init(frame: CGRectZero)
        
        currentReply = reply
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        if let superview = self.superview {
            self.frame = superview.frame
            self.frame.origin.x = 0
            self.frame.origin.y = 0
        }
        
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        self.container = ContainerView(frame: CGRect(x: 20, y: 40, width: self.frame.width-40, height: self.frame.width-40 + 40))
        self.container.center = self.center
        self.container.center.y -= 40
        
        self.container.backgroundColor = UIColorFromRGB(PURPLE_SELECTED).colorWithAlphaComponent(0.8)
        
        
        
        //exit BUTTON
        exitButton = UIButton(frame: CGRectMake(self.container.frame.width-40, 0, 40, 40))
        exitButton.setImage(UIImage(named: "exitIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        exitButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        exitButton.tintColor = UIColor.whiteColor()
        exitButton.addTarget(self, action: "exitButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        self.container.addSubview(exitButton)
        
        self.image = UIImageView(frame: CGRect(x: 0, y: 40, width: container.frame.width, height: container.frame.width + 2))
        self.image.contentMode = UIViewContentMode.ScaleAspectFill
        self.image.clipsToBounds = true
        container.addSubview(image)
        
        if currentReply.hasPicture() {
            currentReply.getReplyPicture { (imageData) -> Void in
                self.image.image = UIImage(data: imageData)
            }
        }
        self.container.layer.cornerRadius = 6.0
        self.container.layer.masksToBounds = true
        self.addSubview(container)
        
    }
    
    func exitButtonListener(sender: UIButton) {
        if let superview = self.superview {
            fadeoutSubview(self, 0.2, superview)
        }
    }
}