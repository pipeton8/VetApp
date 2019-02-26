//
//  ConfigPetViewController.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/18/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

// TODO: Review Image inputs and storage

import UIKit

protocol ConfigPetDelegate {
    func PetAdded(newPet : Pet)
    func PetConfigured(pet : Pet)
}

class ConfigPetViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // Consts and Var
    var delegate : ConfigPetDelegate?
    
    // Edit Mode Consts and variables
    let DEFAULT_CHIP_NUMBER : Int = -1
    let DEFAULT_DATE_OF_BIRTH : Int = 0

    var editMode : Bool = false
    var petToEdit : Pet!    // this pet is passed by the delegate who called the edit
    var petImage : UIImage! // this image is passed by the delegate who called the edit
    var petConfigured : Pet!

    // Picture consts and variables
    var imageToStore : UIImage?
    var imagePath : String = ""
    
    // Finish button consts and variables
    let FINISH_BUTTON_EDIT_TEXT : String = "Done"
    let FINISH_BUTTON_ADD_TEXT : String = "Add"
    let FINISH_BUTTON_HIDE_ALPHA : CGFloat = 0.5
    let FINISH_BUTTON_SHOW_ALPHA : CGFloat = 1

    // SpeciesPickerView consts and variables
    let SPECIES_PICKER_HIDE_HEIGHT : CGFloat = -260.0
    let SPECIES_PICKER_SHOW_HEIGHT : CGFloat = 0
    let SPECIES_PICKER_ANIM_TIME : TimeInterval = 0.25
    let DEFAULT_SPECIES_PICKER_TEXT : String =  "Select..."
    let DEFAULT_RACE_PICKER_TEXT : String = "Select species..."
    let SPECIES_PICKERVIEW_COMPONENT : Int = 0
    let RACE_PICKERVIEW_COMPONENT : Int = 1
    
    // DatePicker consts and variables
    let DATE_PICKER_HIDE_CONSTANT : CGFloat = -216.0
    let DATE_PICKER_SHOW_CONSTANT : CGFloat = 0.0
    let DATE_PICKER_ANIM_TIME : TimeInterval = 0.25
    let DATEOFBIRTH_DATE_FORMAT : DateFormatter.Style = .long
    
    var dateOfBirthFormatter = DateFormatter()

    // TextFields consts and variables
    let KEYBOARD_ANIM_TIME : TimeInterval = 0.23
    
    // Outlets
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var dateofBirthHideConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var speciesPickerConstraint: NSLayoutConstraint!
    @IBOutlet weak var speciesPicker: UIPickerView!
    @IBOutlet weak var speciesPickerToolbar: UIToolbar!
    @IBOutlet weak var speciesButton: UIButton!
    @IBOutlet weak var raceButton: UIButton!
    @IBOutlet weak var chipNumberTextField: UITextField!
    
    //////////////////////////////////////////////////////////////
    
    // MARK: ViewDidLoad and ViewWillLoad overrides
    fileprivate func ConformToProtocols() {
        speciesPicker.delegate = self
        speciesPicker.dataSource = self
        nameTextField.delegate = self
        chipNumberTextField.delegate = self
    }
    
    fileprivate func InitializeDateOfBirth() {
        dateOfBirthPicker.maximumDate = Date()
        dateOfBirthFormatter.dateStyle = DATEOFBIRTH_DATE_FORMAT
        dateOfBirthPicker.date = Date()
        dateOfBirthLabel.text! = dateOfBirthFormatter.string(from: Date())
    }
    
    fileprivate func SetPictureAndName() {
        pictureView.image = petImage
        imageToStore = petImage
        nameTextField.text! = petToEdit!.name
    }
    
    fileprivate func SetSpeciesAndRaceButtons() {
        speciesButton.setTitle(petToEdit!.species.rawValue, for: .normal)
        raceButton.setTitle(petToEdit!.race, for: .normal)
        raceButton.isEnabled = true
    }
    
    fileprivate func SetSpeciesAndRacePicker() {
        let speciesRowSelected = Species.allCases.firstIndex(of: petToEdit!.species)! + 1
        let raceRowSelected = Species.GetRacesIn(petToEdit!.species).firstIndex(of: petToEdit!.race)!
        speciesPicker.selectRow(speciesRowSelected, inComponent: SPECIES_PICKERVIEW_COMPONENT, animated: false)
        speciesPicker.reloadComponent(RACE_PICKERVIEW_COMPONENT)
        speciesPicker.selectRow(raceRowSelected, inComponent: RACE_PICKERVIEW_COMPONENT, animated: false)
    }
    
    fileprivate func SetDateOfBirth() {
        if petToEdit.dateOfBirth != DEFAULT_DATE_OF_BIRTH {
            let dateOfBirth = Date(timeIntervalSinceReferenceDate: TimeInterval(petToEdit.dateOfBirth))
            dateOfBirthPicker.date = dateOfBirth
            dateOfBirthLabel.text! = dateOfBirthFormatter.string(from: dateOfBirth)
        }
    }
    
    fileprivate func SetChipNumber() {
        if petToEdit.chipNumber != DEFAULT_CHIP_NUMBER {
            chipNumberTextField.text! = String(petToEdit.chipNumber)
        } else {
            chipNumberTextField.text! = ""
        }
    }
    
    fileprivate func ConfigureEditMode() {
        finishButton.setTitle(FINISH_BUTTON_EDIT_TEXT, for: .normal)
        
        SetPictureAndName()
        SetSpeciesAndRaceButtons()
        SetSpeciesAndRacePicker()
        SetDateOfBirth()
        SetChipNumber()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConformToProtocols()
        InitializeDateOfBirth()
        if editMode { ConfigureEditMode() }
        UpdateFinishButton()
    }

    //////////////////////////////////////////////////////////////
    
    // MARK: Choose Picture Methods
    @IBAction func addPicturePressed(_ sender: Any) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = {
            (image) in
            self.pictureView.image = image
            self.imageToStore = image
        }
    }

    //////////////////////////////////////////////////////////////
    
    // MARK: Textfields methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        if textField === nameTextField {
            speciesButton.sendActions(for: .touchUpInside)
        }
        UpdateFinishButton()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        HideEverythingExcept(this: textField)
        UIView.animate(withDuration: KEYBOARD_ANIM_TIME) { self.view.layoutIfNeeded() }
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: PickerView-related methods and actions
    fileprivate func ShowPickerView() {
        speciesPickerConstraint.constant = SPECIES_PICKER_SHOW_HEIGHT
        UIView.animate(withDuration: SPECIES_PICKER_ANIM_TIME) {
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func HidePickerView(animated : Bool) {
        speciesPickerConstraint.constant = SPECIES_PICKER_HIDE_HEIGHT
        UIView.animate(withDuration: SPECIES_PICKER_ANIM_TIME) {
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func SpeciesPickerTitle(for row: Int) -> String {
        if row == 0 {
            return DEFAULT_SPECIES_PICKER_TEXT
        } else {
            return Species.allCases[row-1].rawValue
        }
    }
    
    fileprivate func RacePickerTitle(_ pickerView: UIPickerView, for row: Int) -> String {
        let rowInFirstComponent = pickerView.selectedRow(inComponent: SPECIES_PICKERVIEW_COMPONENT)
        if rowInFirstComponent == 0 { return DEFAULT_RACE_PICKER_TEXT }
        let speciesSelected = Species.allCases[rowInFirstComponent-1]
        return Species.GetRacesIn(speciesSelected)[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // Species and Race
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == SPECIES_PICKERVIEW_COMPONENT {
            return Species.allCases.count + 1
        } else {
            let rowSelectedInSpecies = pickerView.selectedRow(inComponent: SPECIES_PICKERVIEW_COMPONENT)
            if rowSelectedInSpecies == 0 {
                return 1
            } else {
                let speciesSelected = Species.allCases[rowSelectedInSpecies-1]
                let racesInSpecies = Species.GetRacesIn(speciesSelected)
                return racesInSpecies.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == SPECIES_PICKERVIEW_COMPONENT {
            return SpeciesPickerTitle(for : row)
        } else {
            return RacePickerTitle(pickerView, for : row)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var titleToSet = ""
        if component == SPECIES_PICKERVIEW_COMPONENT {
            titleToSet = SpeciesPickerTitle(for : row)
            if titleToSet != DEFAULT_SPECIES_PICKER_TEXT { raceButton.isEnabled = true }
            else {
                raceButton.isEnabled = false
                raceButton.setTitle(DEFAULT_RACE_PICKER_TEXT, for: .normal)
            }
            speciesButton.setTitle(titleToSet, for: .normal)
            pickerView.reloadComponent(RACE_PICKERVIEW_COMPONENT)
        } else {
            titleToSet = RacePickerTitle(pickerView, for : row)
            raceButton.setTitle(titleToSet, for: .normal)
        }
        UpdateFinishButton()
    }
    
    @IBAction func speciesRacePressed(_ sender: Any) {
        HideEverythingExcept(this: speciesPicker)
        ShowPickerView()
    }

    @IBAction func speciesDonePressed(_ sender: Any) {
        HidePickerView(animated: true)
    }

    //////////////////////////////////////////////////////////////
    
    // MARK: Date Picker methods
    func DateOfBirthPicker(hide : Bool) {
        if hide == true {
            dateofBirthHideConstraint.constant = DATE_PICKER_HIDE_CONSTANT
            dateOfBirthLabel.textColor = UIColor.black
        } else {
            dateofBirthHideConstraint.constant = DATE_PICKER_SHOW_CONSTANT
            dateOfBirthLabel.textColor = UIColor.red
        }
        UIView.animate(withDuration: DATE_PICKER_ANIM_TIME) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func dateOfBirthPressed(_ sender: Any) {
        HideEverythingExcept(this: dateOfBirthPicker)
        let shouldHide : Bool = dateofBirthHideConstraint.constant == DATE_PICKER_SHOW_CONSTANT
        if shouldHide { DateOfBirthPicker(hide: true) }
        else { DateOfBirthPicker(hide: false) }
    }
    
    @IBAction func dateOfBirthPickerChanged(_ sender: Any) {
        dateOfBirthLabel.text = dateOfBirthFormatter.string(from: dateOfBirthPicker.date)
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: Finish adding methods
    func GetImagePath() {
        let imageName = petConfigured!.ID
        imagePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
    }

    func SaveImage() {
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        if let image = imageToStore {
            try? image.pngData()?.write(to: imageUrl)
        }
    }
    
    func CreatePet() -> Pet {
        let dateOfBirth : Date = dateOfBirthFormatter.date(from: dateOfBirthLabel.text!)!
        var raceName = ""
        if raceButton.titleLabel!.text! == DEFAULT_RACE_PICKER_TEXT {
            raceName = "Unknown"
        } else {
            raceName = raceButton.titleLabel!.text!
        }
        
        let petDict : [String : Any] = [
            "name"        : nameTextField.text ?? "",
            "species"     : speciesButton.titleLabel!.text ?? Species.none,
            "race"        : raceName,
            "dateOfBirth" : Int(dateOfBirth.timeIntervalSinceReferenceDate),
            "chipNumber"  : Int(chipNumberTextField.text ?? "-1") ?? -1,
            "imagePath"   : imagePath ]
        
        var id = ""
        
        if editMode {
            id = petToEdit.ID
        } else {
            id = String(Date.timeIntervalSinceReferenceDate) + nameTextField.text! + String(Int.random(in: 0..<Int.max))
        }
        
        return Pet(dictionary: petDict, id : id)
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        petConfigured = CreatePet()
        GetImagePath()
        SaveImage()
        if editMode { delegate?.PetConfigured(pet: petConfigured!) }
        else { delegate?.PetAdded(newPet: petConfigured!) }
        dismiss(animated: true)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: Other Methods
    func HideEverythingExcept(this object : Any?) {
        if object as? UITextField == nameTextField {
            HidePickerView(animated: true)
            DateOfBirthPicker(hide: true)
            chipNumberTextField.resignFirstResponder()
        } else if object as? UIPickerView == speciesPicker {
            nameTextField.resignFirstResponder()
            DateOfBirthPicker(hide: true)
            chipNumberTextField.resignFirstResponder()
        } else if object as? UIDatePicker == dateOfBirthPicker {
            nameTextField.resignFirstResponder()
            HidePickerView(animated: true)
            chipNumberTextField.resignFirstResponder()
        } else if object as? UITextField == chipNumberTextField {
            nameTextField.resignFirstResponder()
            HidePickerView(animated: true)
            DateOfBirthPicker(hide: true)
        } else {
            nameTextField.resignFirstResponder()
            HidePickerView(animated: true)
            DateOfBirthPicker(hide: true)
            chipNumberTextField.resignFirstResponder()
        }
    }
    
    func CanFinish() -> Bool {
        var canFinish = true
        canFinish = canFinish && nameTextField.text! != ""
        canFinish = canFinish && speciesButton.title(for: .normal) != DEFAULT_SPECIES_PICKER_TEXT
        canFinish = canFinish && raceButton.title(for: .normal) != DEFAULT_RACE_PICKER_TEXT
        return canFinish
    }
    
    fileprivate func UpdateFinishButton() {
        if CanFinish() {
            finishButton.isEnabled = true
            finishButton.alpha = FINISH_BUTTON_SHOW_ALPHA
        } else {
            finishButton.isEnabled = false
            finishButton.alpha = FINISH_BUTTON_HIDE_ALPHA
        }
    }
}
