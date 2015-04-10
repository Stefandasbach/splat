//
//  CommentCell.swift
//  Splat
//
//  Created by Aaron Tainter on 3/23/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

//TODO:
import Foundation
class ReplyCell: UITableViewCell {
    
    var timeCreatedLabel: UILabel!
    var Comment: UITextView!
    var voteSelector: VoteSelector!
    var myImage : UIImageView!
    let imageTag = 3
    
    var actInd: UIActivityIndicatorView!
    
    let cellHeight:CGFloat = 100
    
    var currentReply: Reply!
    
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
        
        voteSelector = VoteSelector(frame: CGRectMake(cellWidth-width, 0, width, cellHeight))
        self.addSubview(voteSelector)
        
        //image
        let imageWidth  = cellHeight
        let imageHeight = cellHeight
        myImage = UIImageView(frame: CGRectMake(0, 0, imageWidth, imageHeight))
        myImage.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        myImage.contentMode = UIViewContentMode.ScaleAspectFill
        myImage.clipsToBounds = true
        self.addSubview(myImage)
        
        //add loading circle
        actInd = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.Gray)
        actInd.frame = myImage.frame
        
        myImage.addSubview(actInd)
        actInd.hidesWhenStopped = true;
        
        //time created
        timeCreatedLabel = UILabel()
        timeCreatedLabel.frame = CGRectMake(cellWidth/2, cellHeight-40, 100, 40)
        timeCreatedLabel.textColor = UIColorFromRGB(PURPLE_UNSELECTED)
        timeCreatedLabel.font = UIFont.systemFontOfSize(14.0)
        var clockImg = UIImageView(frame: CGRectMake(0, 12.5, 15, 15))
        //Add Icon
        clockImg.image = UIImage(named: "clockIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        clockImg.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        
        timeCreatedLabel.addSubview(clockImg)
        self.addSubview(timeCreatedLabel)
        
        //Comment
        Comment = UITextView()
        Comment.frame = CGRectMake(imageWidth + 10, 0, cellWidth - myImage.frame.width - voteSelector.frame.width, cellHeight-timeCreatedLabel.frame.height)
        Comment.userInteractionEnabled = false
        Comment.font = UIFont.systemFontOfSize(12.0)
        //if smaller cell
        if (cellWidth == 320) {
            Comment.font = UIFont.systemFontOfSize(9.0)
        }
        self.addSubview(Comment)
        
        
    }
    
    func initialize(reply: Reply) {
        
        //self.Image.image = nil
        voteSelector.initializeWithReply(reply)
        if (reply.hasPicture()) {
            self.myImage.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
             Comment.frame = CGRectMake(myImage.frame.maxX + 10, 0, cellWidth - myImage.frame.width - voteSelector.frame.width, cellHeight-timeCreatedLabel.frame.height)
            self.actInd.startAnimating()
            reply.getReplyPicture { (imageData) -> Void in
                self.actInd.stopAnimating()
                self.myImage.image = UIImage(data: imageData)
            }
        } else {
            self.myImage.backgroundColor = UIColor.clearColor()
            Comment.frame = CGRectMake(10, 0, cellWidth - voteSelector.frame.width, cellHeight-timeCreatedLabel.frame.height)
        }
        
        Comment.text = reply.getComment()
        
        
        var eventCreatedDate = reply.object.createdAt
        var today = NSDate()
        
        let timeSincePost = getStringTimeDiff(eventCreatedDate!, today)
        timeCreatedLabel.text = "     \(timeSincePost.number)\(timeSincePost.unit)"
        
        currentReply = reply
        
        updateHighlighted()
    }
    
    func cancelLoad() {
        currentReply.cancelPictureGet()
    }
    
    func updateHighlighted() {
        //highlight selected
        voteSelector.updateHighlighted()
        
    }
    
}

