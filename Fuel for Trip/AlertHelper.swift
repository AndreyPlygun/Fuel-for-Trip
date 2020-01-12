//
//  AlertHelper.swift
//  Fuel Way
//
//  Created by Andrey Plygun on 11/24/19.
//  Copyright © 2019 Andrey Plygun. All rights reserved.
//

import UIKit

class AlertHelper {
    static func showMessage(title: String, message: String) -> UIAlertController {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        return alertVC
    }
}
