//
//  NotificationBadge.swift
//  Splat
//
//  Created by Aaron Tainter on 4/7/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class NotificationBadge: UIView {
    private var numberLabel: UILabel!
    var badgeNumber = 0
    
    init(number: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        self.badgeNumber = number
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        
        if (badgeNumber != 0) {
            self.backgroundColor = UIColor.redColor()
            self.layer.cornerRadius = 4
            
            numberLabel = UILabel(frame: self.frame)
            numberLabel.text = "\(badgeNumber)"
            numberLabel.font = UIFont.systemFontOfSize(14.0)
            numberLabel.textAlignment = NSTextAlignment.Center
            numberLabel.textColor = UIColor.whiteColor()
            numberLabel.sizeToFit()
            numberLabel.frame.size.width += 10
            numberLabel.frame.size.height = self.frame.height
            self.frame.size.width = numberLabel.frame.width
            self.center.x = 6
            //self.center.y = 0
            
            self.addSubview(numberLabel)
        }
    }
    
}