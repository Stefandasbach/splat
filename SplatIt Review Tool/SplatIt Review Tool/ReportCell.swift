//
//  ReportCell.swift
//  SplatIt Review Tool
//
//  Created by Aaron Tainter on 5/11/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import UIKit
import Parse


class ReportCell: UITableViewCell {
    
    var postImageView: UIImageView!
    var reportCount: UILabel!
    
    var cellWidth = UIScreen.mainScreen().applicationFrame.width
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        renderCell()
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        renderCell()
    }
    
    func renderCell() {
        postImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        postImageView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.addSubview(postImageView)
        
        reportCount = UILabel(frame: CGRect(x: cellWidth - 100, y: 0, width: 100, height: 100))
        reportCount.textAlignment = NSTextAlignment.Center
        self.addSubview(reportCount)
    }
    
    func initialize(obj: PFObject, number: Int) {
        
        reportCount.text = "\(number)"
        
        if let image = obj["pictureFile"] as? PFFile {
            postImageView.image = nil
            image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let pictureData = data {
                    self.postImageView.image = UIImage(data: pictureData)
                }
            })
        } else {
            println("No Image")
        }
        
    }
}