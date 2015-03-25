//
//  PostPreviewViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/21/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class PostPreviewViewController: ResponsiveTextFieldViewController, UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate {
    
    var mainScrollView: UIScrollView!
    
    var currentPost: Post!
    var postImage: UIImageView!
    var commentText: UITextView!
    var voteSelector:VoteSelector!
    var flagButton: UIButton!
    var shareButton: UIButton!
    var timeCreatedLabel: UILabel!
    
    let maxCharacters = 200
    var numberCharactersLeft: Int!
    
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
        
        //scrollView
        if let navOffset = self.navigationController?.navigationBar.frame.maxY {
            mainScrollView = UIScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - navOffset))
        } else {
            mainScrollView = UIScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
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
        mainScrollView.addSubview(shareButton)
        
        //time created
        timeCreatedLabel = UILabel()
        timeCreatedLabel.frame = CGRectMake(mainScrollView.frame.width-80, flagButton.frame.minY, 60, 40)
        timeCreatedLabel.textColor = UIColorFromRGB(PURPLE_UNSELECTED)
        timeCreatedLabel.font = UIFont.systemFontOfSize(14.0)
        var clockImg = UIImageView(frame: CGRectMake(0, 12.5, 15, 15))
        //Add Icon
        clockImg.image = UIImage(named: "clockIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        clockImg.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        var eventCreatedDate = currentPost.object.createdAt
        var today = NSDate()
        
        let timeSincePost = getStringTimeDiff(eventCreatedDate, today)
        timeCreatedLabel.text = "     \(timeSincePost.number)\(timeSincePost.unit)"
        timeCreatedLabel.frame.origin = CGPoint(x: mainScrollView.frame.width - timeCreatedLabel.frame.width, y: flagButton.frame.minY)
        
        
        timeCreatedLabel.addSubview(clockImg)
        mainScrollView.addSubview(timeCreatedLabel)

        
        //Add line to break between replies
        var path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, ylocCursor))
        path.addLineToPoint(CGPointMake(self.view.frame.width, ylocCursor))
        
        //create shape from path
        var shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        shapeLayer.lineWidth = 0.8
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        
        mainScrollView.layer.addSublayer(shapeLayer)
        
        ylocCursor = ylocCursor + padding
        

        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.size.width, height: ylocCursor+padding)
        
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
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        var stringLength = countElements(textView.text)
        var textLength = countElements(text)
        var characters = stringLength + (textLength - range.length)
        
        if (characters <= maxCharacters) {
            numberCharactersLeft = maxCharacters - characters
        }
        return characters <= maxCharacters;
    }

    
    override func textViewDidEndEditing(textView: UITextView!) {
        super.textViewDidEndEditing(textView)
        commentText.editable = false
        
        //TODO: test
        currentPost.editComment(commentText.text, completion: { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("RefreshFeed", object: nil)
        })
        
    }
    
    func upvote(sender: UIButton) {
        if let post = currentPost {
            var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as NSArray!
            var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as NSArray!
            
            if var existingScore = voteSelector.Score.text?.toInt() {
            
                if let oID = post.object.objectId {
                    //if upvote already selected
                    if (upvotes != nil && upvotes.containsObject(oID)) {
                        //remove upvote
                        post.removeUpvote()
                        removeArchivedUpvote(post, oID, upvotes)
                        existingScore = existingScore - 1

                        //if downvote already selected
                    } else if (downvotes != nil && downvotes.containsObject(oID)) {
                        //remove downvote
                        post.removeDownvote()
                        removeArchivedDownvote(post, oID, downvotes)
                        existingScore = existingScore + 1
                        
                        archiveUpvote(post, oID, upvotes)
                        existingScore = existingScore + 1
                        
                        //nothing selected
                    } else {
                        archiveUpvote(post, oID, upvotes)
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
            var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as NSArray!
            var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as NSArray!
            
            if var existingScore = voteSelector.Score.text?.toInt() {
            
                if let oID = post.object.objectId {
                    //if downvote already selected
                    if (downvotes != nil && downvotes.containsObject(oID)) {
                        //remove downvote
                        post.removeDownvote()
                        removeArchivedDownvote(post, oID, downvotes)
                        existingScore = existingScore + 1
                        
                        //if Upvote already selected
                    } else if (upvotes != nil && upvotes.containsObject(oID)) {
                        //remove Upvote
                        post.removeUpvote()
                        removeArchivedUpvote(post, oID, upvotes)
                        existingScore = existingScore - 1
                        
                        archiveDownvote(post, oID, downvotes)
                        existingScore = existingScore - 1
                        
                        //nothing selected
                    } else {
                        archiveDownvote(post, oID, downvotes)
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
        var flags = NSUserDefaults.standardUserDefaults().objectForKey("SplatFlags") as NSArray!
        if let oID = post?.object.objectId {
            
            if (flags != nil && flags.containsObject(oID)) {
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
        var flags = NSUserDefaults.standardUserDefaults().objectForKey("SplatFlags") as NSArray!
        if let oID = currentPost.object.objectId {
            
            if (flags != nil && flags.containsObject(oID)) {
                flagButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
            } else {
                flagButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
            }
        }
    }
    
    //TODO:
    func share(sender: UIButton) {
        println("Share post here")
    }
    
    
}