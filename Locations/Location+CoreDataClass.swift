//
//  Location+CoreDataClass.swift
//  Locations
//
//  Created by mac on 7/17/20.
//  Copyright © 2020 M.gamal. All rights reserved.
//
//

import Foundation
import CoreData
import  MapKit

@objc(Location)
public class Location: NSManagedObject , MKAnnotation
{
   
    
    public var coordinate: CLLocationCoordinate2D
    { return CLLocationCoordinate2DMake(latitude, longitude) }
    public var title: String?
    {
    if locationDescription.isEmpty
    { return "(No Description)" }
    else { return locationDescription }
    }
    public var subtitle: String?
    {return category}

}
