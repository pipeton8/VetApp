//
//  NewPetViewController.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/18/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit

protocol AddPetDelegate {
    func PetAdded(newPet : Pet)
}

class AddPetViewController: UIViewController {

    var delegate : AddPetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backPressed(_ sender: Any) {
        let newPetTest = Pet(name: "Popo", species: .Dog, race: "Chowchow", dateOfBirth: 21, chipNumber: 2)
        
        delegate?.PetAdded(newPet: newPetTest)
        dismiss(animated: true)
    }
}
