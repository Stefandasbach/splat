//
//  PostPreviewViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/21/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Photos
import Parse

class PostPreviewViewController: ResponsiveTextFieldViewController, UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIGestureRecognizerDelegate, cameraViewDelegate {
    
    var cameraVC: CameraViewController!
    
    var mainScrollView: PostScrollView!
    var replyTable: UITableView!
    var replyData = NSMutableArray()

    var enlargedReplyView: UITextView!
    var replyImage: UIImageView!
    var replyImageButton: UIButton!
    var replyImageLabel: UILabel!
    var replyView: UIView!
    
    
    var currentPost: Post!
    var postImage: UIImageView!
    var commentText: UITextView!
    var voteSelector:VoteSelector!
    var flagButton: UIButton!
    var shareButton: UIButton!
    var timeCreatedLabel: UILabel!
    
    
    let maxCharacters = 200
    var numberCharactersLeft: Int!
    
    let maxCharactersReply = 100
    var numberCharactersLeftReply: Int!
    
    init(post: Post) {
        super.init()
        currentPost = post
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ylocCursor:CGFloat = 0
        var padding:CGFloat = 10
        
        //** NAVIGATION **//
        self.navigationController?.navigationBar.translucent = false
        self.view.backgroundColor = UIColor.whiteColor()
        
        var backItem = BackNavItem(orientation: BackNavItemOrientation.Left)
        backItem.button.addTarget(self, action: "backButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if (currentPost == nil) {
            return
        }
        
        //if the user is the creater, add a settings button
        if (currentPost.getCreator().objectId == User().object.objectId) {
            var settingsItem = SettingsNavItem()
            settingsItem.button.addTarget(self, action: "settingsButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.navigationItem.rightBarButtonItem = settingsItem
        }
        
        self.navigationItem.leftBarButtonItem = backItem
        
        
        
        var titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        titleLabel.text = "Post"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "Pacifico", size: 20.0)
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
        //**//
        
        replyView = UIView()
        replyView.backgroundColor = UIColorFromRGB(PURPLE_UNSELECTED)
        
        replyImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        replyImage.backgroundColor = UIColorFromRGB(PURPLE_SELECTED)
        replyImage.contentMode = UIViewContentMode.ScaleAspectFill
        replyImage.clipsToBounds = true
        replyImageLabel = UILabel()
        replyImageLabel.frame = replyImage.frame
        replyImageLabel.text = "Reply"
        replyImageLabel.textColor = UIColor.whiteColor()
        replyImageLabel.textAlignment = NSTextAlignment.Center
        replyImageLabel.font = UIFont.systemFontOfSize(12.0)
        replyImageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        replyImageLabel.numberOfLines = 2

        replyImage.addSubview(replyImageLabel)
        
        replyImageButton = UIButton()
        replyImageButton.frame = replyImage.frame
        replyImageButton.addTarget(self, action: "chooseReplyImage", forControlEvents: UIControlEvents.TouchUpInside)
        replyImageButton.enabled = false
        
        enlargedReplyView = UITextView(frame: CGRect(x: 60, y: 10, width: self.view.frame.width-70, height: 30))
        enlargedReplyView.returnKeyType = UIReturnKeyType.Send
        enlargedReplyView.delegate = self
        enlargedReplyView.backgroundColor = UIColor.whiteColor()
        
        replyView.addSubview(replyImage)
        replyView.addSubview(replyImageButton)
        replyView.addSubview(enlargedReplyView)
        
        //scrollView
        if let navOffset = self.navigationController?.navigationBar.frame.maxY {
            replyView.frame = CGRect(x: 0, y: self.view.frame.height-navOffset-50, width: self.view.frame.width, height: 50)
            self.view.addSubview(replyView)
            mainScrollView = PostScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - navOffset - replyView.frame.height))
        } else {
            replyView.frame = CGRect(x: 0, y: self.view.frame.height-50, width: self.view.frame.width, height: 50)
            self.view.addSubview(replyView)
            mainScrollView = PostScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - replyView.frame.height))
        }
        
        //ADD IMAGE
        postImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.width))
        postImage.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        postImage.contentMode = UIViewContentMode.ScaleAspectFill
        postImage.clipsToBounds = true
        
        if currentPost != nil {
            currentPost.getEventPicture({ (imageData) -> Void in
                self.postImage.image = UIImage(data: imageData)
            })
        }
        mainScrollView.addSubview(postImage)
        
        ylocCursor = postImage.frame.maxY
        
        
        
        //ADD COMMENT
        commentText = UITextView(frame: CGRectMake(padding, ylocCursor+padding, self.view.frame.width-40-padding, 100))
        commentText.editable = false
        commentText.scrollEnabled = false
        commentText.returnKeyType = UIReturnKeyType.Done
        commentText.delegate = self
        if (self.view.frame.width == 320) {
            commentText.font = UIFont.systemFontOfSize(12.0)
        } else {
            commentText.font = UIFont.systemFontOfSize(14.0)
        }
        if let comment = currentPost.getComment() {
            commentText.text = "\(comment)"
        }
        
        mainScrollView.addSubview(commentText)
        
        //ADD VOTE SELECTOR
        voteSelector = VoteSelector(frame: CGRect(x: commentText.frame.maxX, y: postImage.frame.maxY, width: 40, height: 120))
        mainScrollView.addSubview(voteSelector)
        if currentPost != nil {
            voteSelector.initialize(currentPost)
        }
        
        ylocCursor = commentText.frame.maxY
        
        //flag button
        let flagSize = 40 as CGFloat
        flagButton = FlagButton(frame: CGRectMake(padding, ylocCursor + padding, flagSize, flagSize))
        updateFlagButton()
        mainScrollView.addSubview(flagButton)
        
        ylocCursor = flagButton.frame.maxY
        
        //share button
        shareButton = UIButton(frame: CGRectMake(mainScrollView.frame.width/2-20, flagButton.frame.minY, 40, 40))
        shareButton.setImage(UIImage(named: "shareIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        shareButton.imageEdgeInsets = UIEdgeInsetsMake(12.5, 12.5, 12.5, 12.5)
        shareButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        //mainScrollView.addSubview(shareButton)
        
        //time created
        timeCreatedLabel = UILabel()
        timeCreatedLabel.frame = CGRectMake(mainScrollView.frame.width-60, flagButton.frame.minY, 60, 40)
        timeCreatedLabel.textColor = UIColorFromRGB(PURPLE_UNSELECTED)
        timeCreatedLabel.font = UIFont.systemFontOfSize(14.0)
        var clockImg = UIImageView(frame: CGRectMake(0, 12.5, 15, 15))
        //Add Icon
        clockImg.image = UIImage(named: "clockIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        clockImg.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        var eventCreatedDate = currentPost.object.createdAt
        var today = NSDate()
        
        let timeSincePost = getStringTimeDiff(eventCreatedDate!, today)
        timeCreatedLabel.text = "     \(timeSincePost.number)\(timeSincePost.unit)"
        
        
        timeCreatedLabel.addSubview(clockImg)
        mainScrollView.addSubview(timeCreatedLabel)

        
        //Add line to break between replies
        var path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, ylocCursor))
        path.addLineToPoint(CGPointMake(self.view.frame.width, ylocCursor))
        
        //create shape from path
        var shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = UIColorFromRGB(PURPLE_UNSELECTED).CGColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        
        mainScrollView.layer.addSublayer(shapeLayer)
        
        replyTable = UITableView(frame: CGRect(x: 0, y: ylocCursor, width: mainScrollView.frame.width, height: 100))
        replyTable.delegate = self
        replyTable.dataSource = self
        
        loadReplyData(0, limit: 100)
        mainScrollView.addSubview(replyTable)

        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.size.width, height: ylocCursor+padding + 100)
        
        self.view.addSubview(mainScrollView)
        
        addSelectors()
        
    }
    
    func addSelectors() {
        voteSelector.UpvoteButton.addTarget(self, action: "upvote:", forControlEvents: UIControlEvents.TouchUpInside)
        voteSelector.DownvoteButton.addTarget(self, action: "downvote:", forControlEvents: UIControlEvents.TouchUpInside)
        flagButton.addTarget(self, action: "flag:", forControlEvents: UIControlEvents.TouchUpInside)
        shareButton.addTarget(self, action: "share:", forControlEvents: UIControlEvents.TouchUpInside)
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
    
    func cancelReplyListener() {
        if (enlargedReplyView.isFirstResponder()) {
            enlargedReplyView.resignFirstResponder()
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        switch buttonIndex {
            case 0: //cancel
                break;
            case 1: //delete
                deletePost()
                break;
            case 2: //delete
                editPost()
                break;
            default:
                break
        }
    }
    
    func deletePost() {
        currentPost.deleteObjectInBackground { (success) -> Void in
            if success {
                self.navigationController?.popViewControllerAnimated(true)
                NSNotificationCenter.defaultCenter().postNotificationName("RemovedPost", object: self.currentPost)
            }
        }
    }
    
    func editPost() {
        commentText.editable = true
        commentText.becomeFirstResponder()
        
    }
    
    //make sure characters don't exceed 200
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if (textView == commentText) {
            if (text == "\n") {
                textView.resignFirstResponder()
                return false
            }
            
            var stringLength = count(textView.text)
            var textLength = count(text)
            var characters = stringLength + (textLength - range.length)
            
            if (characters <= maxCharacters) {
                numberCharactersLeft = maxCharacters - characters
            }
            return characters <= maxCharacters;
        }
        
        else if (textView == enlargedReplyView) {
            if (text == "\n") {
                
                if (replyImage.image != nil) {
                    var resizedImage = scaleImage(replyImage.image, CGSize(width: 256, height: 256))
                    let pngImage = UIImagePNGRepresentation(resizedImage)
                    
                    uploadReply(pngImage, comment: textView.text)
                } else {
                    uploadReply(nil, comment: textView.text)
                }
                textView.text = "";
                replyImage.image = nil
                replyImageLabel.hidden = false
                textView.resignFirstResponder()
                return false
            }
            
            var stringLength = count(textView.text)
            var textLength = count(text)
            var characters = stringLength + (textLength - range.length)
            
            if (characters <= maxCharactersReply) {
                numberCharactersLeftReply = maxCharactersReply - characters
            }
            return characters <= maxCharactersReply;
        }
        return true
    }

    
    override func textViewDidBeginEditing(textView: UITextView) {
        
        if (textView == enlargedReplyView) {
            replyImageButton.enabled = true
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.bringSubviewToFront(self.replyView)
                self.replyView.frame.size.height = 100
                self.replyView.frame.origin.y = self.view.frame.height-100
                self.replyImage.frame.size.width = 100
                self.replyImage.frame.size.height = 100
                self.replyImageButton.frame = self.replyImage.frame
                self.replyImageLabel.frame = self.replyImage.frame
            
                self.enlargedReplyView.frame.origin.x = self.replyImage.frame.maxX + 10
                self.enlargedReplyView.frame.origin.y = 10
                self.enlargedReplyView.frame.size.height = 100 - 20
                self.enlargedReplyView.frame.size.width = self.view.frame.width-100-10-10
                
                self.replyImageLabel.text = "Tap to add Image"
                self.replyImageLabel.font = UIFont.systemFontOfSize(14.0)
                
                self.mainScrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - self.replyView.frame.height)
                
            })
            
            disableSubviews()
        }
            
    }
    
    override func textViewDidEndEditing(textView: UITextView) {
        
        if (textView == enlargedReplyView) {
            replyImageButton.enabled = false
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.bringSubviewToFront(self.replyView)
                self.replyView.frame.size.height = 50
                self.replyView.frame.origin.y = self.view.frame.height-50
                self.replyImage.frame.size.width = 50
                self.replyImage.frame.size.height = 50
                self.replyImageButton.frame = self.replyImage.frame
                self.replyImageLabel.frame = self.replyImage.frame
                
                self.enlargedReplyView.frame.origin.x = self.replyImage.frame.maxX + 10
                self.enlargedReplyView.frame.origin.y = 10
                self.enlargedReplyView.frame.size.height = 50 - 20
                self.enlargedReplyView.frame.size.width = self.view.frame.width-50-10-10
                
                self.replyImageLabel.text = "Reply"
                self.replyImageLabel.font = UIFont.systemFontOfSize(12.0)
                
                self.mainScrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - self.replyView.frame.height)
                
            })
            
            enableSubviews()
        }
        
        if (textView == commentText) {
            super.textViewDidEndEditing(textView)
            commentText.editable = false
            
            //TODO: test
            currentPost.editComment(commentText.text, completion: { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("RefreshFeed", object: nil)
            })
        }
        
    }
    
    func upvote(sender: UIButton) {
        if let post = currentPost {
            var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as? NSArray
            var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as? NSArray
            
            if var existingScore = voteSelector.Score.text?.toInt() {
            
                if let oID = post.object.objectId {
                    //if upvote already selected
                    if (upvotes != nil && upvotes!.containsObject(oID)) {
                        //remove upvote
                        post.removeUpvote()
                        removeArchivedUpvote(oID, upvotes)
                        existingScore = existingScore - 1

                        //if downvote already selected
                    } else if (downvotes != nil && downvotes!.containsObject(oID)) {
                        //remove downvote
                        post.removeDownvote()
                        removeArchivedDownvote(oID, downvotes)
                        existingScore = existingScore + 1
                        
                        post.addUpvote()
                        archiveUpvote(oID, upvotes)
                        existingScore = existingScore + 1
                        
                        //nothing selected
                    } else {
                        post.addUpvote()
                        archiveUpvote(oID, upvotes)
                        existingScore = existingScore + 1
                        
                    }
                    
                    voteSelector.Score.text = "\(existingScore)"
                    voteSelector.updateHighlighted()
                    NSNotificationCenter.defaultCenter().postNotificationName("RefreshFeed", object: nil)
                }
            }
        }

    }

    func downvote(sender: UIButton) {
        
        if let post = currentPost {
            var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as? NSArray
            var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as? NSArray
            
            if var existingScore = voteSelector.Score.text?.toInt() {
            
                if let oID = post.object.objectId {
                    //if downvote already selected
                    if (downvotes != nil && downvotes!.containsObject(oID)) {
                        //remove downvote
                        post.removeDownvote()
                        removeArchivedDownvote(oID, downvotes)
                        existingScore = existingScore + 1
                        
                        //if Upvote already selected
                    } else if (upvotes != nil && upvotes!.containsObject(oID)) {
                        //remove Upvote
                        post.removeUpvote()
                        removeArchivedUpvote(oID, upvotes)
                        existingScore = existingScore - 1
                        
                        post.addDownvote()
                        archiveDownvote(oID, downvotes)
                        existingScore = existingScore - 1
                        
                        //nothing selected
                    } else {
                        post.addDownvote()
                        archiveDownvote(oID, downvotes)
                        existingScore = existingScore - 1
                        
                    }
                    
                    voteSelector.Score.text = "\(existingScore)"
                    voteSelector.updateHighlighted()
                    NSNotificationCenter.defaultCenter().postNotificationName("RefreshFeed", object: nil)
                }
            }
        }
    }
    
    func flag(sender: UIButton) {
        var post = currentPost
        var flags = NSUserDefaults.standardUserDefaults().objectForKey("SplatFlags") as? NSArray
        if let oID = post?.object.objectId {
            
            if (flags != nil && flags!.containsObject(oID)) {
                //remove flag
                println("removeflag")
                post?.removeFlag()
                removeArchivedFlag(flags, oID)
                updateFlagButton()
            } else {
                //add flag
                println("addflag")
                post?.addFlag()
                archiveFlag(flags, oID)
                updateFlagButton()
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("RefreshFeed", object: nil)
            
        }

    }
    
    private func updateFlagButton() {
        var flags = NSUserDefaults.standardUserDefaults().objectForKey("SplatFlags") as? NSArray
        if let oID = currentPost.object.objectId {
            
            if (flags != nil && flags!.containsObject(oID)) {
                flagButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
            } else {
                flagButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
            }
        }
    }
    
    func upvoteReply(sender: UIButton) {
        let pointInTable: CGPoint = sender.convertPoint(sender.bounds.origin, toView: self.replyTable)
        let cellIndexPath = self.replyTable.indexPathForRowAtPoint(pointInTable)
        if (cellIndexPath != nil) {
            var cellIndexPathExists: NSIndexPath
            cellIndexPathExists = cellIndexPath as NSIndexPath!
            let cell = self.replyTable.cellForRowAtIndexPath(cellIndexPathExists) as! ReplyCell
        
            if let post = replyData[cellIndexPathExists.row] as? Reply {
                var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyUpvotes") as? NSArray
                var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyDownvotes") as? NSArray
                
                if var existingScore = cell.voteSelector.Score.text?.toInt() {
                    
                    if let oID = post.object.objectId {
                        //if upvote already selected
                        if (upvotes != nil && upvotes!.containsObject(oID)) {
                            //remove upvote
                            post.removeUpvote()
                            removeArchivedUpvoteReply(oID, upvotes)
                            existingScore = existingScore - 1
                            
                            //if downvote already selected
                        } else if (downvotes != nil && downvotes!.containsObject(oID)) {
                            //remove downvote
                            post.removeDownvote()
                            removeArchivedDownvoteReply(oID, downvotes)
                            existingScore = existingScore + 1
                            
                            post.addUpvote()
                            archiveUpvoteReply(oID, upvotes)
                            existingScore = existingScore + 1
                            
                            //nothing selected
                        } else {
                            post.addUpvote()
                            archiveUpvoteReply(oID, upvotes)
                            existingScore = existingScore + 1
                            
                        }
                        
                        cell.voteSelector.Score.text = "\(existingScore)"
                        cell.voteSelector.updateHighlighted()
                        
                    }
                }
            }
        }
        
    }
    
    func downvoteReply(sender: UIButton) {
        
        let pointInTable: CGPoint = sender.convertPoint(sender.bounds.origin, toView: self.replyTable)
        let cellIndexPath = self.replyTable.indexPathForRowAtPoint(pointInTable)
        if (cellIndexPath != nil) {
            var cellIndexPathExists: NSIndexPath
            cellIndexPathExists = cellIndexPath as NSIndexPath!
            let cell = self.replyTable.cellForRowAtIndexPath(cellIndexPathExists) as! ReplyCell
            
            if let post = replyData[cellIndexPathExists.row] as? Reply {
                var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyUpvotes") as? NSArray
                var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatReplyDownvotes") as? NSArray
                
                if var existingScore = cell.voteSelector.Score.text?.toInt() {
                    
                    if let oID = post.object.objectId {
                        //if downvote already selected
                        if (downvotes != nil && downvotes!.containsObject(oID)) {
                            //remove downvote
                            post.removeDownvote()
                            removeArchivedDownvoteReply(oID, downvotes)
                            existingScore = existingScore + 1
                            
                            //if Upvote already selected
                        } else if (upvotes != nil && upvotes!.containsObject(oID)) {
                            //remove Upvote
                            post.removeUpvote()
                            removeArchivedUpvoteReply(oID, upvotes)
                            existingScore = existingScore - 1
                            
                            post.addDownvote()
                            archiveDownvoteReply(oID, downvotes)
                            existingScore = existingScore - 1
                            
                            //nothing selected
                        } else {
                            post.addDownvote()
                            archiveDownvoteReply(oID, downvotes)
                            existingScore = existingScore - 1
                            
                        }
                        
                        cell.voteSelector.Score.text = "\(existingScore)"
                        cell.voteSelector.updateHighlighted()
                        
                    }
                }
            }
        }
    }

    
    //TODO:
    func share(sender: UIButton) {
        println("Share post here")
    }
    
    func uploadReply(image: NSData!, comment: String) {
        if (validateReply()) {
            
            var reply = Reply()
            reply.setComment(comment)
            reply.setParentPost(currentPost.object)
            reply.setScore(0)
            if image != nil {
                reply.setPicture(image)
            }
            reply.saveObjectInBackgroundForCurrentUser { (success) -> Void in
                if success {
                    println("saved reply!")
                    dispatch_async(dispatch_get_main_queue(), {
                        Notification.sendNotificationForReply(reply, parentPost: self.currentPost)
                        self.loadReplyData(0, limit: 100)
                    })
                }
            }
        }
 
    }
    
    func validateReply()->Bool {
        if (enlargedReplyView.text == nil || (enlargedReplyView.text == "" && replyImage.image == nil) ) {
            var alert = UIAlertView(title: "Cannot Post", message: "Error: you must add a reply to post.", delegate: self, cancelButtonTitle: "Okay, got it.")
            alert.show()
            return false
        }
        return true;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //selected reply
        //TODO: add comment image preview
        var currentReply = replyData.objectAtIndex(indexPath.row) as! Reply
        if currentReply.hasPicture() {
            var replyPreview = ReplyImageView(reply: currentReply)
            fadeinSubview(replyPreview, 0.2, self.view)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //we get an error without this for some reason...
        if (replyData.count == 0) {
            return UITableViewCell();
        }
        
        var cell: ReplyCell!
        
        let reply = replyData.objectAtIndex(indexPath.row) as! Reply
        
        cell = tableView.dequeueReusableCellWithIdentifier("ReplyCell") as? ReplyCell
        
        
        if (cell == nil) {
            cell = ReplyCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ReplyCell")
        }
        
        cell.initialize(reply)
        
        
        cell.voteSelector.UpvoteButton.tag = indexPath.row
        cell.voteSelector.DownvoteButton.tag = indexPath.row
        
        //TODO: add scoring system for comments
        cell.voteSelector.UpvoteButton.addTarget(self, action: "upvoteReply:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.voteSelector.DownvoteButton.addTarget(self, action: "downvoteReply:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    //allows reply box to be exited through touch events
    func disableSubviews() {
        replyTable.userInteractionEnabled = false
        commentText.userInteractionEnabled = false
        voteSelector.userInteractionEnabled = false
        flagButton.userInteractionEnabled = false
        shareButton.userInteractionEnabled = false
        timeCreatedLabel.userInteractionEnabled = false
    }
    
    func enableSubviews() {
        replyTable.userInteractionEnabled = true
        commentText.userInteractionEnabled = true
        voteSelector.userInteractionEnabled = true
        flagButton.userInteractionEnabled = true
        shareButton.userInteractionEnabled = true
        timeCreatedLabel.userInteractionEnabled = true
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let replyCell = cell as? ReplyCell {
            replyCell.cancelLoad()
            replyCell.myImage.image = nil
        }
    }
    
    func loadReplyData(skip: Int, limit: Int) {
        
        var query: PFQuery = PFQuery(className: "Reply")
        query.limit = limit
        query.skip = skip
        query.orderByAscending("createdAt")
        query.whereKey("parent", equalTo: currentPost.object)
        query.findObjectsInBackgroundWithBlock({
            (objects, error)->Void in
            
            if (skip == 0) {
                self.replyData.removeAllObjects()
            }
            
            if (error != nil) {
                println("Error: receiving data")
                return
                
            }
            
            if let objs = objects {
                for object in objs {
                    if let obj = object as? PFObject {
                        self.replyData.addObject(Reply(pfObject: obj))
                    }
                }
            }
            
            self.replyTable.reloadData()
            self.replyTable.frame.size.height = CGFloat(self.replyData.count)*100
            self.mainScrollView.contentSize.height = self.replyTable.frame.maxY + 200
            
        })
        
        
    }
    
    func chooseReplyImage() {
        if (enlargedReplyView.isFirstResponder()) {
            enlargedReplyView.resignFirstResponder()
        }
        
        if (cameraVC == nil) {
            cameraVC = CameraViewController()
            cameraVC.cameraDelegate = self
        }
        if cameraEnabled() && photosEnabled() {
            self.presentViewController(cameraVC, animated: true, completion: nil)
        }
    }
    
    
    //CameraViewController Delegate methods
    func pickedImage(image: UIImage!) {
        replyImage.image = image
        replyImageLabel.hidden = true
        
        if (cameraVC != nil) {
            cameraVC.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func cameraCancelSelection() {
        if (cameraVC != nil) {
            cameraVC.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func cameraEnabled() -> Bool {
        /* Ask for access to camera */
        var cameraStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if (cameraStatus != AVAuthorizationStatus.Authorized) {
            self.showAlert("Use your camera?", message: "Splat does not have permission to use the camera. Please update your privacy settings to get in on the fun!", yesTitle: "Yes", noTitle: "Later")
            return false
        }
        /* If we reached here, either cameraStatus was authorized, or
        the alertview was accepted */
        return true
    }
    
    func photosEnabled() -> Bool {
        /* Ask for access to photos */
        var photosEnabled = PHPhotoLibrary.authorizationStatus()
        if (photosEnabled != PHAuthorizationStatus.Authorized) {
            showAlert("Use Images from Photos?", message: "Splat needs access to your photos so you can upload from your camera roll", yesTitle: "Yes", noTitle: "Later")
            return false
        }
        /* Authorized photos access */
        return true
    }
    
    func showAlert(title: String, message: String, yesTitle: String, noTitle: String) {
        var alertController = UIAlertController (title: title, message: message, preferredStyle: .Alert)
        
        var settingsAction = UIAlertAction(title: yesTitle, style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        var cancelAction = UIAlertAction(title: noTitle, style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        self.presentViewController(alertController, animated: true, completion: nil);
    }
    
    override func keyboardWillShow(notification: NSNotification)
    {
        super.keyboardWillShow(notification)
        
        if enlargedReplyView.isFirstResponder() {
            if let info = notification.userInfo {
                var frame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
                scrollToY(-frame.height, self.view)
                
            }
        }
        
    }
    
    override func keyboardWillHide(notification: NSNotification)
    {
        super.keyboardWillHide(notification)
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
            if (enlargedReplyView.isFirstResponder()) {
                enlargedReplyView.resignFirstResponder()
            }
    }
    
    ///allows touch events to pass through
    class PostScrollView: UIScrollView {
        override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
            super.touchesBegan(touches, withEvent: event)
            super.nextResponder()?.touchesBegan(touches, withEvent: event)
        }
    }
    
}