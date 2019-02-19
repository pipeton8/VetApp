//
//  Pet.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/18/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import Foundation

enum Species {
    case Cat
    case Dog
}

class Pet {
    var name : String
    var species : Species
    var dateOfBirth : Int // Special format?
    var chipNumber : Int // String maybe?
    
    init(name : String, species : Species, dateOfBirth : Int, chipNumber : Int) {
        self.name = name
        self.species = species
        self.dateOfBirth = dateOfBirth
        self.chipNumber = chipNumber
    }
    
}
