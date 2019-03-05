//
//  AuthenticationManager.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 3/4/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

protocol AuthenticationManagerDelegate {
    func UserDidAuthenticate()
    func ShowAlert(vc : UIViewController)
    func DismissAlertsVC()
}

class AuthenticationManager : UIViewController, UIPopoverPresentationControllerDelegate {
    
    // Delegation
    var delegate : AuthenticationManagerDelegate?
    
    // Email and password
    var email = ""
    var password = ""
    
    // Password constants and vars
    let NUMBER_OF_PASSWORD_SHAKES : Float = 3
    let PASSWORD_SHAKE_ANIM_TIME : TimeInterval = 0.15
    let PASSWORD_SHAKE_HORIZONTAL_MOVEMENT : CGFloat = 5
    var passwordLabel : UILabel = UILabel()
    var passwordTextField : UITextField = UITextField()

    // E-mail alert PopOver
    let RED_ALERT_IDENTIFIER : String = "RedAlertPop"
    let RED_ALERT_ARROW_OFFSET : CGAffineTransform = CGAffineTransform(translationX: 0, y: -2)
    var emailTextField : UITextField = UITextField()
    
    // Sign In Methods identifiers
    let EMAILPASSWORD_SIGNIN_IDENTIFIER : String = "password"
    let FACEBOOK_SIGNIN_IDENTIFIER : String = "facebook.com"
    
    ////////////////////////////////////////////////////
    //MARK: - Register
    func RegisterWith(_ email : String, _ password : String) {
        self.email = email
        self.password = password
        Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
            if error == nil { self.delegate?.UserDidAuthenticate() }
            else { self.AlertErrorInAuth(withCode : AuthErrorCode(rawValue: error!._code)!) }
        }
    }

    ////////////////////////////////////////////////////
    //MARK: - Re-signin
    func AdvanceIfAlreadySignedIn() {
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current()!.tokenString)
            AuthenticateUsingFacebook(with : credential, shouldShowError : true)
        }
    }
    
    ////////////////////////////////////////////////////
    //MARK: - Authentication with email
    func AuthenticateWith(_ email : String, _ password : String) {
        self.email = email
        self.password = password
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if error == nil { self.delegate?.UserDidAuthenticate() }
            else { self.CheckError(AuthErrorCode(rawValue: error!._code)!) }
        }
    }
    
    ////////////////////////////////////////////////////
    //MARK: - Authentication with Facebook
    func LogInWithFacebook() {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            let failedToSignIn = self.FacebookSignInErrorHandling(result,error)
            if failedToSignIn  { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current()!.tokenString)
            self.AuthenticateUsingFacebook(with : credential)
        }
    }
    
    func AuthenticateUsingFacebook(with credential : AuthCredential, shouldShowError : Bool = true) {
        Auth.auth().signInAndRetrieveData(with: credential) { (_, error) in
            if error == nil { self.delegate?.UserDidAuthenticate() }
            else if shouldShowError { self.AlertErrorInAuth(withCode: AuthErrorCode(rawValue: error!._code)!) }
        }
    }
    
    ////////////////////////////////////////////////////
    //MARK: - Alerts and error handling
    func AlertErrorInAuth(withCode code : AuthErrorCode) {
        switch code {
        case .tooManyRequests:
            ShowPopup(withText: "Too many invalid tries. Try again after some time.")
        case .invalidEmail:
            ShowAlert(withText: "The e-mail is not valid")
        case .userDisabled:
            ShowAlert(withText: "This account has been disabled")
        case .userNotFound:
            ShowAlert(withText: "This e-mail is not registered")
        case .emailAlreadyInUse:
            ShowAlert(withText: "The e-mail is already in use")
        case .invalidCredential:
            ShowPopup(withTitle: "Facebook Authentication Problem", withText: "Invalid credentials")
        case .accountExistsWithDifferentCredential:
            ShowPopup(withTitle: "Linking required", withText: "This account already exists with another provider. To link your account with your e-mail log in with the original credentials and go to Settings")
        case .wrongPassword:
            ShowPasswordAlert()
        case .weakPassword:
            ShowPasswordAlert()
        default:
            break
        }
    }
    
    func CheckError(_ error : AuthErrorCode) {
        Auth.auth().fetchProviders(forEmail: email) { (providers, error) in
            var anotherProvider = false
            if error == nil {
                if let _ = providers {
                    let emailIndex = providers!.firstIndex(of: self.EMAILPASSWORD_SIGNIN_IDENTIFIER)
                    if emailIndex == nil { anotherProvider = true }
                    else if providers!.count > 1 { anotherProvider = true}
                    else if let index = emailIndex, index > 0 { anotherProvider = true }
                }
            }
            if anotherProvider { self.AlertErrorInAuth(withCode: .accountExistsWithDifferentCredential) }
            else { self.AlertErrorInAuth(withCode: AuthErrorCode(rawValue: error!._code)!) }
        }
        
    }
    
    func ShowPasswordAlert() {
        passwordLabel.textColor = UIColor.flatRed()
        passwordLabel.shake(times: NUMBER_OF_PASSWORD_SHAKES, duration: PASSWORD_SHAKE_ANIM_TIME, displacement: PASSWORD_SHAKE_HORIZONTAL_MOVEMENT)
    }
    
    func ShowPopup(withTitle title : String? = nil, withText text : String, actionTitle : String = "Dismiss") {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        delegate?.ShowAlert(vc: alert)
    }
    
    func FacebookSignInErrorHandling(_ result : FBSDKLoginManagerLoginResult?, _ error : Error?) -> Bool {
        if let cancelled = result?.isCancelled, cancelled { return true }
        if let deniedPermissions = result?.declinedPermissions, deniedPermissions.contains("email") {
            ShowPopup(withTitle: "Facebook permissions problem", withText: "In order to authenticate with Facebook access to your e-mail is required")
            return true
        }
        return false
    }
        
    func ShowAlert(withText text : String) {
        let alertVC = SetupAndInstantiateAlert(withText: text)
        ConfigureAppearanceOf(alertVC.popoverPresentationController!)
        delegate?.ShowAlert(vc: alertVC)
    }
    
    func SetupAndInstantiateAlert(withText text : String) -> RedAlertPop {
        let alertPop = RedAlertPop.init(nibName: RED_ALERT_IDENTIFIER, bundle: nil)
        alertPop.alertText = text
        alertPop.modalPresentationStyle = .popover
        return alertPop
    }
    
    func ConfigureAppearanceOf(_ popoverController : UIPopoverPresentationController) {
        popoverController.delegate = self
        popoverController.backgroundColor = UIColor.flatRed()
        popoverController.passthroughViews = [(delegate as? UIViewController)!.view]
        popoverController.permittedArrowDirections = .down
        popoverController.sourceView = emailTextField
        popoverController.sourceRect = emailTextField.bounds.applying(RED_ALERT_ARROW_OFFSET)
    }
    
    func CleanAlerts(passwordErrorCode : AuthErrorCode) {
        delegate?.DismissAlertsVC()
        switch passwordErrorCode {
        case .weakPassword:
            passwordLabel.textColor = UIColor.darkGray
        case .wrongPassword:
            passwordLabel.textColor = UIColor.flatMint()
        default:
            break
        }
    }
    
    ////////////////////////////////////////////////////
    //MARK: - Popover Presentation Delegate Methods
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
