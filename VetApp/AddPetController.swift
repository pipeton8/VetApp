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

class AddPetViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Consts and Var
    var delegate : AddPetDelegate?
    
    // SpeciesPickerView consts and variables
    let SPECIES_PICKER_HIDE_HEIGHT : CGFloat = -260.0
    let SPECIES_PICKER_SHOW_HEIGHT : CGFloat = 0
    let SPECIES_PICKER_ANIM_TIME : TimeInterval = 0.25
    
    // Outlets
    @IBOutlet weak var speciesPickerConstraint: NSLayoutConstraint!
    @IBOutlet weak var speciesPicker: UIPickerView!
    @IBOutlet weak var speciesPickerToolbar: UIToolbar!
    @IBOutlet weak var speciesButton: UIButton!
    
    //////////////////////////////////////////////////////////////
    
    // MARK: ViewDidLoad and ViewWillLoad overrides
    fileprivate func ConformToProtocols() {
        speciesPicker.delegate = self
        speciesPicker.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HidePickerView(animated : false)
        ConformToProtocols()
        // Do any additional setup after loading the view.
    }
    
    //////////////////////////////////////////////////////////////
    
    // MARK: SpeciesPicker-related methods and actions
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Species.allCases.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Select..."
        } else {
            return Species.allCases[row-1].rawValue
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var titleToSet = ""
        if row == 0 { titleToSet = "Select ... "}
        else { titleToSet = Species.allCases[row-1].rawValue }
        speciesButton.setTitle(titleToSet, for: .normal)
    }

    @IBAction func speciesPressed(_ sender: Any) {
        ShowPickerView()
    }
    

    @IBAction func speciesDonePressed(_ sender: Any) {
        HidePickerView(animated: true)
    }



    //////////////////////////////////////////////////////////////
    
    // MARK: Finish adding methods
    @IBAction func donePressed(_ sender: Any) {
        
        
        
        dismiss(animated: true)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
