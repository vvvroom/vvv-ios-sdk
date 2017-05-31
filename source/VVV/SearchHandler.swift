//
//  SearchHandler.swift
//  VVV
//
//  Created by James Swiney on 20/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/**
 The Search handler is the core object used to perform searches.  First depots are searched for (for each supplier) that are near the pickuplocation and the returnlocation, then each depot pair is searched for rental vehicle results.  Callbacks are provided via the delegate.
 */
@objc(VVVSearchHandler) public class SearchHandler : NSObject,APIRequestPerformer {
    
    /** Object containing all results once a search has been performed */
    public var results : SearchResults?
    
    /** The delegate to recieve all search result and error callbacks */
    public var delegate : SearchHandlerDelegate?
    
    /**
     
     Performs a search for an airport location
     - Parameters:
        - atAirportCode: The airport code to pickup and return at eg. "SYD"
        - dateRange: Date range of the rental
        - residencyCode: The country code the driver is a resident of eg. "US"
        - age: The age group the driver belongs to
     
     */
    public func search(atAirportCode:String,dateRange:DateRange,residencyCode:String,age:AgeGroup) {
        
        let search = Search()
        search.dateRange = dateRange
        search.residency = Country(code: residencyCode)
        search.age = age
        self.current = search
        self.perform(search: search, atAirport: atAirportCode)
    }
    
    /**
     
     Performs a preconstruced search object
     - Parameters:
        - search: The search object, will call the error delegate if search is invalid
     
     */
    public func perform(search:Search) {
        
        guard let delegate = self.delegate else { return }
        
        let valid = search.isValid()
        
        //If search is invalid callback search errors and abandon search
        if !valid.0 {
            delegate.searchHandlerFinishedEarly(error: SearchError.combinedMessage(errors: valid.1))
            return
        }
        
        self.current = search
        self.startDepotRequest()
    }
    
    /**
     
     Selects a results to create a pending booking object.  Pending booking includes more information including extras and fees for the rental.  A pending booking then allows a booking to be creating from it.
        - Parameters:
        - result: The search result object to be selected.
     
     */
    public func select(result:SearchResult) {
       self.createPendingFrom(result: result)
    }
    
    /** The search currently being performed. Will be replaced by a new search */
    var current : Search?
    
    /** All the depotpairs found by the current search. Will be replaced by a new search */
    var depots = [DepotPair]()
    
    
    /**
     
     Uses an existing search but uses an airport code to determine the pickup and return locations.  Will call the fail delegate if location cannot be found.
     - Parameters:
        - search:  The search object, pickup and return location will be ignored
        - atAirport: Airport code eg. "BNE"
     
     */
    func perform(search:Search,atAirport:String) {
        
        guard let delegate = self.delegate else { return }
        
        LocationManager.shared.locationFor(airportCode: atAirport) { (location) in
            guard let result = location else {
                delegate.searchHandlerFinishedEarly(error: "No Location found for airport code")
                return
            }
            search.pickupLocation = result
            search.returnLocation = result
            self.startDepotRequest()
        }
    }
}

//MARK: - Search Handler Protocol
/**
 The protocol implemented by the delegate of the Search Handler, provides all callbacks for the progress of a search and the creation of a pending booking.
 */
@objc(VVVSearchHandlerDelegate) public protocol SearchHandlerDelegate {
    
    /**
     
     An optional callback, will call once for a search, and will be the first callback with the depots that will be used for the rest of the search.
     - Parameters:
        - depots:  An array of all depot pairs found per supplier.
     
     */
    @objc optional func searchHandlerFound(depots:[DepotPair])
    
    /**
     
     An optional callback, will call multiple times per search, once for each supplier (this can be used to dynamically update results as they are recieved
     - Parameters:
        - results:  Array of results found.
        - supplier: Supplier for the results.
     
     */
    @objc optional func searchHandlerFound(results:[SearchResult],supplier:Supplier)
    
    /**
     
     The main callback for a search, this is called once per search. When the search finishes with the completed results.
     - Parameters:
        - searchResults:  Search results object containing all results for all suppliers.
     
     */
    func searchHandlerFinishedSearching(searchResults:SearchResults)
    
    /**
     
     An optional callback, will call multiple times per search, once per supplier that recieves an error. An example error would be closed depots.
     - Parameters:
        - error:  The error message.
        - supplier: Supplier with the message.
     
     */
    @objc optional func searchHandlerReceived(error:String,supplier:Supplier)
    
    /**
     
     The main error callback for the search. This will be called any time the search fails due to an error.
     - Parameters:
        - error:  The error message.
     
     */
    func searchHandlerFinishedEarly(error:String)
    
    /**
     
     The is the callback to the select(result:) method of the search handler.
     - Parameters:
        - pendingBooking:  pending booking created from the search result
     
     */
    func searchHandlerCreated(pendingBooking:PendingBooking)
    
    /**
     
     The is the error callback to the select(result:) method of the search handler.
     - Parameters:
        - error:  the error message.
     
     */
    func searchHandlerFailedPendingBookingWith(error:String)
}

//MARK: - NetworkRequests
extension SearchHandler {
    
    
    /**
     
     This is the first step of the search, performs the nearby depot request.
     
     */
    func startDepotRequest() {
        guard let search = self.current else { return }
        
        //Fetch the supplier list incase it isn't loaded yet
        SupplierManager.shared.loadSuppliersIfNeeded { 
            
            let request = DepotRequest(search: search) { (results, error) in
                
                guard let delegate = self.delegate else { return }
                
                if let error = error {
                    delegate.searchHandlerFinishedEarly(error: error)
                    return
                }
                self.depots = results
                delegate.searchHandlerFound?(depots: results)
                self.start(search: search)
            }
            
            self.perform(apiRequest: request)
            
        }
        
    }
    
    /**
     
     This loops through all suppliers and performs a search for each one.
     - Parameters:
        - search:  the search object
     
     */
    func start(search:Search) {
        
        guard let delegate = self.delegate else { return }
        
        var searchCount = 0
        
        //create search results object
        let results = SearchResults()
        self.results = results
        
        for depot in self.depots {
            
            self.search(depotPair: depot, search: search, completion: { (response, error) in
                searchCount+=1
                
                guard let response = response else {
                    if let error = error {
                        delegate.searchHandlerReceived?(error: error, supplier: depot.supplier)
                    } else {
                        delegate.searchHandlerReceived?(error: "Unknown error occured", supplier: depot.supplier)
                    }
                    if searchCount == self.depots.count {
                        delegate.searchHandlerFinishedSearching(searchResults: results)
                    }
                    return
                }
                
                results.responses.append(response)
                delegate.searchHandlerFound?(results: response.results, supplier: depot.supplier)
                
                //If we are up to the last response then do our final callback
                if searchCount == self.depots.count {
                    delegate.searchHandlerFinishedSearching(searchResults: results)
                }
            })
            
        }
    }
    
    /**
     
     This performs the searchvehicles request
     - Parameters:
        - depotPair:  The depots object to search.
        - search: the search object
        - completion: the completion callback with
            - response: Search response
            - error: the error message.
     
     */
    func search(depotPair:DepotPair,search:Search,completion:@escaping (SearchResponse?,String?)->()) {
        let request = SearchVehicleRequest(search: search, depots: depotPair, completion: completion)
        self.perform(apiRequest: request)
    }
    
    
    /**
     
     This performs the searchVehicle request to create a pending booking object.
     - Parameters:
        - result:  The result object ot search.
     
     */
    func createPendingFrom(result:SearchResult) {

        guard let searchResults = self.results,
            let search = self.current,
            let response = searchResults.responseFor(result: result),
            let delegate = self.delegate else { return }
        
        let request = PendingBookingRequest(search: search, result: result, depots: response.depots) { (pending, error) in
            guard let pending = pending else {
                if let error = error {
                    delegate.searchHandlerFailedPendingBookingWith(error: error)
                } else {
                    delegate.searchHandlerFailedPendingBookingWith(error: "Unknown error occured")
                }
                return
            }
            delegate.searchHandlerCreated(pendingBooking: pending)
        }
        self.perform(apiRequest: request)
    }
}

