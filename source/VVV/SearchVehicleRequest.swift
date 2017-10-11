//
//  SearchVehicleRequest.swift
//  VVV
//
//  Created by James Swiney on 17/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation


/** Uses a search object and a Depot Pair object to find a list of vehicles for the Depot pair at the daterange specified in the search object. */
class SearchVehicleRequest : APIRequest {
    
    /** completion block called after request */
    let completion : (SearchResponse?,String?)->()
    
    /** Valid search object to be used in request */
    let search : Search
    
    /** Depot pair to search for vehicles */
    let depots : DepotPair
    
    /**
     
     Inits the request with a search object and a depot pair with completion block
     
     - Parameters:
     - search: A valid search object
     - depots: A valid the depot pair to search for vehicles at
     - completion: A completion block responding with a search response or an error message.
     
     */
    init(search:Search,depots:DepotPair,completion:@escaping (SearchResponse?,String?)->()) {
        self.completion = completion
        self.search = search
        self.depots = depots
    }
    
    override func endPoint() -> NetworkEndpoint {
        return .SearchVehicles
    }
    
    override func method() -> APIMethod {
        return .get
    }
    
    override func params() -> [String : Any] {
        
        var paramsDict = [String:Any]()
        
        paramsDict["supplier"] = depots.supplier.code
        paramsDict["pickUpDate"] = search.dateRange.start.apiFormattedDateString()
        paramsDict["pickUpTime"] = search.dateRange.start.apiFormattedTimeString()
        paramsDict["returnDate"] = search.dateRange.end.apiFormattedDateString()
        paramsDict["returnTime"] = search.dateRange.end.apiFormattedTimeString()
        paramsDict["countryCode"] = search.residency.code
        paramsDict["driverAge"] = search.age.rawValue
        
        var pickupDepots = [String:[String:Any]]()
        pickupDepots["0"] = depots.pickupDepot.toParams()
        
        var returnDepots = [String:[String:Any]]()
        returnDepots["0"] = depots.returnDepot.toParams()
        
        paramsDict["pickUpDepot"] = pickupDepots
        paramsDict["returnDepot"] = returnDepots
        
        var searchLocationDict = [String:Any]()
        searchLocationDict["alias"] = Config.shared.alias ?? ""
        searchLocationDict["pickupLocationCoordinates"] = search.pickupLocation?.locationDetails.commaSeperatedText()
        searchLocationDict["returnLocationCoordinates"] = search.returnLocation?.locationDetails.commaSeperatedText()
        searchLocationDict["pickUpLocationType"] = depots.pickupDepot.location.searchtype()
        searchLocationDict["returnLocationType"] = depots.returnDepot.location.searchtype()
        paramsDict["searchLocation"] = searchLocationDict

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

            if let results = self.map(json: json) {
                self.completion(results, nil)
                return
            }
            
            if let error = self.error(json: json) {
                self.completion(nil,error)
                return
            }
            
            self.completion(nil,"Unknown error occured")
        }
    }
    
    override func appendToUrl() -> String {
        return ""
    }
    
    func map(json:Any) -> SearchResponse? {
        
        guard let jsonDict = json as? [String:Any],
            let data = jsonDict["data"] as? [String:[String:Any]],
            let response = SearchResponse(json: data, depots: self.depots) else { return nil }
        
        return response
    }
    
    func error(json:Any) -> String? {
        guard let jsonDict = json as? [String:Any],
            let message = jsonDict["message"] as? String else { return nil }
        return message
    }
}
