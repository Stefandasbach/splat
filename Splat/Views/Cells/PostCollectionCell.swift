//
//  PostCollectionCell.swift
//  Splat
//
//  Created by Aaron Tainter on 4/13/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class PostCollectionCell: UICollectionViewCell {
    var imageView: UIImageView!
    var scoreLabel: UILabel!
    var actInd: UIActivityIndicatorView!
    
    var currentPost: Post!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        renderCell()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        renderCell()
    }
    
    func renderCell() {
        imageView = UIImageView(frame: self.frame)
        imageView.frame.origin.x = 0
        imageView.frame.origin.y = 0
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        //add loading circle
        actInd = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.Gray)
        actInd.frame = imageView.frame
        
        imageView.addSubview(actInd)
        actInd.hidesWhenStopped = true;
        
        scoreLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 50, height: 20))
        scoreLabel.textColor = UIColorFromRGB(PURPLE_SELECTED)
        scoreLabel.backgroundColor = UIColor.whiteColor()
        scoreLabel.layer.cornerRadius = 10
        scoreLabel.font = UIFont.boldSystemFontOfSize(18.0)
        scoreLabel.clipsToBounds = true
        scoreLabel.textAlignment = NSTextAlignment.Center
        
        
        self.addSubview(imageView)
        self.addSubview(scoreLabel)
    }
    
    func initialize(post: Post) {
        currentPost = post
        
        imageView.image = nil
        if (currentPost.hasPicture()) {
            self.actInd.startAnimating()
            currentPost.getEventPicture{ (imageData) -> Void in
                self.actInd.stopAnimating()
                self.imageView.image = UIImage(data: imageData)
            }
        }
        
        scoreLabel.text = "\(currentPost.getScore())"
        scoreLabel.sizeToFit()
        scoreLabel.frame.size.width += 10
        
    }
    
    func cancelLoad() {
        currentPost.cancelPictureGet()
    }
    
}