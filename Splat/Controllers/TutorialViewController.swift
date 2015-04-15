//
//  TutorialViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 4/14/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class TutorialViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var pageView:UIPageViewController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(PURPLE_SELECTED)
        initPageView()
    }
    
    func initPageView() {
        self.pageView = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        self.pageView.delegate = self
        self.pageView.dataSource = self
        self.pageView.view.frame = self.view.bounds
        
        self.pageView.setViewControllers([viewControllerAtIndex(0)], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        self.addChildViewController(self.pageView)
        self.view.addSubview(self.pageView.view)
        self.pageView.didMoveToParentViewController(self)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = 0
        if let tutorialVC = viewController as? TutorialPageViewController {
            index = tutorialVC.index
        }
        
        if (index == 0) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = 0
        if let tutorialVC = viewController as? TutorialPageViewController {
            index = tutorialVC.index
        }
        
        index++
        if (index == 4) {
            return nil;
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> TutorialPageViewController {
        var vc = TutorialPageViewController()
        vc.index = index
        if index == 3 {
            vc.parent = self
        }
        return vc
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}