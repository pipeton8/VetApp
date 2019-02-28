//
//  AuthenticationScreenController.swif
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/26/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit
import Firebase

class AuthenticationScreenController: UIViewController, UITextFieldDelegate {

    // Segue identifier
    let MAINAPP_SEGUE_IDENTIFIER = "goToMainApp"
    
    // Confirm Button appeareance
    let CONFIRM_BUTTON_ENABLED_ALPHA : CGFloat = 1.0
    let CONFIRM_BUTTON_DISABLED_ALPHA : CGFloat = 0.5
    
    // Data Recievers
    var titleInScreen : String = ""
    var buttonTitle : String = ""
    
    // Outlets
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        confirmButton.setTitle(buttonTitle, for: .normal)
        ConformToProtocols()
        UpdateConfirmButton(if : CanConfirm())
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
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    

}
