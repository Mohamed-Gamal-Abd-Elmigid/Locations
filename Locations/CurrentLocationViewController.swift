//
//  FirstViewController.swift
//  Locations
//
//  Created by mac on 7/9/20.
//  Copyright © 2020 M.gamal. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController , CLLocationManagerDelegate
{

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
        
    let locationManager = CLLocationManager()
    var location : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateLabels()
        
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did Fail With Error \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("did update location \(newLocation)")
        
        location = newLocation
        updateLabels()
    }
    
    func updateLabels()
    {
        if let location = location {
            
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longtudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        }
        else
        {
            latitudeLabel.text = ""
            longtudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"
        }
    }
    
    @IBAction func getLocation(_ sender: Any)
    {
        //Ask For Permision 
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined
        {locationManager.requestWhenInUseAuthorization()
            return
        }
        // hena btl3 el alert lma ykon 3amle denied ll permision for allow permition
        if authStatus == .denied || authStatus == .restricted
        {
            showLocatoinServices()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        
    }
    
    // Helper Methods
    func showLocatoinServices()
    {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert , animated: true)
    
    }
}

