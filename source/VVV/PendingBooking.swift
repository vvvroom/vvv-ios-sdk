//
//  PendingBooking.swift
//  VVV
//
//  Created by James Swiney on 21/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/**
 The Pending Booking object is the object created when selecting a search result, it contains more information such as fees, extras and Driver details.  It can be submitted to create a booking.
 */
@objc(VVVPendingBooking) public class PendingBooking : SearchResult,APIRequestPerformer {
    
    /** The pickup and return depots and the supplier for the booking */
    public let depots : DepotPair
    
    /** The dateRange for the booking */
    public let dateRange : DateRange
    
    /** The age group of the driver for the booking */
    public let age : AgeGroup
    
    /** The country of residency of the driver for the booking */
    public let residency : Country
    
    /** An array of the fee breakdown for the booking (can be empty) */
    public let fees : [Fee]
    
    /** An array of possible extras to be added to the booking (can be empty) */
    public let extras : [PendingExtra]
    
    /** The personal driver details of the driver for the booking */
    public var driver = Driver()
    
    
    /**
     
     Submit the pending booking to create a booking with Vroom and with the Supplier
     - Parameters:
     - completion:  The completion block to be called
        - booking: A booking object if the booking was successfully placed
        - error: An error message to be displayed upon failing to place the booking.
     
     */
    public func submit(completion:@escaping (_ booking:Booking?,_ error:String?)->()) {
        let request = CreateBookingRequest(pending: self, completion: completion)
        self.perform(apiRequest: request)
    }
    
    /**
     
     Request to increase an extras amount to the booking if the amount is 0 the extra is removed from the booking.
     - Parameters:
        - extra:  The extra to change the amount of
        - byAmount: Amount of the extra to add must be lower than the max amount of the extra
     - Return: 
        - ExtraRequestStatus: The status of the amendment to the extra.
     
     */
    public func request(extra:PendingExtra,byAmount:Int) -> ExtraRequestStatus {
        
        if byAmount == 0 {
            extra.quatityRequested = 0
            return .completed
        }
        
        if byAmount + extra.quatityRequested > extra.maxQuantity {
            return .overMaxQuantity
        }

        if extra.isSeatType() && byAmount + extra.quatityRequested + self.totalExtraSeatsRequested() > 2 {
            return .overTotalSeatsAllowed
        }
        
        extra.quatityRequested = extra.quatityRequested + byAmount
        return .completed
    }
    
    /**
     
     If the booking is at an airport adding a flight number ensures that the depot will have a car available if the flight is delayed.  Will only accept valid flight numbers eg. "QA123"
     - Parameters:
        - flightNumber:  The flight number
     - Return:
        Bool: if the flight number is valid returns true otherwise false
     
     */
    public func add(flightNumber:String) -> Bool {
        if Utils.validate(flightNumber: flightNumber) {
            self.flightNumber = flightNumber
            return true
        }
        return false
    }
    
    /**
     
     Supplys an array of terms for a full list of terms and conditions from the supplier. Based on the details in the pending booking.
     - Parameters:
     - completion:
        - terms : The array of term objects if available.
        - error : The error string if available.
     
     */
    public func fetchTermsAndConditions(completion:@escaping (_ terms:[SupplierTerm]?,_ error:String?)->()) {
        
        let request = TermsAndConditionsRequest(pendingBooking: self, completion: completion)
        self.perform(apiRequest: request)
    }
    
    /** the flight number for the booking if available */
    var flightNumber : String?
    
    /** vehicle class id, used in the booking request */
    let classID : Int
    
    /** vehicle category id, used in the booking request */
    let categoryID : Int
    
    /** universal car rental id, used in the booking request */
    let sippID : Int
    
    
    /**
     
     Init with the json object
     - Parameters:
        - json:  json object from the search/vehicle request
        - depots: Depot pair for the booking
        - search: The search object for the booking
     
     */
    init?(json: [String : Any], depots: DepotPair,search:Search) {
        
        guard let sippID = json["sippId"] as? Int,
            let categoryDict = json["vehicleCategory"] as? [String:Any],
            let categoryID = categoryDict["id"] as? Int,
            let classDict = json["vehicleClass"] as? [String:Any],
            let classID = classDict["id"] as? Int else {
                print("failed to map pending \(json.debugDescription)")
                return nil
        }
        
        self.classID = classID
        self.categoryID = categoryID
        self.sippID = sippID
        
        self.depots = depots
        self.dateRange = search.dateRange
        self.age = search.age
        self.residency = search.residency
        
        var feeArray = [Fee]()
        if let feesJson = json["fees"] as? [[String:Any]] {
            for object in feesJson {
                guard let fee = Fee(json: object) else { continue }
                feeArray.append(fee)
            }
        }
        
        self.fees = feeArray
        
        var extraArray = [PendingExtra]()
        if let extraJson = json["extras"] as? [[String:Any]] {
            for object in extraJson {
                guard let extra = PendingExtra(json: object) else { continue }
                extraArray.append(extra)
            }
        }
        
        self.extras = extraArray
        super.init(json: json, supplier: depots.supplier)
        self.driver.setPhonePrefixFor(residency: self.residency)
    }
    
     /** 
     
     Utility method calculation total seats, as there is a maximum amount of combined seats that can be added to a booking
     - Return:
        - Int:  total number of seats requested
     
     */
    func totalExtraSeatsRequested() -> Int {
        
        var count = 0
        
        for extra in extras {
            if extra.isSeatType() {
                count = count + extra.quatityRequested
            }
        }
        
        return count
    }
    
}

/**
 An object representing an individual fee from the fees breakdown of a pending/booking.
 */
@objc(VVVFee) public class Fee : NSObject {
    
    /** The amount of the fee */
    public let amount : Decimal
    
    /** The description of the fee eg. "Premium location surcharge" */
    public let details : String
    
    /**
     
     Init with the json object from withing the fees jsonArray of search/vehicle and booking/create
     - Parameters:
        - json:  json object
     
     */
    init?(json:[String:Any]) {
        
        guard let amount = json["amount"] as? Double,
            let details = json["description"] as? String else { return nil }
        
        self.amount = Decimal(floatLiteral: amount)
        self.details = details
        super.init()
    }
}

/**
 An object representing an an optional extra for a pending booking.
 */
@objc(VVVPendingExtra) public class PendingExtra : NSObject {
    
    /** The display name of the Extra eg. "GPS" */
    public let extraName : String
    
    /** The price of the Extra eg. "GPS" */
    public let price : Decimal
    
    /** The maximam amount of this extra that can be added to a booking. eg for Baby seats it is 2 */
    public let maxQuantity : Int
    
    /** The text description of the extra */
    public let extraDescription : String
    
    /** The maximam amount of this extra that can be added to a booking. eg for Baby seats it is 2 */
    public internal(set) var quatityRequested = 0
    
    /** The maximam price of this extra if available */
    var maxPrice : Decimal?
    
    /** The identifier for the extra */
    let identifier : Int
    
    /**
     
     Init with the json object from withing the extra jsonArray of search/vehicle
     - Parameters:
     - json:  json object
     
     */
    init?(json: [String:Any]) {
        guard let identifier = json["id"] as? Int,
            let name = json["name"] as? String,
            let price = json["price"] as? Double,
            let maxQuantity = json["maxQuantity"] as? Int else {
                print("skipping extra")
                return nil
        }
        
        self.identifier = identifier
        self.extraName = name
        self.extraDescription = json["description"] as? String ?? ""
        self.price = Decimal(floatLiteral: price)
        if let maxPriceString = json["maxPrice"] as? String {
            self.maxPrice = Decimal(string: maxPriceString)
        }
        self.maxQuantity = maxQuantity
        
        super.init()
    }

    
    /** Determines whether or not the extra is a seat, as there is a maximum total amount of extra seats to a booking */
    func isSeatType() -> Bool {
        switch identifier {
        case 2,3,4:
            return true
        default:
            return false
        }
    }
}

/**
 
 Status returned from Requesting an Extra on a pending booking
 
 - completed: pickup location variable on search is nil
 - overMaxQuantity: return location variable on search is nil
 - overTotalSeatsAllowed: The return date is before the pickupdate
 
 */
@objc(VVVExtraRequestStatus) public enum ExtraRequestStatus : Int,RawRepresentable {
    case completed = 0
    case overMaxQuantity = 1
    case overTotalSeatsAllowed = 2
}


