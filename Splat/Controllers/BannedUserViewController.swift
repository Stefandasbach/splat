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
    var TitleLabel: UILabel!
    var BannedLabel: UILabel!
    var PolicyButton: UIButton!
    
    let padding:CGFloat = 10
    let screenWidth:CGFloat = UIScreen.mainScreen().applicationFrame.width
    let screenHeight:CGFloat = UIScreen.mainScreen().applicationFrame.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navbar = self.navigationController?.navigationBar {
            navbar.translucent = false
        }
        self.navigationItem.hidesBackButton = true
        
        addToolbarTitle("SplatIt")
        addBannedLabel("You have been banned for violating the SplatIt Policy. To appeal your ban please send an email to support@SplatIt.ninja")
        addPolicyButton("Policy")
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func addToolbarTitle(title: String) {
        TitleLabel = UILabel()
        TitleLabel.text = title
        TitleLabel.font = UIFont(name: "Pacifico", size: 20.0)
        TitleLabel.textColor = UIColor.whiteColor()
        TitleLabel.sizeToFit()
        self.navigationItem.titleView = TitleLabel
    }
    
    func addBannedLabel(text: String) {
        let SBHeight:   CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height as CGFloat!
        
        
        let labelWidth: CGFloat = screenWidth - (2 * padding)
        let labelHeight:CGFloat = 150
        
        BannedLabel = UILabel()
        BannedLabel.textAlignment = .Left
        /* Don't add in SBHeight to push text up towards top */
        BannedLabel.frame = CGRectMake(padding, 0, labelWidth, labelHeight)
        BannedLabel.text = text
        /* Align towards top */
        BannedLabel.numberOfLines = 0
        BannedLabel.font = UIFont.systemFontOfSize(15)
        self.view.addSubview(BannedLabel)
    }
    
    func addPolicyButton(text: String) {
        let buttonWidth: CGFloat = screenWidth - (2 * padding)
        let buttonHeight:CGFloat = 50
        
        var TBHeight: CGFloat
        if let navbar = self.navigationController?.toolbar {
            TBHeight = navbar.frame.height as CGFloat!
        } else {
            TBHeight = 0
        }
        
        PolicyButton = UIButton()
        PolicyButton.frame = CGRectMake(padding, screenHeight - (buttonHeight + padding + TBHeight), buttonWidth, buttonHeight)
        PolicyButton.layer.masksToBounds = true
        PolicyButton.layer.cornerRadius = 10.0
        PolicyButton.backgroundColor = UIColorFromRGB(PURPLE_SELECTED)
        PolicyButton.setTitle(text, forState: .Normal)
        PolicyButton.titleLabel!.font = UIFont.boldSystemFontOfSize(18)
        
        PolicyButton.addTarget(self, action: "policyButtonListener:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(PolicyButton)
    }
    
    func policyButtonListener(sender: UIButton) {
        let alert = UIAlertView(title: "SplatIt Policy", message: "While SplatIt is for mature audiences, posting content that contains excessively objectionable or crude content is prohibited. Content that is defamatory, offensive, or intended to bully individuals or parties will be removed and the user that posted said content will be suspended. Users that post frequently pornographic material will be suspended. Users can flag objectionable content to remove it and prevent a user from further posting objectionable content. Create the SplatIt community you want to see by upvoting & downvoting content and flagging inappropriate content.", delegate: self, cancelButtonTitle: "Got it")
        alert.show()
    }
}