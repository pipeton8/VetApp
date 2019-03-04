//
//  AuthenticationScreenController.swif
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/26/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit
import Firebase

class AuthenticationViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate {
    
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
    var currentConstraintConstant : CGFloat = 0.0 // must be fetched on viewDidLoad
    @IBOutlet weak var abovePositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var belowPositionConstraint: NSLayoutConstraint!
    
    // E-mail alert PopOver
    let RED_ALERT_IDENTIFIER : String = "RedAlertPop"
    @IBOutlet weak var alertAnchor: UIView!
    
    // Password alert
    let NUMBER_OF_PASSWORD_SHAKES : Float = 3
    let PASSWORD_SHAKE_ANIM_TIME : TimeInterval = 0.15
    let PASSWORD_SHAKE_HORIZONTAL_MOVEMENT : CGFloat = 5
    @IBOutlet weak var passwordLabel: UILabel!
    
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
        currentConstraintConstant = DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT
    }
    
    fileprivate func HidePasswordLabel() {
        passwordLabel.textColor = UIColor.flatMint()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ConformToProtocols()
        UpdateConfirmButton(if : CanConfirm())
        LayoutPassWordTextField()
        AddToNotificationObservers()
        GetConstants()
        SetHideKeyboardWhenTapped()
        HidePasswordLabel()
    }

    ////////////////////////////////////////////////////
    // MARK: - Textfield Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isSecureTextEntry { textField.PreventSecureEntryClearing() }
    }
    
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
        if newConstant != currentConstraintConstant {
            LayoutViewForKeyboard(with: newConstant)
            currentConstraintConstant = newConstant
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if DEFAULT_ABOVEBELOW_CONSTRAINT_CONSTANT != currentConstraintConstant {
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
    fileprivate func AuthenticateWith(_ email : String, _ password : String, _ onCompletion : @escaping (Error?, Bool) -> Void ) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            let success = error == nil
            onCompletion(error, success)
        }
    }
    
    fileprivate func CleanAlerts() {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        passwordLabel.textColor = UIColor.flatMint()
    }
    
    fileprivate func AlertErrorInAuth(withCode code : AuthErrorCode) {
        switch code {
        case .tooManyRequests:
            ShowPopup(withText: "Too many invalid tries. Try again after some time.")
        case .invalidEmail:
            ShowAlert(withText: "The e-mail is not valid")
        case .userDisabled:
            ShowAlert(withText: "This account has been disabled")
        case .userNotFound:
            ShowAlert(withText: "This e-mail is not registered")
        case .wrongPassword:
            ShowPasswordAlert()
        default:
            break
        }
    }

    fileprivate func ShowPopup(withText text : String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func ShowAlert(withText text : String) {
        // instantiate
        let alertVC = RedAlertPop.init(nibName: RED_ALERT_IDENTIFIER, bundle: nil)
        
        // configure alertVC
        alertVC.alertText = text
        alertVC.modalPresentationStyle = .popover
        
        // configure appearance
        let popoverController = alertVC.popoverPresentationController!
        popoverController.delegate = self
        popoverController.backgroundColor = UIColor.flatRed()
        popoverController.passthroughViews = [view, ]
        popoverController.permittedArrowDirections = .down
        popoverController.sourceView = emailTextField
        popoverController.sourceRect = emailTextField.bounds.applying(CGAffineTransform(translationX: 0, y: -2))
        
        // display
        present(alertVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    fileprivate func ShowPasswordAlert() {
        passwordLabel.textColor = UIColor.flatRed()
        passwordLabel.shake(times: NUMBER_OF_PASSWORD_SHAKES, duration: PASSWORD_SHAKE_ANIM_TIME, displacement: PASSWORD_SHAKE_HORIZONTAL_MOVEMENT)
    }

    @IBAction func confirmPressed(_ sender: Any) {
        let username = emailTextField.text!
        let password = passwordTextField.text!
        CleanAlerts()
        AuthenticateWith(username, password) { (error,success) in
            if success {
                self.performSegue(withIdentifier: self.MAINAPP_SEGUE_IDENTIFIER, sender: self)
            } else {
                print("error code: \(error!._code)")
                self.AlertErrorInAuth(withCode : AuthErrorCode(rawValue: error!._code)!)
            }
        }
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
        presentedViewController?.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: REGISTER_SEGUE_IDENTIFIER, sender: self)
    }
    
    ////////////////////////////////////////////////////
    // MARK: - Gesture Recognizer delegate methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let viewTouched = touch.view, viewTouched.isEqual(hidePasswordButton) {
            return false
        }
        return true
    }

}
