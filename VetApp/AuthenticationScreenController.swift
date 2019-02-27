//
//  AuthenticationScreenController.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/26/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit

class AuthenticationScreenController: UIViewController {

    // Segue identifier
    let MAINAPP_SEGUE_IDENTIFIER = "goToMainApp"
    
    // Data Recievers
    var titleInScreen : String = ""
    var buttonTitle : String = ""
    
    // Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text! = titleInScreen
        confirmButton.setTitle(buttonTitle, for: .normal)
    }

    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        performSegue(withIdentifier: MAINAPP_SEGUE_IDENTIFIER, sender: self)
    }
    

}
