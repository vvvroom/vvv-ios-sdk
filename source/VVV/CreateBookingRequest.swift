//
//  CreateBookingRequest.swift
//  VVV
//
//  Created by James Swiney on 22/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import UIKit

/** Creates a booking with Vroom and with the specified supplier */
class CreateBookingRequest: APIRequest {

    /** The pending booking object to create the booking from */
    let pending : PendingBooking
    
    /** completion block called after request with a booking or an error message */
    let completion : (Booking?,String?)->()
    
    /**
     
     Inits the request with a pendingBooking object and completion block
     
     - Parameters:
        - pending: The pending booking object.
        - completion: The block called after the request completes
     
     */
    init(pending : PendingBooking,completion:@escaping (Booking?,String?)->()) {
        self.pending = pending
        self.completion = completion
    }
    
    override func endPoint() -> NetworkEndpoint {
        return .CreateBooking
    }
    
    override func responseHandler() -> NetworkResponseHandler {
        return {(response,error) -> Void in
            
            guard let json = response else {
                self.completion(nil,"Unknown error occured")
                return
            }

            if let result = self.map(json: json) {
                self.completion(result, nil)
                return
            }

            if let error = self.error(json: json) {
                self.completion(nil,error)
                return
            }

            self.completion(nil,"Unknown error occured")
        }
    }
    
    override func params() -> [String : Any] {
        
        var paramsDict = [String:Any]()
        
        paramsDict["supplierCode"] = pending.depots.supplier.code
        paramsDict["currencyCode"] = pending.cost.currency
        paramsDict["countryCode"] = pending.depots.pickupDepot.location.country
        
        //Driver details
        var customer = [String:Any]()
        customer["title"] = pending.driver.title
        customer["firstName"] = pending.driver.firstName
        customer["lastName"] = pending.driver.lastName
        customer["phoneNumber"] = self.createPhoneNumber()
        customer["email"] = pending.driver.email
        customer["driverAge"] = "\(pending.age.rawValue)"
        customer["countryOfResidence"] = pending.residency.code
        paramsDict["customerDetails"] = customer
     
        var rentalDetails = [String:Any]()
        var pickupDetails = [String:Any]()
        pickupDetails["date"] = pending.dateRange.start.apiFormattedDateString()
        pickupDetails["time"] = pending.dateRange.start.apiFormattedTimeString()
        pickupDetails["depotCode"] = pending.depots.pickupDepot.code
        
        rentalDetails["pickUp"] = pickupDetails
        
        var returnDetails = [String:Any]()
        returnDetails["date"] = pending.dateRange.end.apiFormattedDateString()
        returnDetails["time"] = pending.dateRange.end.apiFormattedTimeString()
        returnDetails["depotCode"] = pending.depots.pickupDepot.code
        
        rentalDetails["return"] = returnDetails
        
        if let flight = pending.flightNumber {
            rentalDetails["flightNumber"] = flight
        }
        paramsDict["rentalDetails"] = rentalDetails
        
        var vehicleDetails = [String:Any]()
        vehicleDetails["categoryCode"] = pending.code
        vehicleDetails["rateId"] = pending.rateId
        paramsDict["vehicleDetails"] = vehicleDetails
        
        var notify = [String:Any]()
        notify["sms"] = true
        notify["email"] = true
        paramsDict["notify"] = notify
        
        var extraParams : [[String:Int]] = []
        
        for extra in pending.extras {
            if extra.quatityRequested == 0 {
                continue
            }
            extraParams.append(["id":extra.identifier,"quantity":extra.quatityRequested])
        }
        paramsDict["extras"] = extraParams
        
        //TODO support token
//        if let token = self.paymentToken {
//            paramsDict["payment"] = ["token":token]
//        }
        
        paramsDict["isTestBooking"] = true
        return paramsDict
    }

    /**
     
     Combines the phone number and the country extension. To create "+61414444444".  It will also auto correct Australian numbers by removing the prefixing "0" from the number.
     
     - Return:
        - String: The full phone number string
     
     */
    func createPhoneNumber() -> String? {
        
        guard let prefix = self.pending.driver.phoneCountryPrefix,
            var phone = self.pending.driver.phoneNumber else { return nil }
        
        if phone.contains(prefix) {
            return phone
        }
        if prefix == "+61" && phone[phone.startIndex] == "0" {
            phone = String(phone.characters.dropFirst())
        }
        
        return "\(prefix)\(phone)"
    }
    
    func map(json:Any) -> Booking? {
        guard let jsonObject = json as? [String:Any],
            let dataObject = jsonObject["data"] as? [String:Any],
            let booking = Booking(json: dataObject) else { return nil }
        
        return booking
    }
    
    func error(json:Any) -> String? {
        guard let jsonDict = json as? [String:Any],
            let message = jsonDict["message"] as? String else { return nil }
        return message
    }
}
