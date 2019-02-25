//
//  TableViewCell.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/24/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var petPicture: UIImageView!
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var petSpecies: UILabel!
    @IBOutlet weak var petRace: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
