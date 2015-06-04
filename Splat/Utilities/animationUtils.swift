//
//  animations.swift
//  ComS319Portfolio1
//
//  Created by Aaron Tainter on 2/7/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation

func fadeinSubview(fadingView: UIView, time: NSTimeInterval, container: UIView){
    fadingView.alpha = 0
    container.addSubview(fadingView)
    UIView.beginAnimations(nil, context: nil)
    UIView.setAnimationDuration(time)
    fadingView.alpha = 1.0
    UIView.commitAnimations()
}

func fadeoutSubview(fadingView: UIView, time: NSTimeInterval, container: UIView){
    
    UIView.animateWithDuration(time, animations: {
        fadingView.alpha = 0.0},
        completion: {(value: Bool) in
            fadingView.removeFromSuperview()
    })
}

func fadeinSublayer(fadingView: UIView, time: NSTimeInterval, container: UIView){
    fadingView.alpha = 0
    container.layer.addSublayer(fadingView.layer)
    UIView.beginAnimations(nil, context: nil)
    UIView.setAnimationDuration(time)
    fadingView.alpha = 1.0
    UIView.commitAnimations()
}

func fadeoutSublayer(fadingView: UIView, time: NSTimeInterval, container: UIView){
    
    UIView.animateWithDuration(time, animations: {
        fadingView.alpha = 0.0},
        completion: {(value: Bool) in
            fadingView.layer.removeFromSuperlayer()
    })
}

func scrollToY(y: CGFloat, view: UIView) {
    
    UIView.beginAnimations("registerScroll", context: nil)
    UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
    UIView.setAnimationDuration(0.2)
    view.transform = CGAffineTransformMakeTranslation(0, y)
    UIView.commitAnimations()
    
}

func scrollToView(scrollToView: UIView, view: UIView) {
    let theFrame = scrollToView.frame
    var y = theFrame.origin.y - 10
    y -= (y/3)
    scrollToY(-y, view)
}

func scrollElement(scrollToView: UIView, y: CGFloat, view: UIView) {
    let theFrame = scrollToView.frame
    let origin_y = theFrame.origin.y
    let diff = y - origin_y
    if diff < 0 {
        scrollToY(diff, view)
    } else {
        scrollToY(0, view)
    }
}

func animateVoteButton(button:UIButton) {
    UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
        
        button.transform = CGAffineTransformMakeScale(1.5, 1.5)
        
        }, completion: { finished in
            UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                
                button.transform = CGAffineTransformMakeScale(1.0, 1.0)
                
                }, completion: nil)
            
    })
}




