//
//  Pet.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/18/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import Foundation

enum Species : String, CaseIterable {
    case Dog = "Dog"
    case Cat = "Cat"
    case none = "Other"

    static func GetRacesIn(_ species : Species) -> [String] {
        let races = Races.init()
        switch species {
        case .Dog:
            return races.dogRaces
        case .Cat:
            return races.catRaces
        case .none:
            return ["Unknown"]
        }
    }
}

struct Races {
    let catRaces = ["Unknown", "DLH", "DSH"]
    let dogRaces = ["Unknown", "Dachshund", "Shitzu"]
}
