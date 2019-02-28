//
//  WelcomeScreenController.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/26/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit

class WelcomeScreenController: UIViewController {

    // Segue Identifiers
    let LOGIN_SEGUE_IDENTIFIER = "goToLogin"
    let REGISTER_SEGUE_IDENTIFIER = "goToRegister"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logInPressed(_ sender: Any) {
        performSegue(withIdentifier: LOGIN_SEGUE_IDENTIFIER, sender: self)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        performSegue(withIdentifier: REGISTER_SEGUE_IDENTIFIER, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AuthenticationScreenController
        if segue.identifier! == LOGIN_SEGUE_IDENTIFIER {
            destinationVC.titleInScreen = "Log In Screen"
            destinationVC.buttonTitle = "Log In"
        } else if segue.identifier! == REGISTER_SEGUE_IDENTIFIER {
            destinationVC.titleInScreen = "Register Screen"
            destinationVC.buttonTitle = "Register"
        }
    }
    
}
