//
//  VVVAgeGroup.swift
//  VVV
//
//  Created by James Swiney on 14/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/**
 Age groups available for search.
 
    - twentyOne: Age range of 21 - 24
    - twentyFive: Age range of 25 - 29
    - thirty: Age range of 30 - 69
    - old: Age range of 70+
 */
@objc(VVVAgeGroup) public enum AgeGroup : Int,RawRepresentable {
    
    case twentyOne = 21
    case twentyFive = 25
    case thirty = 30
    case old = 70
    
}

/** A Simple Object representing a country  */
@objc(VVVCountry) public class Country : NSObject  {
    
    /** The ISO country code eg. "US" */
    public var code : String
    
    /** The name of the country eg. "United States" */
    public var name : String
    
    /** The mobile phone prefix of the country eg. "+1" */
    public var phonePrefix : String?
    
    
    /**
     
     Inits the country from a ISO code
     - Parameters:
        - code: The ISO code of the country eg. "US"
    
     */
    public init(code : String) {
        
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: code) {
            self.name = name
        } else {
            self.name = code
        }
        self.code = code
        super.init()
        self.phonePrefix = LocationManager.shared.phonePrefixFor(country: self)
       
    }
    
    //** Faster init method specifying the name as well as ISO code */
    public init(name : String, code : String) {
        self.name = name
        self.code = code
        super.init()
        self.phonePrefix = LocationManager.shared.phonePrefixFor(country: self)
        
    }
}

/**
 Error returned from a Search validity check
 
    - pickupLocation: pickup location variable on search is nil
    - returnLocation: return location variable on search is nil
    - date: The return date is before the pickupdate
 */
public enum SearchError {
    case pickupLocation,returnLocation,date
    
    /** default error message returned for the error type */
    func message() -> String {
        
        switch self {
        case .pickupLocation:
            return "Please enter a Pickup Location"
        case .returnLocation:
            return "Please enter a Return Location"
        case .date:
            return "Return Date must be after pickup date"
        }
    }
    
    /** Returns a newlined message for an error array */
    static func combinedMessage(errors:[SearchError]) -> String {
        
        var message = ""
        for error in errors {
            message.append("\(error)\n")
        }
        return message
    }
}
