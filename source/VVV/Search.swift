//
//  VVVSearch.swift
//  VVV
//
//  Created by James Swiney on 14/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation


/**
 The Search object used by the Search Handler to perform the search.
 Can be created manually or by the search handler
 */
@objc(VVVSearch) public class Search : NSObject {
    

    /** Age Group Bracket (will change rates and terms and conditions of booking). */
    public var age : AgeGroup
    
    /** Residental Country of the driver (this will effect results and pricing). */
    public var residency : Country
    
    /** The location in which to search for the nearest Depot to pickup the vehicle for each supplier. */
    public var pickupLocation : Location?
    
    /** The location in which to search for the nearest Depot to return the vehicle for each supplier. */
    public var returnLocation : Location?
    
    /** An array of suppliers to limit the search to. If the array is empty all suppliers will be searched */
    public var limitToSuppliers = [Supplier]()
    
    /** 
    The range in which the booking will take place.
     
        - Start: The pickup date and time of the booking.
        - End: The return date and time of the booking.
     
     */
    public var dateRange : DateRange
    
    /**
     
    Inits the search with the default values
     - dateRange: Start at tomorrow 10:00am and end 3 days from start date.
     - age: Age group 30 - 70
     - residency: Default to Australia or if possible the current locale of the phone.
     
    */
    public override init() {
        self.dateRange = DateRange()
        self.age = .thirty
        self.residency = Country(code: "AU")
        super.init()
        self.setResidencyToLocale()
    }
    
    
    /**
     
     Validity Checking of the search object
     
     - Returns: 
        - Bool: true the search is valid, false the search is invalid
        - [SearchError]: Array of errors, empty if the search is invalid
     
     */
    public func isValid() -> (Bool,[SearchError]) {
        
        var errors  = [SearchError]()
        
        if pickupLocation == nil {
            errors.append(.pickupLocation)
        }
        
        if returnLocation == nil {
            errors.append(.returnLocation)
        }
        
        if dateRange.end.compare(dateRange.start) == .orderedAscending {
            errors.append(.date)
        }
        return (errors.count == 0,errors)
    }

    /**
     
     Set the residency to the phones current locale if possible
     
     */
    public func setResidencyToLocale() {
        
        let locale = Locale.current
        
        guard let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String  else { return }
        
        self.residency = Country(code: code)
    }
    
    /**
     
     Returns the display name for an ageGroup
     
     - Parameters:
        - ageGroup: The age group enum you want the name for
     - Returns:
        - String: The displayName for the ageGroup
     
     */
    public static func displayNameFor(ageGroup:AgeGroup) -> String {
        
        switch ageGroup {
        case .twentyOne:
            return "21 - 24"
        case .twentyFive:
            return "25 - 29"
        case .thirty:
            return "30 - 69"
        case .old:
            return "70+"
        }
        
    }
}


/** A Date Object containing a start and end date  */
@objc(VVVDateRange) public class DateRange : NSObject {
    
    /** The beginning date in the range  */
    public let start : Date
    
    /** The end date in the range  */
    public let end : Date
    
    
    /**
     
     Inits the date with the default values
        - Start: tomorrow 10:00am and end 3 days from start date.
        - End: 3 days from start date
     
     */
    public override init() {
        self.start = Date.dateByAddingDays(date: Date.tenAmTodayOrTomorrow(), days: 3)
        self.end = Date.dateByAddingDays(date: self.start, days: 3)
        super.init()
    }
    
    /**
     
     Inits the date with defined values
     - Parameters:
        - start: Start of the date range
        - end: End of the date range
     
     */
    public init(start:Date,end:Date) {
        self.start = start
        self.end = end
        super.init()
    }
    
    /** Inits the DateRange with the booking json object */
    init?(json:[String:Any]) {
        guard let pickupObject = json["pickUp"] as? [String:Any],
            let returnObject = json["return"] as? [String :Any],
            let start = Date.dateFrom(jsonData: pickupObject),
            let end = Date.dateFrom(jsonData: returnObject) else { return nil }
        
        self.start = start
        self.end = end
        super.init()
    }
}
