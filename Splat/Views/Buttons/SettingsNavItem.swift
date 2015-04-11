//
//  SettingsNavItem.swift
//  Splat
//
//  Created by Aaron Tainter on 3/23/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class SettingsNavItem: UIBarButtonItem{
    
    var button: UIButton!
    
    override init() {
        super.init()
        
        button = UIButton(frame: CGRectMake(0, 0, 40, 40))
        button.setImage(UIImage(named: "gearIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.tintColor = UIColor.whiteColor()
        
        self.customView = button
    }

    required init(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
}