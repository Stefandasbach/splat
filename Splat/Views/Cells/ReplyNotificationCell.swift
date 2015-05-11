//
//  ReplyNotificationCell.swift
//  Splat
//
//  Created by Aaron Tainter on 4/7/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class ReplyNotificationCell: NotificationCell {
    override func initialize(notification: Notification) {
        super.initialize(notification)
        
        super.notificationText.text = "Someone replied to your post"
        self.backgroundColor = UIColor.blueColor()
    }
}