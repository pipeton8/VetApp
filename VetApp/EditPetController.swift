//
//  EditPetController.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/25/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit

class EditPetViewController: UIViewController {

    @IBOutlet weak var petLabel: UILabel!
    
    var petToEdit : Pet? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        petLabel.text = "Editing pet named " + petToEdit!.name
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
