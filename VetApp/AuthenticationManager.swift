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
    func UserDidSignIn()
    func ShowAlert(vc : UIViewController?, popup : UIAlertController?)
    func DismissAlertsVC()
}

class AuthenticationManager : UIViewController, UIPopoverPresentationControllerDelegate {
    
    // Delegation
    var delegate : AuthenticationManagerDelegate?
    
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
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if error == nil { self.delegate?.UserDidSignIn() }
            else { self.AlertErrorInAuth(withCode: AuthErrorCode(rawValue: error!._code)!) }
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
            if error == nil { self.delegate?.UserDidSignIn() }
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
        case .invalidCredential:
            ShowPopup(withTitle: "Facebook Authentication Problem", withText: "Invalid credentials")
        case .accountExistsWithDifferentCredential:
            ShowPopup(withTitle: "Linking required", withText: "This account already exists. To link Facebok with your account log in with the original credentials and go to Settings")
        case .wrongPassword:
            ShowWrongPasswordAlert()
        default:
            break
        }
    }
    
    func ShowWrongPasswordAlert() {
        passwordLabel.textColor = UIColor.flatRed()
        passwordLabel.shake(times: NUMBER_OF_PASSWORD_SHAKES, duration: PASSWORD_SHAKE_ANIM_TIME, displacement: PASSWORD_SHAKE_HORIZONTAL_MOVEMENT)
    }
    
    func ShowPopup(withTitle title : String? = nil, withText text : String, actionTitle : String = "Dismiss") {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        delegate?.ShowAlert(vc: nil, popup: alert)
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
        delegate?.ShowAlert(vc: alertVC, popup: nil)
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
