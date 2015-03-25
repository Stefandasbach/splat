//
//  PostCell.swift
//  Splat
//
//  Created by Aaron Tainter on 3/17/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import Parse

class PostCell: UITableViewCell {
    
    var timeCreatedLabel: UILabel!
    var Comment: UITextView!
    var flagButton: UIButton!
    var voteSelector: VoteSelector!
    var Image : UIImageView!
    let imageTag = 3
    
    var actInd: UIActivityIndicatorView!
    
    let cellHeight:CGFloat = 150
    
    var currentPost: Post!
    
    //this is an error workaround...
    let cellWidth = UIScreen.mainScreen().applicationFrame.width
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        renderCell()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        renderCell()
    }
    
    func renderCell() {
        //upvote/downvote buttons
        let padding = 50
        let width   = 40 as CGFloat
        let height  = 40 as CGFloat
        
        voteSelector = VoteSelector(frame: CGRectMake(cellWidth-width, 10, width, cellHeight-20))
        self.addSubview(voteSelector)
        
        //image
        let imageWidth  = 150 as CGFloat
        let imageHeight = 150 as CGFloat
        Image = UIImageView(frame: CGRectMake(0, 0, imageWidth, imageHeight))
        Image.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        Image.contentMode = UIViewContentMode.ScaleAspectFill
        Image.clipsToBounds = true
        self.addSubview(Image)
        
        //add loading circle
        actInd = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.Gray)
        actInd.frame = Image.frame
        
        Image.addSubview(actInd)
        actInd.hidesWhenStopped = true;
        
        //flag button
        let flagSize = 40 as CGFloat
        flagButton = FlagButton(frame: CGRectMake(Image.frame.maxX + 10, cellHeight-flagSize, flagSize, flagSize))
        self.addSubview(flagButton)
        
        //Comment
        Comment = UITextView()
        Comment.frame = CGRectMake(imageWidth + 10, 0, cellWidth - Image.frame.width - voteSelector.frame.width, cellHeight-flagButton.frame.height)
        Comment.userInteractionEnabled = false
        Comment.font = UIFont.systemFontOfSize(12.0)
        //if smaller cell
        if (cellWidth == 320) {
            Comment.font = UIFont.systemFontOfSize(9.0)
        }
        self.addSubview(Comment)
        
        //time created
        timeCreatedLabel = UILabel()
        timeCreatedLabel.frame = CGRectMake(voteSelector.frame.minX-40, flagButton.frame.minY, 100, 40)
        timeCreatedLabel.textColor = UIColorFromRGB(PURPLE_UNSELECTED)
        timeCreatedLabel.font = UIFont.systemFontOfSize(14.0)
        var clockImg = UIImageView(frame: CGRectMake(0, 12.5, 15, 15))
        //Add Icon
        clockImg.image = UIImage(named: "clockIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        clockImg.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        
        timeCreatedLabel.addSubview(clockImg)
        self.addSubview(timeCreatedLabel)
        
    }
    
    func initialize(post: Post) {
        
        //self.Image.image = nil
        voteSelector.initialize(post)
        self.actInd.startAnimating()
        post.getEventPicture { (imageData) -> Void in
            self.actInd.stopAnimating()
            self.Image.image = UIImage(data: imageData)
        }
        
        Comment.text = post.getComment()
        
        
        var eventCreatedDate = post.object.createdAt
        var today = NSDate()
        
        let timeSincePost = getStringTimeDiff(eventCreatedDate, today)
        timeCreatedLabel.text = "     \(timeSincePost.number)\(timeSincePost.unit)"
        
        currentPost = post
        
        updateHighlighted()
    }
    
    func cancelLoad() {
        currentPost.cancelPictureGet()
    }
    
    func updateHighlighted() {
        //highlight selected
        voteSelector.updateHighlighted()
        
        var flags = NSUserDefaults.standardUserDefaults().objectForKey("SplatFlags") as NSArray!
        if let oID = currentPost.object.objectId {
            
            if (flags != nil && flags.containsObject(oID)) {
                flagButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
            } else {
                flagButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
            }
        }

    }
    
}
