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
    
    var updatingLocation = false
    var lastLocationError : Error?
    
    var timer : Timer?
    
    //reverse geocoding
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateLabels()
        
    }
        
    //CLLocationManagerDelegate
    // Handel Error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did Fail With Error \(error.localizedDescription)")
    
        if (error as NSError).code == CLError.locationUnknown.rawValue {return}
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        
    }
    // Starting location updates
    func startLocationManager()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            timer = Timer.scheduledTimer(timeInterval: 60, target: self,selector: #selector(didTimeOut), userInfo: nil,
            repeats: false)
        
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }
    
    @objc func didTimeOut()
    {
       
        print("*** Time out")
        if location == nil {
        stopLocationManager()
        lastLocationError = NSError(
        domain: "MyLocationsErrorDomain",
        code: 1, userInfo: nil)
        updateLabels()
        }
        
    }
    
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let newLocation = locations.last!
            print("did update location \(newLocation)")
            
    //        location = newLocation
    //        updateLabels()
    //        lastLocationError = nil
            if newLocation.timestamp.timeIntervalSinceNow < -5
            {return}
            if newLocation.horizontalAccuracy < 0
            {return}
            var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
            if let location = location
            {distance = newLocation.distance(from: location)}
            if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy
            {
                lastLocationError = nil
                location = newLocation
                if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy
                {
                    print("*** We're done!")
                    stopLocationManager()
                    if distance > 0
                    { performingReverseGeocoding = false }
                }
                updateLabels()
                if !performingReverseGeocoding
                {print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation,completionHandler:
                {
                    //Handling reverse geocoding errors
                        placemarks, error in
//                        if let error = error
//                        {
//                            print("*** Reverse Geocoding error:              \(error.localizedDescription)")
//                       return}
//                        if let places = placemarks
//                        {print("*** Found places: \(places)")
//                        }
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                    self.placemark = p.last!
                    } else {
                    self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
                }
                else if distance < 1
                {
                    let timeIntvertal = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                    if timeIntvertal > 10
                    {
                        print("*** Force done !")
                        stopLocationManager()
                        updateLabels()
                    }
                }
                
            }
        }
    func stopLocationManager()
    {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer
            { timer.invalidate() }
        }
    }
    
   
    
    func updateLabels()
    {
        if let location = location {
            
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longtudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            //Displaying the address
            if let placemark = placemark {
            addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
            addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
            addressLabel.text = "Error Finding Address"
            } else {
            addressLabel.text = "No Address Found"
            }
            
            
        }
        else
        {
            latitudeLabel.text = ""
            longtudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
         //   messageLabel.text = "Tap 'Get My Location' to Start"
       
            let statusMessage: String
            if let error = lastLocationError as NSError?
            {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue
                {statusMessage = "Location Services Disabled"}
                else {statusMessage = "Error Getting Location"}
            }
            else if !CLLocationManager.locationServicesEnabled() {
                    statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                    statusMessage = "Searching..."
            } else {
                    statusMessage = "Tap 'Get My Location' to Start"
            }
                    messageLabel.text = statusMessage
        }
        configureGetButton()
    }
    
    func string(from placemark: CLPlacemark) -> String
    {
        // 1  address will be two lines of text create a new string variable for the first line of text.
        var line1 = ""
        // 2 subThoroughfare is a fancy name for house number --->  street number for the location.
            if let s = placemark.subThoroughfare {
                line1 += s + " "
            }
        // 3  Adding the thoroughfare (or street name) is done
            if let s = placemark.thoroughfare {
                line1 += s
            }
        // 4  adds the locality (the city), administrative area (the state or province), and postal code (or zip code)
        var line2 = ""
            if let s = placemark.locality {
                line2 += s + " "
            }
            if let s = placemark.administrativeArea {
                line2 += s + " "
            }
            if let s = placemark.postalCode {
                line2 += s
            }
            // 5  the two lines are concatenated
            return line1 + "\n" + line2
    }
 
        
    func configureGetButton()
    {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
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
        
        //  startLocationManager()
        if updatingLocation
        {stopLocationManager()}
        else {
        location = nil
        lastLocationError = nil
        startLocationManager()
        }
        updateLabels()
        
        placemark = nil
        lastGeocodingError = nil
        
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

