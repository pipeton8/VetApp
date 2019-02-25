//
//  FirstViewController.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/17/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

// TODO: Link Database and internal storage

import UIKit
import Firebase
import SVProgressHUD

class PetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddPetDelegate {

    // Table View Consts and Variables
    let PET_CELL_ID = "petCell"
    let PET_CELL_XIB = "PetCell" // the name of the XIB file
    let ADDPET_CELL_ID = "addPetCell" // the identifier set in the XIB file
    let ADDPET_CELL_XIB = "AddPetCell" // the name of the XIB file
    let PET_DATABASE_ID = "Pets"
    let PET_ROW_HEIGHT : CGFloat = 90.0
    let ADDNEWPET_ROW_HEIGHT : CGFloat = 60.0
    var petArray : [Pet] = [Pet]()
    var numberOfPets : Int = 0

    // Segue Consts and Variables
    let ADDPET_SEGUE_ID = "goToAddPet"
    let EDITPET_SEGUE_ID = "goToEditPet"
    var petToEdit : Pet? = nil
    
    // Outlets
    @IBOutlet weak var petTableView: UITableView!
    
    //////////////////////////////////////////////////////////////
    
    // MARK: ViewDidLoad and ViewWillLoad overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConformToProtocols()
        RetrievePets(showHUD: true)
        ConfigureCells()
        
        petTableView.addSubview(self.refreshControl)
    }
    
    fileprivate func ConformToProtocols() {
        petTableView.delegate = self
        petTableView.dataSource = self
    }

    fileprivate func ConfigureCells() {
        petTableView.register(UINib(nibName: ADDPET_CELL_XIB, bundle : nil), forCellReuseIdentifier: ADDPET_CELL_ID)
        petTableView.register(UINib(nibName: PET_CELL_XIB, bundle : nil), forCellReuseIdentifier: PET_CELL_ID)
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petArray.count + 1 // the extra element is the addPet button
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < numberOfPets {
            let cell = tableView.dequeueReusableCell(withIdentifier: PET_CELL_ID, for: indexPath) as! PetCell
            let petToShow : Pet = petArray[indexPath.row]
            cell.petName.text = petToShow.name
            cell.petRace.text = "Race: " + petToShow.race
            cell.petSpecies.text = petToShow.species.rawValue
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: ADDPET_CELL_ID, for: indexPath) as! AddPetCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < numberOfPets {
            petToEdit = petArray[indexPath.row]
            performSegue(withIdentifier: EDITPET_SEGUE_ID, sender: self)
        } else {
            performSegue(withIdentifier: ADDPET_SEGUE_ID, sender: self)
        }
        
        petTableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < numberOfPets { return PET_ROW_HEIGHT }
        else { return ADDNEWPET_ROW_HEIGHT}
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: PullToRefresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        RetrievePets()
        refreshControl.endRefreshing()
        self.petTableView.reloadData()
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: Networking
    fileprivate func RetrievePets(showHUD : Bool = false) {
        if showHUD { SVProgressHUD.show() }
        let petDB = Firestore.firestore().collection(PET_DATABASE_ID)
        var newPetArray = [Pet]()
        
        petDB.getDocuments {
            (snapshot, error) in
            if let error = error {
                print("There was an error getting the documents : \(error)")
                SVProgressHUD.dismiss()
            } else {
                for document in snapshot!.documents {
                    let petData = document.data()
                    newPetArray.append(Pet(dictionary: petData))
                }
                self.petArray = newPetArray
                self.numberOfPets = newPetArray.count
                self.petTableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    fileprivate func UploadPet(_ petToAdd : Pet) {
        let petData = petToAdd.PrepareToUpload()
        SVProgressHUD.show()
        let petDB = Firestore.firestore().collection(PET_DATABASE_ID)
        petDB.addDocument(data: petData)
        SVProgressHUD.dismiss()
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EDITPET_SEGUE_ID {
            let editPetVC = segue.destination as! EditPetViewController
            editPetVC.petToEdit = petToEdit
        } else if segue.identifier == ADDPET_SEGUE_ID {
            let addPetVC = segue.destination as! AddPetViewController
            addPetVC.delegate = self
        }
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: AddPet and EditPet methods
    func PetAdded(newPet: Pet) {
        petArray.append(newPet)
        UploadPet(newPet)
        petTableView.reloadData()
    }
    
    


}

