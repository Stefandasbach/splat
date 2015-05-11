//
//  WarningNotificationCell.swift
//  Splat
//
//  Created by Stefan Dasbach on 5/11/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class WarningNotificationCell: NotificationCell {
    override func initialize(notification: Notification) {
        super.initialize(notification)
        
        super.notificationText.text = "You received a warning for misconduct"
        self.backgroundColor = UIColor.redColor()
    }
}