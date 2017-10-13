//
//  ResultComponants.swift
//  VVV
//
//  Created by James Swiney on 20/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** An object containing the mileage of a search result or booking */
@objc(VVVMileage) public class Mileage : NSObject {
    
    /** The display name for mileage eg. "Unlimited Km" */
    public let displayName : String
    
    /** Whether or not mileage is unlimited */
    public let isUnlimited : Bool
    
    /**
     
     Init with the searchvehicle/s mileage object
     - Parameters:
     - json:  mileage json object
     
     */
    init?(json:[String:Any]) {
        guard let distanceUnit = json["distanceUnit"] as? String,
            let duration = json["duration"] as? String else { return nil }
        
        self.isUnlimited = json["isUnlimited"] as? Bool ?? false
        if isUnlimited {
            self.displayName = "Unlimited \(distanceUnit)"
        } else {
            self.displayName = "\(duration) \(distanceUnit)"
        }
        
        super.init()
    }
    
}

/** An object containing the cost of a search result or booking */
@objc(VVVCost) public class Cost : NSObject {
    
    /** The total estimated price of the search result/booking */
    public let total : Decimal
    
     /** The per day estimated price of the search result/booking if available */
    public var perDay : Decimal?
    
    /** The per day estimated price of the search result/booking if available */
    public let currency : String
    
    
    /**
     
     Init with the searchvehicle/s response
     - Parameters:
        - json:  search vehicle/s response json object
     
     */
    init?(json:[String:Any]) {
        guard let costDict = json["vehicleCost"] as? [String:Any],
            let currency = json["currencyCode"] as? String,
            let total = costDict["totalCost"] as? Double else { return nil }
        
        self.total = Decimal(floatLiteral: total)
        self.perDay = Decimal(floatLiteral: json["perDayPrice"] as? Double ?? 0)
        self.currency = currency
        super.init()
    }
}

/** An object containing the transmission information Feature */
@objc(VVVTransmission) public class Transmission : NSObject  {
    
    /** The code identifier of a transmission eg. "MT" */
    public let code : String
    
    /** The descriptive name of transmission eg. "Manual Transmission" */
    public let transmissionName : String
    
    
    /**
     
     Init with the json response
     - Parameters:
        - json: json object
     
     */
    init?(json:[String:Any]) {
        guard let transmission = json["transmission"] as? [String:Any],
            let code = transmission["code"] as? String,
            let name = transmission["name"] as? String else { return nil }
        self.code = code
        self.transmissionName = name
        super.init()
    }
}

/** An object containing the luggage capacity */
@objc(VVVLuggage) public class Luggage : NSObject  {
    
    /** The amound of small bags */
    public let small : Int
    
    /** The amound of large bags */
    public let large : Int
    
    
    /**
     
     Init with the json response
     - Parameters:
     - json: json object
     
     */
    init(json:[String:Any]) {
        self.small = json["small"] as? Int ?? 0
        self.large = json["large"] as? Int ?? 0
        super.init()
    }
}

/** An object containing the features of a search result */
@objc(VVVFeatures) public class Features : NSObject {
    
    /** Whether or not the vehicle has air conditioning */
    public let aircon : Bool
    
    /** The transmission type of the vehicle */
    public let transmission : Transmission
    
    /** The number of doors in the vehicle */
    public let doors : Int
    
    /** The number of seats in the vehicle */
    public let seats : Int
    
    /** The luggage capacity of the vehicle */
    public let luggage : Luggage
    
    
    /**
     
     Init with the searchvehicle/s response
     - Parameters:
        - json:  search vehicle/s response json object
     
     */
    init?(json:[String:Any]) {
        guard let transmission = Transmission(json: json) else { return nil }
        
        self.aircon = json.typeValueFor(key: "hasAirConditioning", type: Bool.self)
        self.doors = json.typeValueFor(key: "doorCount", type: Int.self)
        self.seats = json.typeValueFor(key: "seatCount",type: Int.self)
        self.luggage = Luggage(json: json["luggage"] as? [String:Any] ?? [:])
        self.transmission = transmission
        super.init()
    }
}
