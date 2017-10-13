//
//  Depot.swift
//  VVV
//
//  Created by James Swiney on 17/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation
import CoreLocation

/** A object containing all information regarding a Depot.  A Depot is a location in which the rental vehicle is picked up or returned. */
@objc(VVVDepot) public class Depot : NSObject {
    
    /** The name of the Depot eg "Brisbane APO." */
    public let name : String
    
    /** The phone number of the Depot */
    public let phone : String
    
    /** The supplier the depots belong to */
    public let supplier : Supplier
    
    /** The location of the depots (including address and coordinates) */
    public let location : Location
    
    
    
    /** The code identifier of the Depot */
    let code : String
    
    /** The distance from the search required for search request */
    var originalDistance : Double?
    
    /** The distance from the search required for search request */
    var distance : Double?
    
    /**
     
     Standard mapping init method for Nearby Depots request.
     
     - Parameters:
     - json: The json object from the nearby depots request.
     - supplier: the Supplier for the depot
     
     */
    init?(json:[String:Any],supplier:Supplier) {
        
        guard let metaData = json["metadata"] as? [String:Any],
            let code = json["depotCode"] as? String,
            let distance = json["distance"] as? Double,
            let originalDistance = json["originalDistance"] as? Double,
            let name = metaData["name"] as? String,
            let address = metaData["address"] as? String,
            let city = metaData["city"] as? String,
            let countryCode = metaData["countryCode"] as? String,
            let isAirport = metaData["isAirport"] as? Bool,
            let phone = metaData["phoneNumber"] as? String,
            let lat = metaData["latitude"] as? Double,
            let long = metaData["longitude"] as? Double else { return nil }
        
        self.location = Location(title: name, subTitle: "\(address), \(city)", country: countryCode, location: CLLocation(latitude: lat, longitude: long))
        self.location.isAirport = isAirport
        self.code = code
        self.distance = distance
        self.originalDistance = originalDistance
        self.name = name
        self.phone = phone
        self.supplier = supplier
        super.init()
    }
    
    /**
     
     Standard mapping init method for PendingBooking and Booking objects
     
     - Parameters:
        - json: The depot json object from the PendingBooking and Booking objects
        - supplier: the Supplier code for the depots eg. "HZ"
     
     */
    init?(bookingJson:[String:Any],supplier:Supplier) {
        
        guard let code = bookingJson["code"] as? String,
            let name = bookingJson["name"] as? String,
            let address = bookingJson["address"] as? String,
            let city = bookingJson["city"] as? String,
            let countryCode = bookingJson["countryCode"] as? String,
            let isAirport = bookingJson["isAirport"] as? Bool,
            let locationDict = bookingJson["geoLocation"] as? [String:Any],
            let lat = locationDict["latitude"] as? Double,
            let long = locationDict["longitude"] as? Double else { return nil }
        
        self.location = Location(title: name, subTitle: "\(address), \(city)", country: countryCode, location: CLLocation(latitude: lat, longitude: long))
        self.location.isAirport = isAirport
        self.code = code
        self.name = name
        self.phone = bookingJson["phoneNumber"] as? String ?? ""
        self.supplier = supplier
        super.init()
    }

}

extension Depot {
    
    /**
     
     The params mapping for the depot when performing a search request
     
     - Return:
        - [String:Any]: A key value representation of the depot for the request.
     
     */
    func toParams() -> [String:Any] {
        
        guard let distance = self.distance,
            let originalDistance = self.originalDistance else { return [:] }
        
        let params = ["depotCode" : code,"countryCode": location.country, "originalDistance": originalDistance, "distance" : distance] as [String : Any]
        
        return params
        
    }
    
}
