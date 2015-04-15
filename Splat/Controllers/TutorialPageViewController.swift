//
//  TutorialPageViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 4/14/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class TutorialPageViewController: UIViewController {
    var index = 0;
    var parent:UIViewController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(PURPLE_SELECTED
        )
        
        
        switch(index) {
        case 0:
            var imageView = UIImageView(frame: self.view.frame)
            imageView.image = UIImage(named: "tutorialScreenPage1.png")
            imageView.contentMode = .ScaleAspectFit
            self.view.addSubview(imageView)
            break
        case 1:
            var imageView = UIImageView(frame: self.view.frame)
            imageView.image = UIImage(named: "tutorialScreenPage2.png")
            imageView.contentMode = .ScaleAspectFit
            self.view.addSubview(imageView)
            break
        case 2:
            var imageView = UIImageView(frame: self.view.frame)
            imageView.image = UIImage(named: "tutorialScreenPage3.png")
            imageView.contentMode = .ScaleAspectFit
            self.view.addSubview(imageView)
            break
        case 3:
            var imageView = UIImageView(frame: self.view.frame)
            imageView.image = UIImage(named: "tutorialScreenPage4.png")
            imageView.contentMode = .ScaleAspectFit
            self.view.addSubview(imageView)
            var exitButton = UIButton(frame: CGRect(x: self.view.frame.width-110, y: self.view.frame.height-100, width: 100, height: 50))
            exitButton.contentHorizontalAlignment = .Center
            exitButton.setTitle("Let's Go!", forState: UIControlState.Normal)
            exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            exitButton.titleLabel?.font = UIFont.boldSystemFontOfSize(20.0)
            exitButton.addTarget(self, action: "exitButtonSelected", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(exitButton)
            break
        default:
            break
        }
        
    }
    
    func exitButtonSelected() {
        if (parent != nil) {
            parent.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}