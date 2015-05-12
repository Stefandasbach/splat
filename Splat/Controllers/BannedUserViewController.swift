//
//  BannedUserViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 5/12/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import UIKit

class BannedUserViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(PURPLE_SELECTED)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}