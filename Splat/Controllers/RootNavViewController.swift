//
//  ViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/3/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import UIKit
import Foundation
import Parse

class RootNavViewController: UINavigationController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var bottomToolbar: UITabBar!
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(navigationBarClass: AnyClass!, toolbarClass: AnyClass!) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationBar.barTintColor = UIColorFromRGB(PURPLE_SELECTED)
        renderElements()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce")) {
            // app already launched
        } else
        {
            self.presentViewController(TutorialViewController(), animated: true, completion: nil)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            // This is the first launch ever
        }

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderElements() {
        //may re-add this in the future
        
       /* bottomToolbar = UITabBar(frame: CGRectMake(0, self.view.frame.height-49, self.view.frame.width, 49))
        bottomToolbar.translucent = false
        bottomToolbar.barTintColor = UIColorFromRGB(TOOLBAR_GREY)
        bottomToolbar.shadowImage = UIImage()
        bottomToolbar.backgroundImage = UIImage()
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(self.view.frame.width, 0))
        
        //create shape from path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = UIColorFromRGB(PURPLE_SELECTED).CGColor
        shapeLayer.lineWidth = 0.8
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        
        bottomToolbar.layer.addSublayer(shapeLayer)
        
        self.view.addSubview(bottomToolbar) */
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func disableBottomToolbar() {
        if (bottomToolbar != nil) {
            bottomToolbar.removeFromSuperview()
        }
    }
    
    func enableBottomToolbar() {
        if (bottomToolbar != nil) {
            self.view.addSubview(bottomToolbar)
        }
    }
    
    enum Direction {
        case Left
        case Right
    }
    func pushVC(direction: Direction, viewController: UIViewController) {
        switch direction {
        case .Left:
            var animation = CATransition()
            animation.duration = 0.35
            animation.type = kCATransitionPush
            animation.subtype = kCATransitionFromRight
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            self.view.layer.addAnimation(animation, forKey: nil)
            
            self.pushViewController(viewController, animated: false)
        case .Right:
            /* Attempt to fix */
//            let width = UIScreen.mainScreen().bounds.width
//            viewController.view.frame = CGRectOffset(viewController.view.frame, width, 0)
//            UIView.animateWithDuration(0.5, animations: {
//                viewController.view.frame = CGRectOffset(viewController.view.frame, -width, 0)
//            })
            
            /* Animation with fade */
            var animation = CATransition()
            animation.duration = 0.35
            animation.type = kCATransitionPush
            animation.subtype = kCATransitionFromLeft
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            self.view.layer.addAnimation(animation, forKey: nil)
            
            self.pushViewController(viewController, animated: false)
        }
    }
    func popVC(direction: Direction) -> UIViewController{
        switch direction {
        case .Left:
            var animation = CATransition()
            animation.duration = 0.35
            animation.type = kCATransitionPush
            animation.subtype = kCATransitionFromRight
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            self.view.layer.addAnimation(animation, forKey: nil)
            
            return self.popViewControllerAnimated(false)!
        case .Right:
            var animation = CATransition()
            animation.duration = 0.35
            animation.type = kCATransitionPush
            animation.subtype = kCATransitionFromLeft
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            self.view.layer.addAnimation(animation, forKey: nil)
            
            return self.popViewControllerAnimated(false)!
        }
    }
    
}

