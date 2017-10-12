//
//  PendingBookingRequest.swift
//  VVV
//
//  Created by James Swiney on 20/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** Returns more information for a specific search result. The information from this request is required for booking request. */
class PendingBookingRequest : APIRequest {
    
    /** Valid search object to be used in request */
    let search : Search
    
    /** The search result to get more information for */
    let result : SearchResult
    
    /** Depot pair to search for vehicles */
    let depots : DepotPair
    
    /** completion block called after request with a pendingBooking or an error message */
    let completion : (PendingBooking?,String?)->()
    
    /**
     
     Inits the request with a search object and a depot pair with completion block
     
     - Parameters:
     - search: The search object.
     - result: The chosen search results object
     - depots: The depot pair for the search result
     - completion: A completion block responding with a pending booking or an error message.
     
     */
    init(search:Search,result:SearchResult,depots:DepotPair,completion:@escaping (PendingBooking?,String?)->()) {
        self.search = search
        self.result = result
        self.completion = completion
        self.depots = depots
    }
    
    override func endPoint() -> NetworkEndpoint {
        return .SearchVehicle
    }
    
    override func method() -> APIMethod {
        return .get
    }
    
    override func params() -> [String : Any] {
        
        var paramsDict = [String:Any]()
        
        paramsDict["supplierCode"] = result.supplier.code
        paramsDict["pickUpDate"] = search.dateRange.start.apiFormattedDateString()
        paramsDict["pickUpTime"] = search.dateRange.start.apiFormattedTimeString()
        paramsDict["returnDate"] = search.dateRange.end.apiFormattedDateString()
        paramsDict["returnTime"] = search.dateRange.end.apiFormattedTimeString()
        paramsDict["driverCountryCode"] = search.residency.code
        paramsDict["driverAge"] = search.age.rawValue
        
        paramsDict["pickUpDepotCode"] = depots.pickupDepot.code
        
        paramsDict["returnDepotCode"] = depots.returnDepot.code
        paramsDict["carCategoryCode"] = result.code
        
        return paramsDict
    }
    
    override func encoding() -> APIParameter {
        return .url
    }
    
    override func responseHandler() -> NetworkResponseHandler {
        return {(response,error) -> Void in
            
            guard let json = response else {
                if let error = error {
                    self.completion(nil,error)
                    return
                }
                self.completion(nil,"No data in response")
                return
            }
            
            if let result = self.map(json: json) {
                self.completion(result, nil)
                return
            }
            
            if let error = self.error(json: json) {
                self.completion(nil,error)
                return
            }
            
            self.completion(nil,"Unknown error occured")
        }
    }
    
    func map(json:Any) -> PendingBooking? {
        guard let jsonDict = json as? [String:Any],
            let data = jsonDict["data"] as? [String:Any],
            let carObject = data.first?.value as? [String:Any],
            let pending = PendingBooking(json: carObject, depots: self.depots, search: self.search) else { return nil }
        
        return pending
    }
    
    func error(json:Any) -> String? {
        guard let jsonDict = json as? [String:Any],
            let message = jsonDict["message"] as? String else { return nil }
        return message
    }
}
