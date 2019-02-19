//
//  Pet.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/18/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import Foundation

enum DogRace {
    case none
    case Dachshund
    case ShihTzu
}

class Dog : Pet {
    var race : DogRace = .none
    
    init(name : String, species : Species, race : DogRace, dateOfBirth : Int, chipNumber : Int) {
        super.init(name: name, species: species, dateOfBirth: dateOfBirth, chipNumber: chipNumber)
        self.race = race
    }
    
    func UpdateRace(newRace : DogRace) {
        race = newRace
    }
    
}
