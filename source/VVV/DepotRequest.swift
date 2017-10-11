//
//  VVVAPIDepotRequest.swift
//  VVV
//
//  Created by James Swiney on 14/12/16.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** Uses a search obect to find the closest depot pairs to the searched location.  Returns with an array of depot pairs or an empty array with an error */
class DepotRequest : APIRequest {
    
    /** completion block called after request */
    let completion : ([DepotPair],String?)->()
    
    /** a valid search to use for the request */
    let search : Search
    
    /**
     
     Inits the request with a search object and the completion block
     
     - Parameters:
        - search: A valid search object to find depots for
        - completion: A completion block responding with an array of depotPairs or an error message.
     
     */
    init(search:Search,completion:@escaping ([DepotPair],String?)->()) {
        self.completion = completion
        self.search = search
    }
    
    override func endPoint() -> NetworkEndpoint {
        return .NearestDepot
    }
    
    override func method() -> APIMethod {
        return .get
    }
    
    override func params() -> [String:Any] {
        
        guard let pickupLocation = search.pickupLocation,
            let returnLocation = search.returnLocation else { return [:] }
        
        var pickupType = 2
        var returnType = 2
        
        if pickupLocation.isAirport {
            pickupType = 1
        }
        
        if returnLocation.isAirport {
            returnType = 1
        }
        
        let paramsDict : [String:Any] =
            ["alias":Config.shared.alias ?? "",
             "pickupCoordinate":pickupLocation.locationDetails.commaSeperatedText(),
             "returnCoordinate":returnLocation.locationDetails.commaSeperatedText(),
             "pickUpLocationType":pickupType,
             "returnLocationType":returnType,
             "byPassDefaultRadius":"0",
             "showByPassedDepots":"0"]
        
        return paramsDict
    }
    
    override func encoding() -> APIParameter {
        return .url
    }
    
    override func responseHandler() -> NetworkResponseHandler {
        return {(response,error) -> Void in
            
            guard let json = response else {
                if let error = error {
                    self.completion([],error)
                    return
                }
                self.completion([],"No data in response")
                return
            }
            
            if let results = self.map(json: json) {
                self.completion(results, nil)
                return
            }
            
            if let error = self.error(json: json) {
                self.completion([],error)
                return
            }
            
            self.completion([],"Unknown error occured while retrieving depots")
        }
    }
    
    override func appendToUrl() -> String {
        return ""
    }
    
    func map(json:Any) -> [DepotPair]? {
        
        guard let jsonDict = json as? [String:Any],
            let data = jsonDict["data"] as? [String:[String:Any]] else { return nil }
        
        var results = [DepotPair]()
        
        for (key,object) in data {
            guard let result = DepotPair(json: object, supplierCode: key) else { continue }
            results.append(result)
        }
        
        return results
    }
    
    func error(json:Any) -> String? {
        guard let jsonDict = json as? [String:Any],
            let message = jsonDict["message"] as? String else { return nil }
        return message
    }
}


