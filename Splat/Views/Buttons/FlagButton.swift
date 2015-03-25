//
//  FlagButton.swift
//  Splat
//
//  Created by Aaron Tainter on 3/23/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class FlagButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setImage(UIImage(named: "flagIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        self.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        self.imageEdgeInsets = UIEdgeInsetsMake(12.5, 12.5, 12.5, 12.5)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        
        self.setImage(UIImage(named: "flagIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        self.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)

    }
}