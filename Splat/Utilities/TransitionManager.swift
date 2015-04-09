//
//  TransitionManager.swift
//  Splat
//
//  Created by Stefan Dasbach on 4/8/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import UIKit

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    enum SlideDirection {
        case Left
        case Right
    }
    
    func pushViewController(direction: SlideDirection, navigationController: UINavigationController, fromViewController: UIViewController, toViewController: UIViewController) {
        switch direction {
        case .Left: // Push motion
            navigationController.pushViewController(toViewController, animated: true)
        case .Right: // Pop motion
            var vcStack = NSMutableArray(array: navigationController.viewControllers! as [UIViewController])
            println("Before insert:\(vcStack)")
            vcStack.insertObject(toViewController, atIndex: vcStack.count-1)
            println("After insert:\(vcStack)")
            navigationController.setViewControllers(vcStack, animated: false)
            navigationController.popViewControllerAnimated(true)
            navigationController.setViewControllers(vcStack, animated: false)
            
            vcStack = NSMutableArray(array: navigationController.viewControllers! as [UIViewController])
            vcStack.insertObject(fromViewController, atIndex: vcStack.count-1)
            navigationController.setViewControllers(vcStack, animated: false)
        }
        
    }
    
    func popViewController(direction: SlideDirection, navigationController: UINavigationController) {
        switch direction {
        case .Left: // Push motion
            var vcStack = NSMutableArray(array: navigationController.viewControllers! as [UIViewController])
            println("vcStack before: \(vcStack)")
            if (vcStack.count < 2) {
                NSException(name: "Array index out of bounds", reason: "Too few ViewControllers on stack to pop. Push instead.", userInfo: nil).raise()
            }
            
            let toViewController = vcStack.objectAtIndex(vcStack.count-2) as UIViewController
            
            navigationController.popViewControllerAnimated(false)
            navigationController.popViewControllerAnimated(false)
            vcStack.removeObjectAtIndex(vcStack.count-1)
            vcStack.removeObjectAtIndex(vcStack.count-1)
            navigationController.setViewControllers(vcStack, animated: false)
            
//            navigationController.pushViewController(toViewController, animated: false)
            vcStack.addObject(toViewController)
            navigationController.setViewControllers(vcStack, animated: true)
            
//            vcStack = NSMutableArray(array: navigationController.viewControllers! as [UIViewController])
            
//            println("After:\(vcStack)")
        case .Right: // Pop motion
            navigationController.popViewControllerAnimated(true)
        }
        
    }
    


    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        

//        let fromView = transitionContext.viewForKey(UITransitionContextFromViewControllerKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let fromView = UIApplication.sharedApplication().keyWindow?.rootViewController?.view
        
        /* Set bounds as left of screen and right of screen*/
        let offScreenLeft = CGAffineTransformMakeTranslation(-container.frame.width, 0)
        let offScreenRight = CGAffineTransformMakeTranslation(container.frame.width, 0)
        
        /* Start left of screen */
        toView.transform = offScreenLeft
        
        container.addSubview(toView)
        container.addSubview(fromView!)
        
        let duration = self.transitionDuration(transitionContext)
        
        /* Slide fromView off to left, and pull toView in behind it */
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: nil, animations: {
                fromView!.transform = offScreenRight
                toView.transform = CGAffineTransformIdentity
            }, completion: { finished in
                /* We're finished the animation */
                transitionContext.completeTransition(true)
            }
        )
    }
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}