//
//  VoteSelector.swift
//  Splat
//
//  Created by Aaron Tainter on 3/22/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class VoteSelector: ContainerView {
    var DownvoteButton : UIButton!
    var UpvoteButton : UIButton!
    var Score : UILabel!
    let scoreTag = 1
    
    var currentPost: Post!
    var currentReply: Reply!
    var rendered = false
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let width   = self.frame.width as CGFloat
        let height  = self.frame.width as CGFloat
        
        var caretImage = UIImage(named: "caretImage.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        var flippedCaretImage = UIImage(named: "caretImageFlipped.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        UpvoteButton = UIButton()
        UpvoteButton.setImage(caretImage, forState: UIControlState.Normal)
        UpvoteButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        UpvoteButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        DownvoteButton = UIButton()
        DownvoteButton.setImage(flippedCaretImage, forState: UIControlState.Normal)
        DownvoteButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        DownvoteButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        UpvoteButton.frame = CGRectMake(0, 0, width, height)
        DownvoteButton.frame = CGRectMake(0, self.frame.height - height, width, height)
        UpvoteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        UpvoteButton.contentVerticalAlignment   = UIControlContentVerticalAlignment.Center
        DownvoteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        DownvoteButton.contentVerticalAlignment   = UIControlContentVerticalAlignment.Center
        self.addSubview(UpvoteButton)
        self.addSubview(DownvoteButton)
        
        //score
        let widthScore  = 40 as CGFloat
        let heightScore = 20 as CGFloat
        Score = UILabel()
        Score.frame = CGRectMake(0, self.frame.height/2-heightScore/2, widthScore, heightScore)
        Score.textAlignment = NSTextAlignment.Center
        Score.text = "0"
        Score.tag = scoreTag
        Score.font = UIFont.boldSystemFontOfSize(18.0)
        Score.textColor = UIColorFromRGB(PURPLE_SELECTED)
        self.addSubview(Score)
        
        rendered = true
    }
    
    func initialize(post: Post) {
        if (rendered) {
            currentPost = post
            Score.text = "\(post.getScore())"
            updateHighlighted()
        }
    }
    
    func initialize(reply: Reply) {
        if (rendered) {
            currentReply = reply
            Score.text = "\(reply.getScore())"
            updateHighlighted()
        }
    }
    
    func updateHighlighted() {
        //highlight selected
     /*   var user = User()
        var upvotes = user.getUpvoted()
        if (upvotes?.containsObject(currentPost.getObject().objectId) == true) {
            UpvoteButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
        } else {
            UpvoteButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        }
        
        var downvotes = user.getDownvoted()
        if (downvotes?.containsObject(currentPost.getObject().objectId) == true) {
            DownvoteButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
        } else {
            DownvoteButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
        } */
        
        var upvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatUpvotes") as NSArray!
        if currentPost != nil {
            if let oID = currentPost.object.objectId {
                
                if (upvotes != nil && upvotes.containsObject(oID)) {
                    UpvoteButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
                } else {
                    UpvoteButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
                }
            }
        }
        else if currentReply != nil {
            if let oID = currentReply.object.objectId {
                if (upvotes != nil && upvotes.containsObject(oID)) {
                    UpvoteButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
                } else {
                    UpvoteButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
                }
            }
        }
        
        var downvotes = NSUserDefaults.standardUserDefaults().objectForKey("SplatDownvotes") as NSArray!
        if currentPost != nil {
            if let oID = currentPost.object.objectId {
                
                if (downvotes != nil && downvotes.containsObject(oID)) {
                    DownvoteButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
                } else {
                    DownvoteButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
                }
            }
        }
        else if currentReply != nil {
            if let oID = currentReply.object.objectId {
                if (downvotes != nil && downvotes.containsObject(oID)) {
                    DownvoteButton.tintColor = UIColorFromRGB(PURPLE_SELECTED)
                } else {
                    DownvoteButton.tintColor = UIColorFromRGB(PURPLE_UNSELECTED)
                }

            }
        }

        
    }
}
