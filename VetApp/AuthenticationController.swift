//
//  AuthenticationScreenController.swif
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/26/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit
import Firebase

class AuthenticationViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties

    // Segue identifier
    let MAINAPP_SEGUE_IDENTIFIER = "goToMainApp"
    let REGISTER_SEGUE_IDENTIFIER = "goToRegister"
    
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

    // Login Button
    let LOGIN_BUTTON_ENABLED_ALPHA : CGFloat = 0.8
    let LOGIN_BUTTON_DISABLED_ALPHA : CGFloat = 0.2
    @IBOutlet weak var loginButton: UIButton!

    // Keyboard layout adjustments
    let LOGIN_BUTTON_KEYBOARD_OFFSET : CGFloat = 10.0
    let LAYOUT_FOR_KEYBOARD_ANIM_TIME : TimeInterval = 0.15
    var LOGINBUTTON_DEFAULT_MAXY : CGFloat = 0.0 // must be fetched on viewDidLoad
    var DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT : CGFloat = 0.0 // must be fetched on viewDidLoad
    @IBOutlet weak var abovePositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var belowPositionConstraint: NSLayoutConstraint!
    
    ////////////////////////////////////////////////////
    //MARK: - viewDidLoad and viewWillLoad methods
    
    fileprivate func ConformToProtocols() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
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
        LOGINBUTTON_DEFAULT_MAXY = view.convert(loginButton.frame, from: loginButton.superview!).maxY
        DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT = abovePositionConstraint.constant
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ConformToProtocols()
        UpdateConfirmButton(if : CanConfirm())
        LayoutPassWordTextField()
        AddToNotificationObservers()
        GetConstants()
        SetHideKeyboardWhenTapped()
    }

    ////////////////////////////////////////////////////
    // MARK: - Textfield Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            if CanConfirm() {
                loginButton.sendActions(for: .touchUpInside)
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
        LayoutViewForKeyboard(with: newConstant)
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        LayoutViewForKeyboard(with : DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT)
    }
    
    fileprivate func LayoutViewForKeyboard(with constant : CGFloat) {
        UIView.animate(withDuration: LAYOUT_FOR_KEYBOARD_ANIM_TIME) {
            self.abovePositionConstraint.constant = -constant
            self.belowPositionConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func GetNewConstant(using keyboardFrame : CGRect) -> CGFloat {
        let desiredMaxY = keyboardFrame.minY - LOGIN_BUTTON_KEYBOARD_OFFSET
        return CGFloat.maximum(DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT,
                               LOGINBUTTON_DEFAULT_MAXY - desiredMaxY
        )
    }
    
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
    
    ////////////////////////////////////////////////////
    // MARK: - Authenticate Methods
    fileprivate func AuthenticateWith(_ username : String, _ password : String) {
        print("User \(username) with password \(password) wants to log in")
    }

    @IBAction func confirmPressed(_ sender: Any) {
        let username = emailTextField.text!
        let password = passwordTextField.text!
        AuthenticateWith(username, password)
        performSegue(withIdentifier: MAINAPP_SEGUE_IDENTIFIER, sender: self)
    }
    
    @IBAction func guestEntryPressed(_ sender: Any) {
        performSegue(withIdentifier: MAINAPP_SEGUE_IDENTIFIER, sender: self)
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        print("Signing in with facebook")
        performSegue(withIdentifier: MAINAPP_SEGUE_IDENTIFIER, sender: self)
    }
    

    ////////////////////////////////////////////////////
    // MARK: - Views Navigation Methods
    fileprivate func CanConfirm() -> Bool {
        return emailTextField.text! != "" && passwordTextField.text! != ""
    }
    
    fileprivate func UpdateConfirmButton(if enabled : Bool) {
        if enabled {
            loginButton.alpha = LOGIN_BUTTON_ENABLED_ALPHA
            loginButton.isEnabled = true
        } else {
            loginButton.alpha = LOGIN_BUTTON_DISABLED_ALPHA
            loginButton.isEnabled = false
        }
    }
    
    fileprivate func DismissKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        performSegue(withIdentifier: REGISTER_SEGUE_IDENTIFIER, sender: self)
    }
}
