//
//  AboutVC.swift
//  Fuel Way
//
//  Created by Andrey Plygun on 11/28/19.
//  Copyright © 2019 Andrey Plygun. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var tvInfo: UITextView!
    @IBOutlet weak var swCheck: UISwitch!
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var blCheck: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        tvInfo.layer.cornerRadius = 10
        tvInfo.clipsToBounds = true
        tvInfo.text = "Here you can easily calculate distanse of your trip and, if you define your car's consumption of fuel (liter per 100 km), you'll get amount of fuel you need for trip. Additionaly you can define cost of one liter of fuel, so you'll also know, how much will cost trip".localized
        
        btnDismiss.layer.cornerRadius = btnDismiss.layer.bounds.height / 2
        btnDismiss.clipsToBounds = true
        btnDismiss.setTitle("Dismiss".localized, for: .normal)
        
        swCheck.isOn = UserDefaults.standard.bool(forKey: "dontShowAgain")
    }
    
    @IBAction func btnDismissTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(swCheck.isOn, forKey: "dontShowAgain")
        dismiss(animated: true, completion: nil)
    }
}
