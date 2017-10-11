//
//  TopLocationsRequest.swift
//  VVV
//
//  Created by James Swiney on 15/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** Fetches the top locations from VroomVroomVroom (usually around 300). */
class TopLocationsRequest: APIRequest {
    
    /** Completion which returns an array of locations or an error message. */
    var completion : (([Location],String?)->())?
    
    /** An optional search string can be passed into the request to filter results */
    var searchString : String?
    
    init(completion:(([Location],String?)->())?) {
        self.completion = completion
    }
    
    /**
     
     Inits the request with a search object and a depot pair with completion block
     
     - Parameters:
        - searchString: a string to filter by can be blank
        - completion: A completion block responding with a location array or an error message.

     */
    init(searchString:String,completion:(([Location],String?)->())?) {
        self.searchString = searchString
        self.completion = completion
    }
    
    override func endPoint() -> NetworkEndpoint {
        return NetworkEndpoint.TopLocations
    }
    
    override func responseHandler() -> NetworkResponseHandler {
        return { (response,error) -> Void in
            
            guard let responseBlock = self.completion else { return }
            if let response = response {
                responseBlock(self.map(jsonData: response), nil)
                return
            }
            responseBlock([], error)
        }
    }
    
    override func method() -> APIMethod {
        return .get
    }
    
    override func appendToUrl() -> String {
        guard let search = self.searchString else { return "" }
        if !search.isEmpty {
            return "/\(search.replacingOccurrences(of: " ", with: ""))"
        }
        return ""
    }
    
}

extension TopLocationsRequest {
    
    func map(jsonData:Any) -> [Location] {
        
        var locationArray  = [Location]()
        
        guard let jsonDict = jsonData as? [String:Any],
        let array = jsonDict["data"] as? [[String:Any]] else {
            return locationArray
        }
        for object in array {
            if let location = Location(json: object) {
                locationArray.append(location)
                continue
            }
            if let location = Location(searchJSON: object) {
                locationArray.append(location)
            }
        }
        return locationArray
    }
    
    
}

