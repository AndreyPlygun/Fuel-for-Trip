//
//  ViewController.swift
//  Fuel Way
//
//  Created by Andrey Plygun on 11/22/19.
//  Copyright © 2019 Andrey Plygun. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lbInfo: UILabel!
    
    var optionsVC: OptionsVC!
    var isViewShown = false
    var distance: Double = 0
    var shouldNotShowAbout = UserDefaults.standard.bool(forKey: "dontShowAgain")
//    var shouldNotShowAbout = false
    var consumption: Double = 0 {
        didSet {
            showInfo()
        }
    }
    
    var price: Double = 0 {
        didSet {
            showInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
    }
    
    private func setupUI() {
        lbInfo.backgroundColor = UIColor(white: 0.5, alpha: 1)
        lbInfo.layer.cornerRadius = lbInfo.bounds.height / 2
        lbInfo.clipsToBounds = true
        lbInfo.isHidden = true
        
        optionsVC = Storyboard.details.controller(withClass: OptionsVC.self)
        optionsVC.delegate = self
        view.insertSubview(optionsVC.view, aboveSubview: self.view)
        optionsVC.view.layer.cornerRadius = 20
        optionsVC.view.clipsToBounds = true
        optionsVC.view.frame.origin.y = UIScreen.main.bounds.height - 60
    }
    
    private func showInfo() {
//        var amountFuel = 0.0
        if distance != 0 {
            lbInfo.text = "Distance:".localized + " \(distance) " + "km".localized
//            if consumption != 0 {
//                amountFuel = (consumption / 100 * distance).rounded(.up)
//                lbInfo.text?.append("\n" + "Amount of fuel:".localized + " \(Int(amountFuel)) " + "L".localized)
//            }
//            if price != 0 {
//                let fuelCost = amountFuel * price
//                lbInfo.text?.append("\n" + "Total cost of fuel:".localized + " \(Int(fuelCost))")
//            }
            lbInfo.isHidden = false
        }
    }
    
    private func showAbout() {
        let aboutVC = Storyboard.about.controller(withClass: AboutVC.self)!
        aboutVC.modalPresentationStyle = .popover
        present(aboutVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !shouldNotShowAbout {
            showAbout()
            shouldNotShowAbout = true
        }
    }
}

extension ViewController: MKMapViewDelegate {
    private func setupMapView() {
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func handleTap(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .began {
            return
        }
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        showAnnotation(coordinate)
    }
    
    private func showAnnotation(_ coordinate: CLLocationCoordinate2D) {
        if mapView.annotations.count < 2 {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = checkTitle(for: annotation)
            if mapView.annotations.isEmpty {
                mapView.addAnnotation(annotation)
            } else {
                mapView.addAnnotation(annotation)
                showRoute()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let id = "pin"
        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
        view.image = UIImage(named: "pin")
        view.centerOffset = .init(x: 2.5, y: -24)
        view.canShowCallout = true
        let button = UIButton(frame: CGRect(origin: .zero, size: .init(width: 30, height: 30)))
        button.setImage(UIImage.init(named: "basket"), for: .normal)
        view.rightCalloutAccessoryView = button
        return view
    }
    
    private func showRoute() {
        let sourceCoor = mapView.annotations[0].coordinate
        let destinationCoor = mapView.annotations[1].coordinate
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoor)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoor)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [weak self] (response, error) in
            guard let response = response else {
                self?.present(AlertHelper.showMessage(title: "Could not find a route".localized, message: error?.localizedDescription ?? ""), animated: true, completion: nil)
//                print(error ?? "Could not find a route")
                return
            }
            let route = response.routes[0]
            self?.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self?.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 150, left: 30, bottom: 100, right: 30), animated: true)
            self?.distance = route.distance / 1000
            self?.showInfo()
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 4
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        removeAnnotation(view.annotation!)
        mapView.overlays.forEach {
            mapView.removeOverlay($0)
        }
        distance = 0
        lbInfo.isHidden = true
    }
    
    private func removeAnnotation(_ annotation: MKAnnotation) {
        var coordinate: CLLocationCoordinate2D?
        if annotation.title == "Start".localized {
            if mapView.annotations.count == 1 {
                mapView.removeAnnotation(annotation)
            } else if mapView.annotations.count == 2 {
                for item in mapView.annotations {
                    if item.title == "Finish".localized {
                        coordinate = item.coordinate
                        mapView.removeAnnotation(item)
                        break
                    }
                }
                mapView.removeAnnotation(annotation)
                showAnnotation(coordinate!)
            }
        } else {
            mapView.removeAnnotation(annotation)
        }
    }
    
    private func checkTitle(for annotation: MKAnnotation) -> String {
        let title = annotation.title!
        if mapView.annotations.isEmpty || title == "Finish".localized {
            return "Start".localized
        } else {
            return "Finish".localized
        }
    }
}

extension ViewController: OptionsVCDelegate {    
    func moveView() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            if self!.isViewShown {
                self?.optionsVC.view.frame.origin.y = UIScreen.main.bounds.height - 60
            } else {
                self?.optionsVC.view.frame.origin.y -= 180
            }
            self?.isViewShown = !self!.isViewShown
        }
    }
}
