//
//  CustomViews.swift
//  Splat
//
//  Created by Aaron Tainter on 3/15/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class ContainerView: UIView {
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
    }
}

class Form: ContainerView {
    /// This function submits the form.
    /// The super method checks validate and returns if False.
    ///
    ///:returns: True if the form is submitted, False if it is not.
    func submit() -> Bool {
        if (!self.validate()) {
            return false;
        }
        
        return true;
    }
    
    /// This function is used to validate the form elements before submitting.
    /// The super method returns True always.
    ///
    /// :returns: True if the form is validated, False if it is not.
    func validate() -> Bool {
        return true;
    }
}

class FormScrollable: UIScrollView {
    /// This function submits the form.
    /// The super method checks validate and returns if False.
    ///
    ///:returns: True if the form is submitted, False if it is not.
    func submit() -> Bool {
        if (!self.validate()) {
            return false;
        }
        
        return true;
    }
    
    /// This function is used to validate the form elements before submitting.
    /// The super method returns True always.
    ///
    /// :returns: True if the form is validated, False if it is not.
    func validate() -> Bool {
        return true;
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
    }
    
}
