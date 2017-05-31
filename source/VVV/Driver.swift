//
//  DriverDetails.swift
//  VVV
//
//  Created by James Swiney on 22/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation


/**
A object for the creation of the driver details to be attached to the Pending Booking
 */
@objc(VVVDriver) public class Driver : NSObject {
    
    /** The name title eg. "Mr/Mrs" */
    public var title : String?
    
     /** The drivers first name */
    public var firstName : String?
    
    /** The drivers surname */
    public var lastName : String?
    
    /** Convenience variable to display "Mr John Smith" */
    public var fullName : String { get {
        
        guard let title = self.title,
            let first = self.firstName,
            let last = self.lastName else { return "" }
        
        return "\(title) \(first) \(last)"
        
        }
    }
    
    /** The drivers email address */
    public var email : String?
    
    /** Drivers mobile phone number excluding the country code eg. "414444444" */
    public var phoneNumber : String?
    
    /** Drivers mobile phone number country code prefix the eg. "+61" this will be set automatically by the residency of the driver if available. */
    public var phoneCountryPrefix : String?
    
    /**
     
     Sets the phone country code prefix according to a country
     - Parameters:
     - residency:  The country in which to set the phone code from.
     
     */
    public func setPhonePrefixFor(residency:Country) {
        if let prefix = residency.phonePrefix {
            self.phoneCountryPrefix = prefix
            return
        }
        self.phoneCountryPrefix = LocationManager.shared.phonePrefixFor(country: residency)
    }
    
    /**
     
     Valididates the drivers details for a booking will return an empty array if all details are valid.
     - Return:
     - [DriverDetail]:  An array containing driver details that are invalid can be empty.
     
     */
    public func invalidDetails() -> [DriverDetail] {
        
        var invalid = [DriverDetail]()
        
        if self.title == nil {
            invalid.append(.title)
        } else if self.title!.isBlankSpace() {
            invalid.append(.title)
        }
        
        if self.firstName == nil {
            invalid.append(.firstName)
        } else if self.firstName!.isBlankSpace() {
            invalid.append(.firstName)
        }
        
        if self.lastName == nil {
            invalid.append(.lastName)
        } else if self.lastName!.isBlankSpace() {
            invalid.append(.lastName)
        }
        
        if self.email == nil {
            invalid.append(.email)
        } else if self.email!.isBlankSpace() {
            invalid.append(.email)
        }
        
        if self.phoneNumber == nil {
            invalid.append(.phone)
        } else if self.phoneNumber!.isBlankSpace() {
            invalid.append(.phone)
        }
        
        return invalid
    }
    
    /**
     
     All Driver detail types in an array
     - Return:
     - [DriverDetail]:  An array containing driver details.
     
     */
    static func allDetailTypes() -> [DriverDetail] {
        return [.title,.firstName,.lastName,.email,.phone]
    }
}

/**
 All the types of driver details that can be invalid
 
 - title:
 - firstName:
 - lastName:
 - email:
 - phone:
 
 */
@objc(VVVDriverDetail) public enum DriverDetail : Int,RawRepresentable {
    
    case title = 0
    case firstName = 1
    case lastName = 2
    case email = 3
    case phone = 4
    
}
