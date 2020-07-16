//
//  LocationDetailsViewController.swift
//  Locations
//
//  Created by mac on 7/14/20.
//  Copyright © 2020 M.gamal. All rights reserved.
//

import UIKit
import CoreLocation

    private let dateFormatter: DateFormatter =
    {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
    }()


class LocationDetailsViewController: UITableViewController
{
        @IBOutlet weak var descriptionTextView: UITextView!
        @IBOutlet weak var categoryLabel: UILabel!
        @IBOutlet weak var latitudeLabel: UILabel!
        @IBOutlet weak var longitudeLabel: UILabel!
        @IBOutlet weak var addressLabel: UILabel!
        @IBOutlet weak var dateLabel: UILabel!
    
        var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var placemark : CLPlacemark?
        
        var categoryName = "No Category"

    
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            descriptionTextView.text = ""
            categoryLabel.text = ""
            
            categoryLabel.text = categoryName
            
            latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
            
            if let placemark = placemark
            {
                addressLabel.text = string(from : placemark)
            }
            else
            {
                addressLabel.text = "No Address Found"
            }
            
            dateLabel.text = format(date: Date())
        }
        
    
        func string(from placemark: CLPlacemark) -> String
        {
            var text = ""
            if let s = placemark.subThoroughfare
            { text += s + " " }
            if let s = placemark.thoroughfare
            { text += s + ", " }
            if let s = placemark.locality
            { text += s + ", " }
            if let s = placemark.administrativeArea
            { text += s + " " }
            if let s = placemark.postalCode
            { text += s + ", " }
            if let s = placemark.country
            {text += s}
            return text
        }
        
        func format(date: Date) -> String {
        return dateFormatter.string(from: date)
        }
    
        // MARK:- Actions
        @IBAction func done() {
        navigationController?.popViewController(animated: true)
        }
        @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory"
        {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue)
    {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
}
        

