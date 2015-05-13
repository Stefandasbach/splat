//
//  WarningNotificationCell.swift
//  Splat
//
//  Created by Stefan Dasbach on 5/11/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class WarningNotificationCell: NotificationCell, UIAlertViewDelegate {
    var policyButton: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        policyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        policyButton.setTitle("Review Our Policy", forState: UIControlState.Normal)
        policyButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        policyButton.setTitleColor(UIColorFromRGB(PURPLE_SELECTED), forState: UIControlState.Normal)
        policyButton.addTarget(self, action: "policyButtonSelected", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(policyButton)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func initialize(notification: Notification) {
        super.initialize(notification)
        self.notificationText.hidden = true
        self.postPicture.hidden = true
        
        if let number = notification.getObject()["warningNumber"] as? Int {
            var textString = "You received a warning for misconduct. If you get \(3-number) more warnings, you will be suspended from our service."
            var attrText = NSMutableAttributedString(string: textString)
            var range = (textString as NSString).rangeOfString("\(3-number) more warnings")
            attrText.addAttribute(NSForegroundColorAttributeName, value: UIColorFromRGB(PURPLE_SELECTED), range: range)
            
            //add alignment
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.Center
            attrText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attrText.length))
            
            super.misconductTextView.attributedText = attrText
        } else {
            super.misconductTextView.text = "You received a warning for misconduct."
        }
        self.backgroundColor = UIColorFromRGB(PURPLE_SELECTED).colorWithAlphaComponent(0.15)
        self.notificationTime.frame.origin.y = 100 - self.notificationTime.frame.height - 20
        self.policyButton.center.y = notificationTime.center.y
        self.policyButton.center.x = cellWidth/2
        
    }
    
    func policyButtonSelected() {
        let alert = UIAlertView(title: "SplatIt Policy", message: "While SplatIt is for mature audiences, posting content that contains excessively objectionable or crude content is prohibited. Content that is defamatory, offensive, or intended to bully individuals or parties will be removed and the user that posted said content will be suspended. Users that post frequently pornographic material will be suspended. Users can flag objectionable content to remove it and prevent a user from further posting objectionable content. Create the SplatIt community you want to see by upvoting & downvoting content and flagging inappropriate content.", delegate: self, cancelButtonTitle: "Got it")
        alert.show()
    }
}