//
//  LocationDetailsViewController.swift
//  Locations
//
//  Created by mac on 7/14/20.
//  Copyright © 2020 M.gamal. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

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

            var managedObjectContext: NSManagedObjectContext!
    
            var date = Date()

    
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
            
            dateLabel.text = format(date: date)
            
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            gestureRecognizer.cancelsTouchesInView = false
            tableView.addGestureRecognizer(gestureRecognizer)

            
        }
        
        @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer)
        {
            let point = gestureRecognizer.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: point)
                if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
                    return
        }
            
            
    descriptionTextView.resignFirstResponder()
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
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1
        {return indexPath}
        else {return nil}
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0
        {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    
        // MARK:- Actions
        @IBAction func done() {
       
            let hudView = HudView.hud(inView: navigationController!.view, animated: true)
            hudView.text = "Tagged"
            let delayInSeconds = 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds,
            execute:
                {   hudView.hide()
                    self.navigationController?.popViewController(animated: true) })

            
            // Save Location
            let location = Location(context: managedObjectContext)

            location.locationDescription = descriptionTextView.text
            location.category = categoryName
            location.latitude = coordinate.latitude
            location.longitude = coordinate.longitude
            location.date = date
            location.placemark = placemark

            do
            {try managedObjectContext.save() }
            catch
            {fatalError("Error : \(error)")}

                
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
        

