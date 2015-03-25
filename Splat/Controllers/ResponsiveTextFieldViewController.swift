//
//  ResponsiveTextFieldViewController.swift
//  Splat
//
//  Created by Aaron Tainter on 3/10/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation
import UIKit


///This class is used for adjusting views for use with a keyboard
///It also can be used to retrieve values from the uidatepicker
///Additionally, a toolbar is added above the view to easily end text editing
class ResponsiveTextFieldViewController : UIViewController
{

    var kPreferredTextFieldToKeyboardOffset: CGFloat = 20.0
    var keyboardFrame: CGRect = CGRect.nullRect
    var keyboardIsShowing: Bool = false
    weak var activeTextField: UITextField?
    weak var activeTextView: UITextView?
    
    var keyboardToolbar: UIToolbar!
    
    override init() {
        super.init()
        initializeView()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initializeView()
    }
    
    func initializeView() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeKeyboard", name: "RemoveKeyboard", object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        activeTextView = nil
        activeTextField = nil
    } 
    
    deinit {
         NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func keyboardWillShow(notification: NSNotification)
    {
        
        self.keyboardIsShowing = true
        
        if let info = notification.userInfo {
            self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            self.arrangeViewOffsetFromKeyboard()
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.keyboardIsShowing = false
        
        self.returnViewToInitialFrame()
    }
    
    func arrangeViewOffsetFromKeyboard()
    {
        if (self.activeTextField != nil) {
            var scrollView = UIView()
            scrollView.frame.origin = self.activeTextField!.convertPoint(CGPointMake(0, 0), toCoordinateSpace: self.view)
            scrollToView(scrollView, self.view)
        }
        if (self.activeTextView != nil) {
           var scrollView = UIView()
            scrollView.frame.origin = self.activeTextView!.convertPoint(CGPointMake(0, 0), toCoordinateSpace: self.view)
            scrollToView(scrollView, self.view)
        }
    }
    
    func returnViewToInitialFrame()
    {
        scrollToY(0, self.view)

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        removeKeyboard()
    }
    
    func donePressedListener() {
        removeKeyboard()
    }
    
    func removeKeyboard() {
        
        if (self.activeTextField != nil)
        {
            self.activeTextField?.resignFirstResponder()
            self.activeTextField = nil
        }
        
        if(self.activeTextView != nil) {
            self.activeTextView?.resignFirstResponder()
            self.activeTextView = nil
        }
    }
    
    func getDatePickerData(textField: UITextField?) {
        var datePicker = textField?.inputView as UIDatePicker
        var date = datePicker.date
        var dateFormatter = NSDateFormatter()
        
        textField?.text = dateFormatter.stringFromDate(date)
    }
    
    func textFieldDidReturn(textField: UITextField!)
    {
        textField.resignFirstResponder()
        self.activeTextField = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if ((textField.inputView?.isKindOfClass(UIDatePicker)) != nil)
        {
            getDatePickerData(textField)
        }
        
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField!)
    {
        
        if(self.activeTextView != nil) {
            self.activeTextView = nil
        }
        
        self.activeTextField = textField
        
        if(self.keyboardIsShowing)
        {
            self.arrangeViewOffsetFromKeyboard()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView!) {
        
    }
    
    func textViewDidBeginEditing(textView: UITextView!) {
        
        if (self.activeTextField != nil)
        {
            self.activeTextField = nil
        }
        
        self.activeTextView = textView
        
        if(self.keyboardIsShowing)
        {
            self.arrangeViewOffsetFromKeyboard()
        }
    }

}

