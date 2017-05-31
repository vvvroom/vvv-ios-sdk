//
//  VVVLocation.swift
//  VVV
//
//  Created by James Swiney on 14/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation
import CoreLocation

/** Simple object representing a location of a depot/search */
@objc(VVVLocation) public class Location : NSObject, LocationSearchResult {
    
    /** Whether or not the location is an Airport */
    public var isAirport = false
    
    /** If the location is an airport this with be the airport code if available eg. "SYD" */
    public var airportCode : String?
    
    /** The coordinate location information */
    public let locationDetails : CLLocation
    
    /** The name of the location eg "Sydney Airport" */
    public var title : String
    
    /** The full details of the location including state and country */
    public var subtitle : String
    
    
    /** Full description combined title and subtitle */
    public var fullName : String { get {
         return "\(self.title) \(self.subtitle)"
        }
    }
    
    /** The state of the location is available */
    public var state : String?
    
    /** The country name of the location */
    public var country : String
    
    /**
     
     Inits the date with defined values
     - Parameters:
        - title: The name of the location eg "Sydney Airport"
        - subTitle: The full details of the location including state and country.
        - country: The country name
        - location: the location coordinates object
     
     */
    public init(title:String,subTitle:String,country:String,location:CLLocation) {
        
        self.isAirport = title.lowercased().contains("airport") || subTitle.lowercased().contains("airport")
        
        self.locationDetails = location
        self.title = title
        self.subtitle = subTitle
        self.country = country
        
    }
    
    /** Init a location at a placemark from Apple MKLocation search */
    init?(placemark:CLPlacemark) {
        
        guard let location = placemark.location,
            let country = placemark.country else { return nil }
        
        self.country = country
        self.locationDetails = location
        self.state = placemark.administrativeArea
        
        var locationText = ""
        
        if let subLocality = placemark.subLocality {
            locationText = "\(subLocality),"
        }
        
        if let administrativeArea = placemark.administrativeArea {
            if !locationText.contains(administrativeArea) {
                locationText = "\(locationText) \(administrativeArea),"
            }
        }
        locationText = "\(locationText) \(country)"

        if let name = placemark.name {
            self.title = name
            self.subtitle = locationText
        } else {
            self.title = locationText
            self.subtitle = ""
        }
        super.init()
        self.isAirport = self.fullName.lowercased().contains("airport")
    }
    
    /** Init a location from the JSON object in Depot reponse */
    init?(json:[String:Any]) {
        guard let latitude = json["latitude"] as? String,
            let lat = Double(latitude),
            let longitude = json["longitude"] as? String,
            let long = Double(longitude),
            let locationText = json["fullLocationName"] as? String,
            let shortName = json["displayName"] as? String,
            let country = json["countryName"] as? String else {
                return nil
        }
        
        self.locationDetails = CLLocation(latitude: lat, longitude: long)
        self.subtitle = locationText
        self.isAirport = json.typeValueFor(key:"isAirport",type:Bool.self)
        self.title = shortName
        self.airportCode = json["code"] as? String
        self.country = country
    }
    
    /** Init a location from the JSON object in Toplocations reponse */
    init?(searchJSON:[String:Any]) {
        guard let latitude = searchJSON["latitude"] as? String,
            let lat = Double(latitude),
            let longitude = searchJSON["longitude"] as? String,
            let long = Double(longitude),
            let locationText = searchJSON["location"] as? String,
            let shortName = searchJSON["name"] as? String,
            let country = searchJSON["countryName"] as? String else {
                return nil
        }

        self.locationDetails = CLLocation(latitude: lat, longitude: long)
        self.subtitle = locationText
        self.isAirport = searchJSON.typeValueFor(key:"isAirport",type:Bool.self)
        self.title = shortName
        self.airportCode = searchJSON["code"] as? String
        self.country = country
    }
    
    /** Init a simple location object for the current location */
    static func currentLocation() -> Location {
        
        let location = Location(title: "Current Location", subTitle: "", country: "", location: LocationManager.shared.userLocation!)
        return location
    }
}

