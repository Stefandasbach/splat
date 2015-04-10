//
//  ProfileButton.swift
//  Splat
//
//  Created by Aaron Tainter on 3/23/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class ProfileButton: UIButton {
    var buttonIntegerValue: Int!
    var buttonText: String!

    
    init(y: CGFloat, text: String, value: Int) {
        super.init(frame: CGRectMake(-5, y, 100, 50))

        buttonText = text
        buttonIntegerValue = value
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMoveToSuperview() {
        //set the width of the frame
        if let width = self.superview?.frame.size.width {
            self.frame.size.width = width+10
        }
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor
        self.addTarget(self, action: "highlightButton:", forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: "unselectButton:", forControlEvents: UIControlEvents.TouchUpOutside)
        self.addTarget(self, action: "unselectButton:", forControlEvents: UIControlEvents.TouchDragOutside)
        self.addTarget(self, action: "unselectButton:", forControlEvents: UIControlEvents.TouchDragInside)
        
        //TITLE SUBVIEW for numberPostsButton
        var pastPostsLabel = UILabel(frame: CGRectMake(20, 18, 100, 100))
        pastPostsLabel.text = "\(buttonText)"
        pastPostsLabel.font = UIFont.systemFontOfSize(14)
        pastPostsLabel.sizeToFit()
        
        //Shows the number of previous posts as a subview
        var pastPostsNumber = UILabel(frame: CGRectMake(0, 0, 100, 100))
        pastPostsNumber.text = "\(buttonIntegerValue)"
        pastPostsNumber.font = UIFont.systemFontOfSize(14)
        pastPostsNumber.textColor = UIColorFromRGB(PURPLE_SELECTED)
        pastPostsNumber.sizeToFit()
        
        pastPostsNumber.frame.origin = CGPoint(x: self.frame.width - 25 - pastPostsNumber.frame.width, y: 18)
        
        //Add to button
        self.addSubview(pastPostsLabel)
        self.addSubview(pastPostsNumber)
    }
    
   func highlightButton(sender: UIButton) {
        sender.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
    }
    
    func unselectButton(sender: UIButton) {
        sender.backgroundColor = UIColor.whiteColor()
    }
}