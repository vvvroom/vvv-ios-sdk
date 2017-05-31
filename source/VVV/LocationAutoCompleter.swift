//
//  LocationAutoCompleter.swift
//  VVV
//
//  Created by James Swiney on 16/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation
import MapKit

/** Protocol making an object able to be passed as a Location Search Result. Due to different searches providing different objects. */
@objc(VVVLocationSearchResult) public protocol LocationSearchResult {
    
    var title : String { get }
    var subtitle : String  { get }
    
}

/** Making a MKLocalSearchCompletion conforn to the LocationSearchResult protocol (it already has a subtitle and title so it needs no extra information) */
@available(iOS 9.3, *)
extension MKLocalSearchCompletion : LocationSearchResult {

}

/** An object to handle and perform a Location Searches from a number of different sources. It is queued and auto completing so searches can be put in as fast as you like eg. the delete of a changing UITextfield. */
class LocationSearch {
    
    /** The top locations object handling the top locations loaded from VVV API */
    var topLocations = TopLocations()
    
    /** If true tells the search the is currently in progress to ignore its result and not perform a callback when finished.  This can happen if a different source returns with more relevent information before another is finished. */
    var ignoreResults = false
    
    /** Whether or not a current search is in progress */
    var searchInProgress = false
    
    /** If a current search is in progress and a new search is trigger, this will contain the new search and will be performed once the current search is finished. */
    var pendingSearch : String?
    
    //Apple's search completer object
    @available(iOS 9.3, *)
    lazy var completer: MKLocalSearchCompleter? = { return nil }()
    
    /** The Search Completer delegate object which will return results in block format */
    @available(iOS 9.3, *)
    lazy var completerDelegate: AutoCompleteLocalSearchDelegate? = { return nil }()
    
    /** Init and load top locations from API to populate all array */
    init() {
        topLocations.load(completion: nil)
    }
    
    
    /**
     
     The primary Location autocomplete search function. Performs a search via top locations first, if top locations contains no results the Apple's AutoCompleter will then be called.
     
     - Parameters:
        - search: The search string (if empty all toplocations will be returned)
        - completion: Callback block with array of location result objects (can be an empty array if no results) this callback can potentially be called straight away or after some time
     
     */
    func resultsBasedOn(search:String,completion:@escaping ([LocationSearchResult]) -> ()) {
        
        //no results for empty search
        if search.isEmpty {
            completion(topLocations.all)
            return
        }
        
        let topLocationResults = topLocations.searchAll(searchString: search.lowercased())
        if topLocationResults.count > 0 {
            completion(topLocationResults)
            if self.searchInProgress {
                //We don't want the results from apple to override our new search.
                self.ignoreResults = true
            }
            return
        }

        if #available(iOS 9.3, *){
            self.searchUsingAppleCompleter(search: search, completion: { (results) in
                if self.ignoreResults {
                    return
                }
                completion(results)
            })
        } else {
            
            //If a search is inprogress we save the search to be performed after
            if searchInProgress {
                self.pendingSearch = search
                return
            }
            
            searchInProgress = true
            self.searchAppleForPlace(searchString: search, completion: { (results) in
                self.searchInProgress = false
                //ignore results if we got a better result while waiting (typically when the user backspaces alot)
                if self.ignoreResults {
                    self.ignoreResults = false
                    return
                }
                completion(results)
                if let pending = self.pendingSearch {
                    self.pendingSearch = nil
                    self.resultsBasedOn(search: pending, completion: completion)
                }
            })
        }
    }
    
    /**
     
     Finds a location for an Airport code. First searches Top locations then searches apple places.
     
     - Parameters:
        - airportCode: The search string an airport Code or partial airport code eg. "BNE"
        - completion: Callback block with the location object if available.
     
     */
    func resultBasedOn(airportCode:String,completion:@escaping (Location?) -> ()) {
        
        if let topLocationAirport = topLocations.searchAirports(code: airportCode) {
            completion(topLocationAirport)
            return
        }
        self.searchAppleForPlace(searchString: "\(airportCode) airport") { (results) in
            completion(results.first)
        }
    }
    
    
    /**
     
     This will turn a LocationSearchResult into a proper Location object.  This can callback immediately or can take a few moments depending on the LocationSearchResult object.
     
     - Parameters:
        - result: The result to convert to a location.
        - completion: Callback block with the location object if available.
     
     */
    func convert(result:LocationSearchResult,completion:@escaping (Location?)->()) {
        
        if let location = result as? Location {
            completion(location)
            return
        }
        
        guard #available(iOS 9.3, *) else {
            completion(nil)
            return
        }
         guard let completerResult = result as? MKLocalSearchCompletion else {
            completion(nil)
            return
        }
        
        self.searchAppleForCompleterPlace(completerPlace: completerResult) { (possibleLocations) in
            guard let location = possibleLocations.first else {
                completion(nil)
                return
            }
            completion(location)
        }
        
        
    }
}

//MARK: - Apple Pre ios 9 search
extension LocationSearch {
    
    /**
     
     Performs an MKLocalSearchRequest base on a search string.
     
     - Parameters:
     - searchString: The search string to search.
     - completion: Array of Locations matching the search string.
     
     */
    func searchAppleForPlace(searchString:String,completion:@escaping ([Location]) -> ()) {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchString
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            completion(self.mapMKSearchToLocations(response: response))
        }
        
    }
}

//MARK: - Apple Completer search
@available(iOS 9.3, *)
extension LocationSearch {
    
    /**
     
     Accesses the MKLocalSearchCompleter (creates it if needed) and searches matching the search string for locations only.
     
     - Parameters:
        - search: The search string to search.
        - completion: Block with Array of MKLocalSearchCompletion, these adopt the protocol of LocationSearchResult.
     
     */
     func searchUsingAppleCompleter(search:String,completion:@escaping ([MKLocalSearchCompletion]) -> ()) {
        
        if completer == nil {
            completer = MKLocalSearchCompleter()
            completer!.filterType = .locationsOnly
            completerDelegate = AutoCompleteLocalSearchDelegate()
            completer!.delegate = completerDelegate
        }
        completerDelegate?.delegateCompletion = { (results) in
            completion(results)
        }
        completer!.queryFragment = search
    }
    
    /**
     
     This converts a MKLocalSearchCompletion object to a Location array by using the MKLocalSearchRequest.
     
     - Parameters:
        - completerPlace: MKLocalSearchCompletion to convert
        - completion: The block with location array of possible matches (usually only has one result)
     
     */
     func searchAppleForCompleterPlace(completerPlace:MKLocalSearchCompletion,completion:@escaping ([Location]) -> ()) {
        let request = MKLocalSearchRequest(completion: completerPlace)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            completion(self.mapMKSearchToLocations(response: response))
        }
    }
}

//MARK: - Mapping
extension LocationSearch {
    
    /**
     
     This converts an array of MKPlacemark objects into an array of Location Objects
     
     - Parameters:
        - response: The MKLocalSearchResponse which contains an array of placemarks
     - Return:
        - [Location]: Location object array for placemarks.
     
     */
    func mapMKSearchToLocations(response:MKLocalSearchResponse?) -> [Location] {
        
        guard let searchData = response else { return [] }
        var locations = [Location]()
        
        for item in searchData.mapItems {
            guard let location = Location(placemark: item.placemark) else { continue }
            locations.append(location)
        }
        return locations
    }
    
}
