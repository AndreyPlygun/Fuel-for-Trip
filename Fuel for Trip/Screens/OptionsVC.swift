//
//  OptionsVC.swift
//  Fuel Way
//
//  Created by Andrey Plygun on 23/11/2019.
//  Copyright © 2019 Andrey Plygun. All rights reserved.
//

import UIKit

protocol OptionsVCDelegate {
    func moveView()
    var distance: Double { get }
    var isViewShown: Bool { get }
}

class OptionsVC: UIViewController {
    
    @IBOutlet weak var tfConsumption: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCalc: UIButton!
    @IBOutlet weak var lbInfo: UILabel!
    @IBOutlet weak var btnAbout: UIButton!
    
    var delegate: OptionsVCDelegate?
    
    var distance = 0.0
    var consumption: Double = 0
    var price: Double = 0
    var isKeyboardVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGR)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupUI()
    }
    
    func setupUI() {
        tfConsumption.layer.cornerRadius = tfConsumption.bounds.height / 2
        tfConsumption.layer.borderWidth = 0
        tfConsumption.enablesReturnKeyAutomatically = true
        tfConsumption.clipsToBounds = true
        tfConsumption.attributedPlaceholder = NSAttributedString(string: "Fuel consumption".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)])
        tfConsumption.textColor = .white
        if consumption != 0 {
            tfConsumption.text = "\(Int(consumption))"
        }
        
        tfPrice.layer.cornerRadius = tfPrice.bounds.height / 2
        tfPrice.layer.borderWidth = 0
        tfPrice.clipsToBounds = true
        tfPrice.attributedPlaceholder = NSAttributedString(string: "Price of fuel".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)])
        tfPrice.textColor = .white
        if price != 0 {
            tfPrice.text = "\(Int(price))"
        }
        
        btnDone.layer.cornerRadius = 20
        btnDone.clipsToBounds = true
        btnDone.setTitle("Options".localized, for: .normal)
        
        btnCalc.layer.cornerRadius = 20
        btnCalc.clipsToBounds = true
        btnCalc.setTitle("Calculate".localized, for: .normal)
        
        infoView.layer.cornerRadius = 20
        infoView.clipsToBounds = true
        lbInfo.text = "Here you can easily calculate distanse of your trip and, if you define your car's consumption of fuel (liter per 100 km), you'll get amount of fuel you need for trip. Additionaly you can define cost of one liter of fuel, so you'll also know, how much will cost trip".localized
        
        btnAbout.setTitle("About".localized, for: .normal)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        //        let consumption = NSString(string: tfConsumption.text!).doubleValue
        //        let price = NSString(string: tfPrice.text!).doubleValue
        view.endEditing(true)
        delegate?.moveView()
        if delegate!.isViewShown {
            btnDone.setTitle("Hide".localized, for: .normal)
        } else {
            btnDone.setTitle("Options".localized, for: .normal)
        }
        //        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCalcTapped(_ sender: Any) {
        var title = ""
        var message = ""
        var amountFuel = 0.0
        consumption = NSString(string: tfConsumption.text!).doubleValue
        price = NSString(string: tfPrice.text!).doubleValue
        distance = delegate!.distance
        if distance != 0 {
            if consumption != 0 {
                title = "Travel expenses".localized
                amountFuel = (consumption / 100 * distance).rounded(.up)
                message = "\n" + "Amount of fuel:".localized + " \(Int(amountFuel)) " + "L".localized
                if price != 0 {
                    let fuelCost = amountFuel * price
                    message.append("\n" + "Total cost of fuel:".localized + " \(Int(fuelCost))")
                }
            } else {
                title = "Could not calculate travel expenses".localized
                message = "Please specify fuel consumption of your car".localized
            }
            
        } else {
            title = "Could not calculate travel expenses".localized
            message = "Please specify distance of travel".localized
        }
        dismissKeyboard()
        present(AlertHelper.showMessage(title: title, message: message), animated: true, completion: {
            if self.delegate!.isViewShown {
                self.btnDone.setTitle("Options".localized, for: .normal)
                self.delegate?.moveView()
            }
        })
    }
    
    @IBAction func btnAboutPressed(_ sender: Any) {
        let aboutVC = Storyboard.about.controller(withClass: AboutVC.self)!
        aboutVC.modalPresentationStyle = .popover
        present(aboutVC, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if !isKeyboardVisible {
                self.view.frame.origin.y -= keyboardSize.height
                isKeyboardVisible = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
            isKeyboardVisible = false
        }
    }
}

extension OptionsVC: UIGestureRecognizerDelegate {
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }    
}
