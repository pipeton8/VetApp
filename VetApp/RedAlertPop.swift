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
    let ALERT_HEIGHT : CGFloat = 30.0
    let TEXT_HORIZONTAL_OFFSET : CGFloat = 10.0
    var alertText : String = "Placeholder alert text"
    @IBOutlet weak var alertLabel: UILabel!
    
    // MARK: - viewDidLoad

    fileprivate func SetAlertLabel(with text : String) {
        alertLabel.text = alertText
    }
    
    fileprivate func SetViewSize() {
        view.layoutIfNeeded()
        preferredContentSize = CGSize(width: alertLabel.frame.maxX + TEXT_HORIZONTAL_OFFSET, height: ALERT_HEIGHT)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetAlertLabel(with : alertText)
        SetViewSize()
    }

}
