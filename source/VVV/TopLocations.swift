//
//  TopLocations.swift
//  VVV
//
//  Created by James Swiney on 15/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

/** An object that can fetch and store the Top 300ish locations from Vroom and perform searching and filtering */
class TopLocations  {
    
    /** All of the fetched Locations from Vroom */
    var all = [Location]()
    
}

extension TopLocations : APIRequestPerformer {
    
    /**
     
     Perform the Top location request to fetch the top locations and store them in the all variable.
     
     - Parameters:
     - completion: Completion block called once completed
        - [Location]: Array of all the top locations.
     
     */
    func load(completion:(([Location])->())?) {
        
        let request = TopLocationsRequest { (locations, error) in
            self.all = locations
            if let block = completion {
                block(locations)
            }
        }
        self.perform(apiRequest: request)
    }
    
    /**
     
     Sorts the `all` locations array by distance from a specified location.
     
     - Parameters:
        - location: The location to sort the distance of all locations from.
     
     */
    func sortAllByDistanceFrom(location:CLLocation) {
        
        all.sort { (location1, location2) -> Bool in
            let distance1 = location.distance(from: location1.locationDetails)
            let distance2 = location.distance(from: location2.locationDetails)
            return distance1 < distance2
        }
    }
}

//MARK: - Search
extension TopLocations {
    
    /**
     
     Search a location in all which matches the specified Airport Code
     
     - Parameters:
        - code: The airport code to search for eg. "BNE"
     - Return:
        - Location: The location matching the airport code if available.
     
     */
    func searchAirports(code:String) -> Location? {
        let airportPredicate = NSPredicate(format: "airportCode CONTAINS[cd] %@", code)
        let results = all.filter({ airportPredicate.evaluate(with: $0) })
        return results.first
    }
    
    /**
     
     Searches all the locations that begin with the search string or contain an airport code that begins with the search string.
     
     - Parameters:
        - searchString: The search string to filter results matching
     - Return:
        - [Location]: Locations matching the search string criteria, can be an empty array.
     
     */
    func searchAll(searchString:String) -> [Location] {
        let searchPredicate = NSPredicate(format: "fullName BEGINSWITH[cd] %@", searchString)
        let airportPredicate = NSPredicate(format: "airportCode BEGINSWITH[cd] %@", searchString)
        let compound = NSCompoundPredicate(orPredicateWithSubpredicates: [searchPredicate,airportPredicate])
        
        let results = all.filter({ compound.evaluate(with: $0) })
        return results
    }
    
}

