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

class PetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ConfigPetDelegate {

    // MARK: - Properties

    // Table View Consts and Variables
    let PET_CELL_ID = "petCell"
    let PET_CELL_XIB = "PetCell" // the name of the XIB file
    let ADDPET_CELL_ID = "addPetCell" // the identifier set in the XIB file
    let ADDPET_CELL_XIB = "AddPetCell" // the name of the XIB file
    let PET_DATABASE_ID = "Pets"
    let PET_ROW_HEIGHT : CGFloat = 90.0
    let ADDNEWPET_ROW_HEIGHT : CGFloat = 60.0
    var petArray : [Pet] = [Pet]()

    // Segue Consts and Variables
    let ADDPET_SEGUE_ID = "goToAddPet"
    let EDITPET_SEGUE_ID = "goToEditPet"
    var petToEdit : Pet?
    var petToEditImage : UIImage?
    
    // Pet Database
    var petDB : CollectionReference?
    
    // Outlets
    @IBOutlet weak var petTableView: UITableView!
    
    //////////////////////////////////////////////////////////////
    
    // MARK: - ViewDidLoad and ViewWillLoad overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ConformToProtocols()
        GetPetDatabase()
        RetrievePets(showHUD: true)
        ConfigureCells()
        
        petTableView.addSubview(self.refreshControl)
    }
    
    func ConformToProtocols() {
        petTableView.delegate = self
        petTableView.dataSource = self
    }

    func ConfigureCells() {
//        petTableView.register(UINib(nibName: ADDPET_CELL_XIB, bundle : nil), forCellReuseIdentifier: ADDPET_CELL_ID)
        petTableView.register(UINib(nibName: PET_CELL_XIB, bundle : nil), forCellReuseIdentifier: PET_CELL_ID)
    }
    
    func GetPetDatabase() {
        petDB = Firestore.firestore().collection(PET_DATABASE_ID)
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petArray.count //+ 1 // the extra element is the addPet button
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < petArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: PET_CELL_ID, for: indexPath) as! PetCell
            let petToShow : Pet = petArray[indexPath.row]
            let petImage : UIImage? = loadImage(from: petToShow)
            if petImage != nil { cell.petPicture.image = petImage! }
            cell.petName.text = petToShow.name
            cell.petRace.text = "Race: " + petToShow.race
            cell.petSpecies.text = petToShow.species.rawValue
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: ADDPET_CELL_ID, for: indexPath) as! AddPetCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < petArray.count {
            petToEdit = petArray[indexPath.row]
            petToEditImage = (tableView.cellForRow(at: indexPath) as! PetCell).petPicture.image
            performSegue(withIdentifier: EDITPET_SEGUE_ID, sender: self)
        } else {
            performSegue(withIdentifier: ADDPET_SEGUE_ID, sender: self)
        }
        
        petTableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < petArray.count { return PET_ROW_HEIGHT }
        else { return ADDNEWPET_ROW_HEIGHT}
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let petToDelete = petArray.remove(at: indexPath.row)
            DeletePet(petToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //////////////////////////////////////////////////////////////
    // MARK: - Image Handling
    
    func loadImage(from pet: Pet) -> UIImage? {
        let imageUrl : URL = URL(fileURLWithPath: pet.imagePath)
        
        if FileManager.default.fileExists(atPath: pet.imagePath),
            let imageData: Data = try? Data(contentsOf: imageUrl),
            let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
            return image
        } else {
            return UIImage(named: pet.species.rawValue)
        }
        
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: - PullToRefresh
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
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: - Networking
    fileprivate func RetrievePets(showHUD : Bool = false) {
        if showHUD { SVProgressHUD.show() }
        var newPetArray = [Pet]()
        
        petDB!.getDocuments {
            (snapshot, error) in
            if let error = error {
                print("There was an error getting the documents : \(error)")
                SVProgressHUD.dismiss()
            } else {
                for document in snapshot!.documents {
                    let petData = document.data()
                    newPetArray.append(Pet(dictionary: petData, id: document.reference.documentID))
                }
                self.ReloadTableView(with : newPetArray)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func ReloadTableView(with newPetArray : [Pet]) {
        petArray = [Pet]()
        petTableView.reloadData()
        petArray = newPetArray
        petTableView.reloadSections(IndexSet(integer: 0), with: .bottom)
    }
    
    fileprivate func UploadPet(_ petToAdd : Pet) {
        let petData = petToAdd.PrepareToUpload()
        
        SVProgressHUD.show()
        let petDocReference = petDB!.document(petToAdd.ID)
        petDocReference.setData(petData)
        SVProgressHUD.dismiss()
    }
    
    func DeletePet(_ petToDelete : Pet) {
        petDB!.document(petToDelete.ID).delete()
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let configPetVC = segue.destination as! ConfigPetViewController
        configPetVC.delegate = self

        if segue.identifier == EDITPET_SEGUE_ID {
            configPetVC.petToEdit = petToEdit
            configPetVC.petImage = petToEditImage
            configPetVC.editMode = true
        }
    }
    
    @IBAction func addPetPressed(_ sender: Any) {
        performSegue(withIdentifier: ADDPET_SEGUE_ID, sender: self)
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: - ConfigPetDelegate methods
    func PetAdded(newPet: Pet) {
        petArray.append(newPet)
        UploadPet(newPet)
        petTableView.reloadData()
    }
    
    func PetConfigured(pet: Pet) {
        let petIndex = petArray.firstIndex(where: {$0.ID == pet.ID})!
        petArray[petIndex] = pet
        UploadPet(pet)
        petTableView.reloadData()
    }
}

