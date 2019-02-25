//
//  FirstViewController.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/17/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit

class PetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Table View Consts and Variables
    let PET_CELL_ID = "petCell"
    let PET_CELL_XIB = "PetCell" // the name of the XIB file
    let ADDPET_CELL_ID = "addPetCell" // the identifier set in the XIB file
    let ADDPET_CELL_XIB = "AddPetCell" // the name of the XIB file
    let ADDPET_SEGUE_ID = "goToAddPet"
    let PET_DATABASE_ID = "Pets"
    let ESTIMATED_ROW_HEIGHT : CGFloat = 120.0
    var petArray : [Pet] = [Pet]()

    // Outlets
    @IBOutlet weak var petTableView: UITableView!
    
    //////////////////////////////////////////////////////////////
    
    // MARK: ViewDidLoad and ViewWillLoad overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConformToProtocols()
        ConfigureTableView()
        
        petArray.append(Pet(name: "Kira", species: .Cat, race : "DLH", dateOfBirth: 25, chipNumber: 1))
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: TableViewMethods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petArray.count + 1 // the extra element is the addPet button
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberOfPets : Int = petArray.count
        
        if indexPath.row < numberOfPets {
            let cell = tableView.dequeueReusableCell(withIdentifier: PET_CELL_ID, for: indexPath) as! PetCell
            let petToShow : Pet = petArray[indexPath.row]
            cell.petName.text = petToShow.name
            cell.petPicture.image = UIImage(named: "Kira")
            cell.petRace.text = petToShow.race
            cell.petSpecies.text = petToShow.species.rawValue
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: ADDPET_CELL_ID, for: indexPath) as! AddPetCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ADDPET_SEGUE_ID, sender: self)
    }
    
    fileprivate func ConformToProtocols() {
        petTableView.delegate = self
        petTableView.dataSource = self
    }
    
    fileprivate func ConfigureTableView() {
        petTableView.register(UINib(nibName: ADDPET_CELL_XIB, bundle : nil), forCellReuseIdentifier: ADDPET_CELL_ID)
        petTableView.register(UINib(nibName: PET_CELL_XIB, bundle : nil), forCellReuseIdentifier: PET_CELL_ID)
        petTableView.rowHeight = UITableView.automaticDimension
        petTableView.estimatedRowHeight = ESTIMATED_ROW_HEIGHT
    }



}

