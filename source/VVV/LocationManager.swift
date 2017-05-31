//
//  LocationManager.swift
//  
//
//  Created by James Swiney on 14/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

/** A singleton that manages all Location Services, contains authorisation, location search and current location. */
@objc(VVVLocationManager) public class LocationManager : NSObject,CountryCoordinator {

    /** The singleton accessor.  */
    public static let shared = LocationManager()
    
    /** Returns the location provided by CoreLocation if available.  */
    public var userLocation : CLLocation? { get {
            return services.currentLocation
        }
    }
    
    /** 2 dimensional array of countrys first array is popular countrys, second array is all countries */
    public internal(set) var countryList = [[Country]]()
    
    /**
     
     Called to display the location services auth prompt. If already displayed will call completion immediately with the current location is available.
     
     - Parameters:
        - completion: The block called once the prompt has been dismissed, will contain users location if available.
     
     */
    public func authoriseServices(completion:@escaping (_ currentLocation : CLLocation?)->()) {
        self.services.authorise(completion: completion)
    }
    
    
    /**
     
     Performs a search for an airport code with block completion containing the Location object of the airport if found.
     
     - Parameters:
        - airportCode: The airport code or part of the airport code to search for eg "SYD"
        - completion: The block to be called once search is finished, can be called immediately.  Will contain location object if found.
     
     */
    public func locationFor(airportCode:String,completion:@escaping (_ location : Location?)->()) {
        self.searchCompleter.resultBasedOn(airportCode: airportCode.lowercased(), completion: completion)
    }
    
    /**
     
     The standard auto complete location search. Will return an array of LocationSearchResult objects in a completion.  If search is nil or empty will return the top 300 locations for Vroom.  This search is queued so it can be called repeatedly without concern ie. the delegate to a UITextfield.
     
     - Parameters:
        - search: The search string to apply to results, can be nil or empty to return top locations.
        - completion: Called once search is complete with an array of LocationSearchResult objects. Can be empty and can be called back immediately.
     
     */
    public func locationResultsFor(search:String?,completion:@escaping (_ locations :[LocationSearchResult])->()) {
        self.searchCompleter.resultsBasedOn(search: search ?? "", completion: completion)
    }
    
    /**
     
     This provides the full location information for a LocationSearchResult object which can then be applied to a search object. Usually would be called once a LocationSearchResult is selected in a Collection or Tableview.
     
     - Parameters:
        - result: The resut to be selected to provide the full location information
        - completion: Called once location information is returned (can happen immediately).
     
     */
    public func selectLocation(result:LocationSearchResult,completion:@escaping (_ location:Location?)->()) {
        self.searchCompleter.convert(result: result, completion: completion)
    }
    
    /** The location services Object that holds the corelocation information */
    let services = LocationServices()
    
    /** The location search performer */
    let searchCompleter  = LocationSearch()
    
    /** Init method, starts the location services and loads the country list. */
    override init() {
        
        super.init()
        //Make Location manager recieve current location updates
        services.delegate = self
        
        //Load popular and all countries
        self.loadPopularAndAll { (countries) in
            self.countryList = countries
        }
    }
}

extension LocationManager {
    
    func phonePrefixFor(country:Country) -> String? {
        
        guard let all = self.countryList.last else { return nil }
        for prefixCountry in all {
            if prefixCountry.code == country.code {
                return prefixCountry.phonePrefix
            }
        }
        return nil
    }
}

//MARK: - Location Services delegate for current location updates
extension LocationManager : LocationServicesDelegate {
    
    func currentLocationUpdated(location: CLLocation) {
        self.searchCompleter.topLocations.sortAllByDistanceFrom(location: location)
    }
    
}

