//
//  ExtraInspectorButton.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/25/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UIButton {
    
    @IBInspectable
    var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

@IBDesignable
class UITextFieldPadding : UITextField {
    
    var padding = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 0)
    
    @IBInspectable
    var top : CGFloat {
        get { return padding.top }
        set { padding.top = newValue }
    }
    
    @IBInspectable
    var left : CGFloat {
        get { return padding.left }
        set { padding.left = newValue }
    }
    
    @IBInspectable
    var bottom : CGFloat {
        get { return padding.bottom }
        set { padding.bottom = newValue }
    }
    
    @IBInspectable
    var right : CGFloat {
        get { return padding.right }
        set { padding.right = newValue }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension UITextField {
    func TogglePasswordVisibility() {
        isSecureTextEntry.toggle()
        
        if let existingText = text, isSecureTextEntry {
            
            deleteBackward()
            
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }
        
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
}

extension UIViewController {
    func SetHideKeyboardWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
