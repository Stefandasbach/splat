//
//  CaretSelectorBar.swift
//  ComS319Portfolio1
//
//  Created by Aaron Tainter on 3/3/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation

protocol CaretSelectorDelegate {
    func caretSelectorBar(didSelectItem item: String?) -> (Void)
}

class CaretSelectorBar: UIControl {
    
    //Private Variables
    private var eventTypeContainer: UIView!
    private var buttonContainer: ContainerView!
    
    private var caretSelector: Caret!
    
    //Public Variables
    var delegate: CaretSelectorDelegate!
    
    var buttonItems: [String]!
    var selectedItem: UIButton!
    
    var caretSize: CGFloat = 5
    
    var textPadding: CGFloat = 0;
    
    var textSize: CGFloat = 16
    var barColor: UIColor = UIColorFromRGB(PURPLE_SELECTED)
    var selectedColor: UIColor = UIColor.whiteColor()
    var unselectedColor: UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    
    var font:UIFont! = UIFont.boldSystemFontOfSize(16.0)
    
    
    init(frame: CGRect, items: [String]) {
        super.init(frame: frame)
        self.userInteractionEnabled = true
        self.buttonItems = items
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        draw()
    }
    
    //draws the view
    private func draw() {
        let eventTypeContainerFrame = CGRectMake(0, 0, self.frame.width, self.frame.height-caretSize)
        
        eventTypeContainer = UIView(frame: eventTypeContainerFrame)
        eventTypeContainer.backgroundColor = barColor
        
        buttonContainer = ContainerView(frame: eventTypeContainerFrame)
        var xlocCur:CGFloat = 0;
        
        for item in buttonItems {
            var button = UIButton()
            
            button.setTitle(item, forState: UIControlState.Normal)
            button.frame.origin.x = xlocCur
            button.sizeToFit()
            button.frame.size.height = eventTypeContainer.frame.height
            button.titleLabel?.font = font
            button.setTitleColor(selectedColor, forState: UIControlState.Selected)
            button.setTitleColor(unselectedColor, forState: UIControlState.Normal)
            button.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            if (selectedItem == nil) {
                selectedItem = button
                button.selected = true
            }
            
            buttonContainer.addSubview(button)
            
            xlocCur = button.frame.maxX + textPadding
            
        }
        
        //set size to fit
        buttonContainer.frame = CGRectMake(0, 0, xlocCur - textPadding, eventTypeContainer.frame.height)
        
        self.addSubview(eventTypeContainer)
        buttonContainer.center = eventTypeContainer.center
        self.addSubview(buttonContainer)
        
        //add the caret
        addCaret(selectedItem)
    }
    
    //button press listener
    func buttonPressed(sender: UIButton) {
        
        //select the button
        for subview in buttonContainer.subviews {
            if let button = subview as? UIButton {
                if sender == button {
                    sender.selected = true;
                    selectedItem = sender
                    addCaret(selectedItem)
                    
                } else {
                    button.selected = false;
                }
            }
        }
        
        //run the delegate
        if let del = self.delegate {
            del.caretSelectorBar(didSelectItem: sender.titleLabel?.text)
        }
    }
    
    //changes caret selector
    private func addCaret(button: UIButton) {
        if (caretSelector != nil) {
            caretSelector.removeFromSuperview()
        }
        
        caretSelector = Caret(frame: CGRectMake(0, 0, 2*caretSize, caretSize), color: barColor)
        caretSelector.center = buttonContainer.convertPoint(button.center, toView: self)
        caretSelector.center.y = self.frame.height-caretSize/2
        self.addSubview(caretSelector)
    }
    
    private class Caret : UIView {
        
        var triColor: UIColor = UIColor.clearColor()
        
        init() {
            super.init(frame:CGRectZero)
            self.opaque = false
        }
        
        required init(coder: NSCoder) {
            fatalError("NSCoding not supported")
        }
        
        override init(frame: CGRect) {
            super.init(frame:frame)
            self.opaque = false
        }
        
        init(frame: CGRect, color: UIColor) {
            triColor = color
            super.init(frame:frame)
            self.opaque = false
        }
        
        override func drawRect(rect: CGRect) {
            let p = UIBezierPath()
            
            triColor.set()
            p.removeAllPoints()
            p.moveToPoint(CGPointMake(0,0))
            p.addLineToPoint(CGPointMake(self.frame.width, 0))
            p.addLineToPoint(CGPointMake(self.frame.width/2, self.frame.height))
            p.fill()
            
        }
        
        
        
    }
    
}

