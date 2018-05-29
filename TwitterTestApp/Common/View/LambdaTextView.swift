//
//  LambdaTextEditView.swift
//  SupportApp
//
//  Created by 椎名陽介 on 2018/03/12.
//  Copyright © 2018年 椎名陽介. All rights reserved.
//

import UIKit

class LambdaTextView : UITextView, UITextViewDelegate {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    var delegateShouldBeginEditing: (() -> Bool)?
    var delegateShouldEndEditing: (() -> Bool)?
    var delegateDidBeginEditing: (() -> Void)?
    var delegateDidEndEditing: (() -> Void)?
    var delegateShouldChangeTextIn: ((NSRange,String) -> Bool)?
    var delegateDidChange: (() -> Void)?
    var delegateDidChangeSelection: (() -> Void)?
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if delegateShouldBeginEditing != nil {
            return delegateShouldBeginEditing!()
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if delegateShouldEndEditing != nil {
            return delegateShouldEndEditing!()
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) -> Void {
        if delegateDidBeginEditing != nil {
            return delegateDidBeginEditing!()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) -> Void {
        if delegateDidEndEditing != nil {
            return delegateDidEndEditing!()
        }
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        if delegateShouldChangeTextIn != nil {
            return delegateShouldChangeTextIn!(range,text)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) -> Void {
        if delegateDidChange != nil {
            return delegateDidChange!()
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) -> Void {
        if delegateDidChangeSelection != nil {
            return delegateDidChangeSelection!()
        }
    }

    
//    - (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0);
//    - (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0);

    
}
