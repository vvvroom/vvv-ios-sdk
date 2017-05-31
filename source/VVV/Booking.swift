//
//  Booking.swift
//  VVV
//
//  Created by James Swiney on 22/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/**
 The Booking object is the object created when submitting a pending booking and it is successfully created with Vroom and the Supplier.
 */
@objc(VVVBooking) public class Booking : NSObject,APIRequestPerformer {
    
    /** The Vroom booking identifier */
    public let identifier : Int
    
    /** The Supplier confirmation number, shown in emails and all supplier and vroom communication */
    public let supplierConfirmation : String
    
     /** The name of the vehicle in the booking eg. "Toyota Yaris or similair" */
    public let vehicleName : String
    
    /** The url of the image of the rental vehicle */
    public let imageUrl : String
    
    /** A string detailing the mileage. eg. "Unlimited" or "100km" */
    public let mileage : String
    
    /** The personal driver details of the driver for the booking */
    public let driver : BookedDriver
    
    /** The pricing of the rental vehicle */
    public let cost : Cost
    
    /** An array of the fee breakdown for the booking (can be empty) */
    public let fees : [Fee]
    
    /** An array of extras requested for the booking (can be empty) */
    public let extras : [BookedExtra]
    
    /** The features of the rental vehicle */
    public let features : Features
    
    /** The dateRange for the booking */
    public let dateRange : DateRange
    
    /** The pickup and return depots and the supplier for the booking */
    public let depots : DepotPair
    
    /** The current status of the booking */
    public let status : BookingStatus
    
    /** The flight number of the booking if entered */
    public let flightNumber : String?
    
    /**
     
     Cancel and booking with Vroom and the supplier
     - Parameters:
     - completion:  The completion block to be called
        - Bool: Whether or not the cancellation was successful
        - error: An error message to be displayed upon failing to cancel the booking.
     
     */
    public func cancel(completion:@escaping (_ success:Bool,_ error:String?)->()) {
        let request = CancelRequest(booking: self, completion: completion)
        self.perform(apiRequest: request)
    }
    
    
    /**
     
     Fetch a booking by the drivers lastname and confirmation number
     - Parameters:
     - lastName:  Driver of the bookings lastname
     - confirmation: Confirmation number of the booking
     - completion: If a booking is found will callback with the booking otherwise will callback with an error.
     
     */
    public static func fetchWith(lastName:String,confirmation:String,completion:@escaping (_ booking:Booking?,_ error:String?)->()) {
        let request = FetchBookingRequest(lastName: lastName, confirmation: confirmation, completion: completion)
        APIClient.shared.perform(apiRequest: request)
    }
    
    
    /**
     
     Supplys an array of terms for a full list of terms and conditions from the supplier for this particular booking.
     - Parameters:
     - completion:
        - terms : The array of term objects if available.
        - error : The error string if available.
     
     */
    public func fetchTermsAndConditions(completion:@escaping (_ terms:[SupplierTerm]?,_ error:String?)->()) {
        
        let request = TermsAndConditionsRequest(booking: self, completion: completion)
        self.perform(apiRequest: request)
    }
    
    /**
     
     Init with the json object
     - Parameters:
     - json:  json object from the booking/create request
     
     */
    init?(json:[String:Any]) {
        guard let identifier = json["bookingID"] as? Int,
            let confirmation = json["confirmation"] as? String,
            let supplierCode = json["supplierCode"] as? String,
            let vehicleName = json["name"] as? String,
            let imageUrl = json["vehicleImage"] as? String,
            let mileage = json["mileage"] as? String,
            let driverJson = json["driver"] as? [String:Any],
            let statusJson = json["bookingStatus"] as? [String:Any],
            let status = BookingStatus(json: statusJson),
            let driver = BookedDriver(json:driverJson),
            let cost = Cost(bookingJson:json),
            let features = Features(bookingJson:json),
            let dates = DateRange(json: json),
            let depots = DepotPair(bookingJson: json, supplierCode: supplierCode) else {
            return nil
        }
        self.identifier = identifier
        self.supplierConfirmation = confirmation
        self.vehicleName = vehicleName
        
        //Sometimes the url comes without a prefix just the // so we need to append.
        if !imageUrl.contains("http") {
            self.imageUrl = "https:\(imageUrl)"
        } else {
            self.imageUrl = imageUrl
        }
        
        self.mileage = mileage
        self.driver = driver
        self.cost = cost
        self.features = features
        self.dateRange = dates
        self.depots = depots
        self.status = status
        self.flightNumber = json["flightNumber"] as? String
        
        var feeArray = [Fee]()
        if let feesJson = json["fees"] as? [[String:Any]] {
            for object in feesJson {
                guard let fee = Fee(json: object) else { continue }
                feeArray.append(fee)
            }
        }
        self.fees = feeArray
        
        var extraArray = [BookedExtra]()
        if let extraJson = json["extras"] as? [[String:Any]] {
            for object in extraJson {
                guard let extra = BookedExtra(json: object) else { continue }
                extraArray.append(extra)
            }
        }
        
        self.extras = extraArray
        super.init()
    }
}

/**
 A read only driver details attached to a booking object
 */
@objc(VVVBookedDriver) public class BookedDriver : NSObject {
    
    /** The Country of the residence of the driver */
    public let residency : Country
    
    /** The age groupe of the driver */
    public let age : AgeGroup
    
    /** The name title eg. "Mr/Mrs" */
    public let title : String
    
    /** The drivers first name */
    public let firstName : String
    
    /** The drivers surname */
    public let lastName : String
    
    /** Convenience variable to display "Mr John Smith" */
    public var fullName : String { get {
        return "\(self.title) \(self.firstName) \(self.lastName)"
        }
    }
    
    /** The drivers email address */
    public let email : String
    
    /** Full mobile phone number including phone country code prefix eg. "+61444444444" */
    public let phoneNumber : String
    
    
    /**
     
     Init with the json object
     - Parameters:
     - json:  driver json object from the booking/create request
     
     */
    init?(json:[String:Any]) {
        guard let countryCode = json["countryCode"] as? String,
            let ageInt = json["driverAge"] as? Int,
            let age = AgeGroup(rawValue: ageInt),
            let title = json["title"] as? String,
            let first = json["firstName"] as? String,
            let last = json["lastName"] as? String,
            let phone = json["phone"] as? String,
            let email = json["email"] as? String else { return nil }
        
        self.residency = Country(code: countryCode)
        self.age = age
        self.title = title
        self.firstName = first
        self.lastName = last
        self.phoneNumber = phone
        self.email = email
        super.init()
    }
    
}

/**
 An Extra object that has been requested to be added to a booking.
 */
@objc(VVVBookedExtra) public class BookedExtra : NSObject {
    
    /** The display name of the Extra eg. "GPS" */
    public let extraName : String
    
    /** The price of the Extra eg. "GPS" */
    public let price : Decimal
    
    /** The amount of this extra that has been requested eg. 1 GPS or 2 Baby Seats */
    public let quantitySelected : Int
    
    /** Detailed description of the requested extra. */
    public let extraDescription : String
    
    /** The identifier for the extra */
    let identifier : Int
    
    
    /**
     
     Init with the json object
     - Parameters:
     - json:  extra json object from the booking/create request
     
     */
    init?(json: [String:Any]) {
        guard let pivotObject = json["pivot"] as? [String:Any],
            let description = json["description"] as? String,
            let quantity = pivotObject["quantity"] as? Int,
            let identifier = json["extraID"] as? Int,
            let name = json["extraName"] as? String,
            let priceString = pivotObject["price"] as? String,
            let price = Decimal(string: priceString) else {
                print("skipping extra \(json.debugDescription)")
                return nil
        }
        
        self.identifier = identifier
        self.extraName = name
        self.price = price
        self.extraDescription = description
        self.quantitySelected = quantity
        super.init()
    }
    
}

/** Small object containing the status of the booking and a short description */
@objc(VVVBookingStatus) public class BookingStatus : NSObject {
    
    /** The name of the status eg. "Cancelled" "Booked" etc. */
    public let statusName : String
    
    /** A description of the status */
    public let statusText : String
    
    /** A convenience boolean will be true if the booking is cancelled */
    public let isCancelled : Bool
    
    /**
     
     Init with the status json object of a booking
     - Parameters:
     - json:  status json object
     
     */
    init?(json: [String:Any]) {
        guard let name = json["name"] as? String,
            let description = json["description"] as? String,
            let identifier = json["id"] as? Int else {
                print("skipping status \(json.debugDescription)")
                return nil
        }
        
        self.statusName = name
        self.statusText = description
        self.isCancelled = identifier == 3
        super.init()
    }
    
}
