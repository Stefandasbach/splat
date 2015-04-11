//
//  BackNavItem.swift
//  Splat
//
//  Created by Aaron Tainter on 3/22/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class BackNavItem: UIBarButtonItem {
    
    var button: UIButton!
    
    init(orientation: BackNavItemOrientation) {
        super.init()
        
        button = UIButton(frame: CGRectMake(0, 0, 40, 40))
        if (orientation == BackNavItemOrientation.Left) {
            button.setImage(UIImage(named: "backIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        } else if (orientation == BackNavItemOrientation.Right){
             button.setImage(UIImage(named: "backIconFlipped.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        }
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.tintColor = UIColor.whiteColor()
        
        self.customView = button
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

enum BackNavItemOrientation {
    case Left
    case Right
}