//
//  RedAlertPop.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 3/3/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import UIKit

class RedAlertPop: UIViewController {

    // MARK: - Properties

    var alertText : String = "Placeholder alert text"
    @IBOutlet weak var alertLabel: UILabel!
    
    // MARK: - viewDidLoad

    fileprivate func SetAlertLabel(with text : String) {
        alertLabel.text = alertText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetAlertLabel(with : alertText)
    }


    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
