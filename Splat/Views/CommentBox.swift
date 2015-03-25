//
//  CommentBox.swift
//  Splat
//
//  Created by Aaron Tainter on 3/16/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

class CommentBox: ContainerView {
    
    let caretSize: CGFloat = 10
    
    var textView: UITextView!
    var textViewDelegate: UITextViewDelegate!
    var parent: ResponsiveTextFieldViewController!
    
    private var caret: Caret!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        self.backgroundColor = UIColor.clearColor()
        
        textView = UITextView(frame: CGRectMake(0, 0+caretSize, self.frame.width, self.frame.height-caretSize))
        textView.font = UIFont.systemFontOfSize(16.0)
        textView.returnKeyType = UIReturnKeyType.Done
        textView.delegate = self.textViewDelegate
        
        caret = Caret(frame: CGRectMake(0, 0, 2*caretSize, caretSize), color: UIColor.whiteColor())
        caret.center = CGPointMake(3*self.frame.width/4, caretSize/2)
        
        self.addSubview(textView)
        self.addSubview(caret)
    }
    
    func getComment() -> String! {
        return textView.text
    }
    
    private class Caret : UIView {
        
        var triColor: UIColor = UIColor.clearColor()
        
        override init() {
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
            p.moveToPoint(CGPointMake(0,self.frame.height))
            p.addLineToPoint(CGPointMake(self.frame.width, self.frame.height))
            p.addLineToPoint(CGPointMake(self.frame.width/2, 0))
            p.fill()
            
        }
        
        
        
    }

}