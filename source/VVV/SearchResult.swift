//
//  SearchResult.swift
//  VVV
//
//  Created by James Swiney on 17/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** An object containing information about a rental vehicle. */
@objc(VVVSearchResult) public class SearchResult : NSObject {
    
    /** The name of the rental vehicle eg. "Toyota Yaris or similar" */
    public let name : String
    
    /** The url of the image of the rental vehicle */
    public let imageUrl : String
    
    /** A string detailing the mileage. eg. "Unlimited" or "100km" */
    public let mileage : String
    
    /** The pricing of the rental vehicle */
    public let cost : Cost
    
    /** The features of the rental vehicle */
    public let features : Features
    
    /** The supplier of the rental vehicle */
    public let supplier : Supplier
    
    /** The category of the rental vehicle eg. "Compact" */
    public let category : String
    
    /** The code identifier of the rental vehicle eg. "Compact" */
    public let code : String
    
    /** The rateId of this search result. */
    public let rateId : String
    
    /** The code of the pickup depot. */
    var pickupCode : String?
    
    /** The code of the return depot. */
    var returnCode : String?
    
    
    /**
     
     Init with the json object
     - Parameters:
        - json:  json object.
        - supplier: the supplier for the result.
     
     */
    init?(json:[String:Any],supplier:Supplier) {
        
        guard let name = json["name"] as? String,
            let imageUrl = json["vehicleImage"] as? String,
            let mileage = json["mileage"] as? String,
            let category = json["category"] as? String,
            let code = json["categoryCode"] as? String,
            let rateId = json["rateID"] as? String,
            let cost = Cost(json:json),
            let features = Features(json: json) else {
                print("failed to map result \(json.debugDescription)")
                return nil
        }
        
        self.supplier = supplier
        self.name = name
        
        //Sometimes the url comes without a prefix just the // so we need to append.
        if !imageUrl.contains("http") {
            self.imageUrl = "https:\(imageUrl)"
        } else {
            self.imageUrl = imageUrl
        }
        
        self.mileage = mileage
        self.category = category
        self.code = code
        self.rateId = rateId
        self.cost = cost
        self.features = features
        self.pickupCode = json["pickUpDepotCode"] as? String
        self.returnCode = json["returnDepotCode"] as? String
        
        super.init()
    }
    
}
