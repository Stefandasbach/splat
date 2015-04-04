//
//  ReplyPreviewViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 4/3/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class ReplyPreviewViewController: UIViewController, UIActionSheetDelegate {
    var currentReply: Reply!
    var replyImage: UIImageView!
    var timeCreatedLabel: UILabel!
    var voteSelector: VoteSelector!
    var replyText: UITextView!
    
    init(reply: Reply) {
        super.init()
        currentReply = reply
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //** NAVIGATION **//
        self.navigationController?.navigationBar.translucent = false
        self.view.backgroundColor = UIColor.whiteColor()
        
        var backItem = BackNavItem(orientation: BackNavItemOrientation.Left)
        backItem.button.addTarget(self, action: "backButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if (currentReply == nil) {
            return
        }
        
        //if the user is the creater, add a settings button
        if (currentReply.getCreator().objectId == User().object.objectId) {
            var settingsItem = SettingsNavItem()
            settingsItem.button.addTarget(self, action: "settingsButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.navigationItem.rightBarButtonItem = settingsItem
        }
        
        self.navigationItem.leftBarButtonItem = backItem
        
        //ADD IMAGE
        replyImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.width))
        replyImage.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        replyImage.contentMode = UIViewContentMode.ScaleAspectFill
        replyImage.clipsToBounds = true
        
        if currentReply != nil {
            currentReply.getReplyPicture({ (imageData) -> Void in
                self.replyImage.image = UIImage(data: imageData)
            })
        }
        
        self.view.addSubview(replyImage)
        
        //ADD COMMENT
        replyText = UITextView(frame: CGRectMake(10, replyImage.frame.maxY, self.view.frame.width-40-10, 100))
        replyText.editable = false
        replyText.scrollEnabled = false
        replyText.returnKeyType = UIReturnKeyType.Done
        //replyText.delegate = self
        if (self.view.frame.width == 320) {
            replyText.font = UIFont.systemFontOfSize(12.0)
        } else {
            replyText.font = UIFont.systemFontOfSize(14.0)
        }
        if let comment = currentReply.getComment() {
            replyText.text = "\(comment)"
        }
        
        self.view.addSubview(replyText)
        
        //ADD VOTE SELECTOR
        voteSelector = VoteSelector(frame: CGRect(x: replyText.frame.maxX, y: replyImage.frame.maxY, width: 40, height: 120))
        self.view.addSubview(voteSelector)
        if currentReply != nil {
            voteSelector.initialize(currentReply)
        }
        
        //time created
        timeCreatedLabel = UILabel()
        timeCreatedLabel.frame = CGRectMake(self.view.frame.width - 60, self.voteSelector.frame.maxY, 60, 40)
        timeCreatedLabel.textColor = UIColorFromRGB(PURPLE_UNSELECTED)
        timeCreatedLabel.font = UIFont.systemFontOfSize(14.0)
        var clockImg = UIImageView(frame: CGRectMake(0, 12.5, 15, 15))
        //Add Icon
        clockImg.image = UIImage(named: "clockIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        clockImg.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        var eventCreatedDate = currentReply.object.createdAt
        var today = NSDate()
        
        let timeSincePost = getStringTimeDiff(eventCreatedDate, today)
        timeCreatedLabel.text = "     \(timeSincePost.number)\(timeSincePost.unit)"
        
        
        timeCreatedLabel.addSubview(clockImg)
        self.view.addSubview(timeCreatedLabel)
        
           }
    
    func backButtonListener(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func settingsButtonListener(sender: UIButton) {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle("Delete Post")
        actionSheet.addButtonWithTitle("Edit Post")
        
        actionSheet.actionSheetStyle = .Default
        actionSheet.showInView(self.view)
    }

}