//
//  RegisterController.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 3/1/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class RegisterViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, AuthenticationManagerDelegate {
    
    // MARK: - Properties

    // Auth manager
    var authManager = AuthenticationManager()
    
    // Segue identifier
    let MAINAPP_SEGUE_IDENTIFIER = "goToMainApp"
    
    
    // Logo ImageView
    @IBOutlet weak var logoImageView: UIImageView!
    
    // Username TextField
    @IBOutlet weak var emailTextField: UITextField!
    
    // Password TextField
    let EYE_OPEN_IMAGE_NAME = "eyeIcon"
    let EYE_CLOSED_IMAGE_NAME = "notEyeIcon"
    let HIDE_BUTTON_TEXT_OFFSET : CGFloat = 5.0
    @IBOutlet weak var HIDE_PASSWORD_BUTTON_HORIZONTAL_OFFSET: NSLayoutConstraint!
    @IBOutlet weak var HIDE_PASSWORD_BUTTON_VERTICAL_OFFSET: NSLayoutConstraint!
    @IBOutlet weak var hidePasswordButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextFieldPadding!
    @IBOutlet weak var passwordLabel: UILabel!

    // Register Button
    let REGISTER_BUTTON_ENABLED_ALPHA : CGFloat = 0.8
    let REGISTER_BUTTON_DISABLED_ALPHA : CGFloat = 0.2
    @IBOutlet weak var registerButton: UIButton!
    
    // Keyboard layout adjustments
    let REGISTERBUTTON_KEYBOARD_OFFSET : CGFloat = 10.0
    let LAYOUT_FOR_KEYBOARD_ANIM_TIME : TimeInterval = 0.15
    var REGISTERBUTTON_DEFAULT_MAXY : CGFloat = 0.0 // must be fetched on viewDidLoad
    var DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT : CGFloat = 0.0 // must be fetched on viewDidLoad
    var currentConstraintConstant : CGFloat = 0.0 // must be fetched on viewDidLoad
    @IBOutlet weak var abovePositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var belowPositionConstraint: NSLayoutConstraint!
    
    ////////////////////////////////////////////////////
    //MARK: - viewDidLoad and viewWillLoad methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConfigureAuthManager()
        ConformToProtocols()
        UpdateConfirmButton(if : CanConfirm())
        LayoutPassWordTextField()
        AddToNotificationObservers()
        GetConstants()
        SetHideKeyboardWhenTapped()
    }
    
    fileprivate func ConfigureAuthManager() {
        authManager.emailTextField = emailTextField
        authManager.passwordTextField = passwordTextField
        authManager.passwordLabel = passwordLabel
    }
    
    fileprivate func ConformToProtocols() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        authManager.delegate = self
    }
    
    fileprivate func AddToNotificationObservers() {
        // usernameTextField change text notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange(_:)),
                                               name: UITextField.textDidChangeNotification,
                                               object: emailTextField)
        
        // passwordTextField change text notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange(_:)),
                                               name: UITextField.textDidChangeNotification,
                                               object: passwordTextField)
        
        // keyboardWillShow notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UITextField.keyboardWillShowNotification,
                                               object: nil)
        
        // keyboardWillHide notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UITextField.keyboardWillHideNotification,
                                               object: nil)
    }
    
    fileprivate func LayoutPassWordTextField() {
        passwordTextField.padding.right = passwordTextField.frame.height
            - 2*HIDE_PASSWORD_BUTTON_VERTICAL_OFFSET.constant
            - HIDE_PASSWORD_BUTTON_HORIZONTAL_OFFSET.constant
            - HIDE_BUTTON_TEXT_OFFSET
    }
    
    fileprivate func GetConstants() {
        REGISTERBUTTON_DEFAULT_MAXY = view.convert(registerButton.frame, from: registerButton.superview!).maxY
        DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT = abovePositionConstraint.constant
        currentConstraintConstant = DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT
    }
    
    ////////////////////////////////////////////////////
    // MARK: - Textfield Methods
    @IBAction func hideButtonPressed(_ sender: Any) {
        var newImage : UIImage
        
        if passwordTextField.isSecureTextEntry {
            newImage = UIImage(named: EYE_OPEN_IMAGE_NAME)!
        } else {
            newImage = UIImage(named: EYE_CLOSED_IMAGE_NAME)!
        }
        hidePasswordButton.setImage(newImage, for: .normal)
        passwordTextField.TogglePasswordVisibility()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isSecureTextEntry { textField.PreventSecureEntryClearing() }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            if CanConfirm() {
                registerButton.sendActions(for: .touchUpInside)
            }
        }
        return true
    }
    
    @objc func textDidChange(_ notification : Notification) {
        UpdateConfirmButton(if : CanConfirm())
    }
    
    @objc func keyboardWillShow(_ notification : Notification) {
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let newConstant = GetNewConstant(using: keyboardFrame)
        if currentConstraintConstant != newConstant {
            LayoutViewForKeyboard(with: newConstant)
            currentConstraintConstant = newConstant
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if currentConstraintConstant != DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT {
            LayoutViewForKeyboard(with: DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT)
            currentConstraintConstant = DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT
        }
    }
    
    fileprivate func LayoutViewForKeyboard(with constant : CGFloat) {
        UIView.animate(withDuration: LAYOUT_FOR_KEYBOARD_ANIM_TIME) {
            self.abovePositionConstraint.constant = -constant
            self.belowPositionConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func GetNewConstant(using keyboardFrame : CGRect) -> CGFloat {
        let desiredMaxY = keyboardFrame.minY - REGISTERBUTTON_KEYBOARD_OFFSET
        return CGFloat.maximum(DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT,
                               REGISTERBUTTON_DEFAULT_MAXY - desiredMaxY
                )
    }
    
    ////////////////////////////////////////////////////
    // MARK: - Authenticate Methods
    @IBAction func registerPressed(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        authManager.CleanAlerts(passwordErrorCode: .weakPassword)
        authManager.RegisterWith(email, password)
    }

    ////////////////////////////////////////////////////
    // MARK: - Register Button Methods
    fileprivate func UpdateConfirmButton(if enabled : Bool) {
        if enabled {
            registerButton.alpha = REGISTER_BUTTON_ENABLED_ALPHA
            registerButton.isEnabled = true
        } else {
            registerButton.alpha = REGISTER_BUTTON_DISABLED_ALPHA
            registerButton.isEnabled = false
        }
    }
    
    fileprivate func CanConfirm() -> Bool {
        return emailTextField.text! != "" && passwordTextField.text! != ""
    }
    
    ////////////////////////////////////////////////////
    // MARK: - Views Navigation Mehods
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    ////////////////////////////////////////////////////
    // MARK: - Auth Manager delegate methods
    func UserDidAuthenticate() {
        performSegue(withIdentifier: MAINAPP_SEGUE_IDENTIFIER, sender: self)
    }
    
    func ShowAlert(vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
    
    func DismissAlertsVC() {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    ////////////////////////////////////////////////////
    // MARK: - Gesture Recognizer delegate methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let viewTouched = touch.view, viewTouched.isEqual(hidePasswordButton) { return false }
        return true
    }
    
    ////////////////////////////////////////////////////
    // MARK: - Miscellaneous methods
    fileprivate func DismissKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
}

