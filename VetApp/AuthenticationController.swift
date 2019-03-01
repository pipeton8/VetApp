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

    // Segue identifier
    let MAINAPP_SEGUE_IDENTIFIER = "goToMainApp"
    
    // Confirm Button appeareance
    let CONFIRM_BUTTON_ENABLED_ALPHA : CGFloat = 0.8
    let CONFIRM_BUTTON_DISABLED_ALPHA : CGFloat = 0.2
    let CONFIRM_BUTTON_CONSTRAINT_DEFAULT_CONSTANT : CGFloat = 0.0
    let CONFIRM_BUTTON_KEYBOARD_OFFSET : CGFloat = 20.0
    
    // Password TextField appearance
    let HIDE_BUTTON_TEXT_OFFSET : CGFloat = 5.0
    @IBOutlet weak var HIDE_PASSWORD_BUTTON_HORIZONTAL_OFFSET: NSLayoutConstraint!
    @IBOutlet weak var HIDE_PASSWORD_BUTTON_VERTICAL_OFFSET: NSLayoutConstraint!
    
    // Data Recievers
    var titleInScreen : String = ""
    var buttonTitle : String = ""
    
    // Outlets
    @IBOutlet weak var confirmButtonContainer: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextFieldPadding!
    @IBOutlet weak var confirmButtonAdjustConstraint: NSLayoutConstraint!
    
    ////////////////////////////////////////////////////
    // MARK: viewDidLoad and viewWillLoad methods
    
    fileprivate func ConformToProtocols() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    fileprivate func AddToNotificationObservers() {
        // usernameTextField change text notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange(_:)),
                                               name: UITextField.textDidChangeNotification,
                                               object: usernameTextField)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        confirmButton.setTitle(buttonTitle, for: .normal)
        ConformToProtocols()
        UpdateConfirmButton(if : CanConfirm())
        LayoutPassWordTextField()
        AddToNotificationObservers()
    }

    ////////////////////////////////////////////////////
    // MARK: Textfield Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            if CanConfirm() {
                confirmButton.sendActions(for: .touchUpInside)
            }
        }
        return true
    }
    
    @objc func textDidChange(_ notification : Notification) {
        UpdateConfirmButton(if : CanConfirm())
    }
    
    @objc func keyboardWillShow(_ notification : Notification) {
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        confirmButtonAdjustConstraint.constant = GetNewConstant(usingFrame: keyboardFrame)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        confirmButtonAdjustConstraint.constant = CONFIRM_BUTTON_CONSTRAINT_DEFAULT_CONSTANT
    }
    
    fileprivate func GetNewConstant(usingFrame keyboardFrame : CGRect) -> CGFloat {
        let confirmButtonOriginalY = confirmButtonContainer.frame.minY + CONFIRM_BUTTON_CONSTRAINT_DEFAULT_CONSTANT
        let newConfirmButtonY = keyboardFrame.minY - confirmButton.frame.height - CONFIRM_BUTTON_KEYBOARD_OFFSET
        return newConfirmButtonY - confirmButtonOriginalY
    }
    
    @IBAction func hideButtonPressed(_ sender: Any) {
        passwordTextField.TogglePasswordVisibility()
    }
    
    ////////////////////////////////////////////////////
    // MARK: Authenticate Methods
    fileprivate func AuthenticateWith(_ username : String, _ password : String) {
        print("User \(username) with password \(password) wants to log in")
    }

    @IBAction func confirmPressed(_ sender: Any) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        AuthenticateWith(username, password)
        performSegue(withIdentifier: MAINAPP_SEGUE_IDENTIFIER, sender: self)
    }

    ////////////////////////////////////////////////////
    // MARK: Views Navigation Methods
    fileprivate func CanConfirm() -> Bool {
        return usernameTextField.text! != "" && passwordTextField.text! != ""
    }
    
    fileprivate func UpdateConfirmButton(if enabled : Bool) {
        if enabled {
            confirmButton.alpha = CONFIRM_BUTTON_ENABLED_ALPHA
            confirmButton.isEnabled = true
        } else {
            confirmButton.alpha = CONFIRM_BUTTON_DISABLED_ALPHA
            confirmButton.isEnabled = false
        }
    }
    
    fileprivate func DismissKeyboard() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        DismissKeyboard()
        dismiss(animated: true)
    }
}
