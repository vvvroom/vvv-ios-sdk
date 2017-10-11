//
//  TermsAndConditionsRequest.swift
//  VVV
//
//  Created by James Swiney on 14/3/17.
//  Copyright © 2017 James Swiney. All rights reserved.
//

import UIKit

/** Fetches the terms and conditions attached to a booking or for the details in a pending booking. */
class TermsAndConditionsRequest: APIRequest {

    /** The booking to fetch the terms and conditions for. */
    var booking : Booking?
    
    /** The pending booking to fetch the terms and conditions for */
    var pending : PendingBooking?
    
    /** Block called on completion with an array of supplier terms and an error if failed. */
    var completion : (([SupplierTerm]?,String?)->())
    
    /**
     
     Inits the request with a booking and completion block
     
     - Parameters:
     - booking: The booking to fetch the terms and conditions for.
     - completion: The block called after the request completes
     
     */
    init(booking:Booking,completion:@escaping ([SupplierTerm]?,String?)->()) {
        self.booking = booking
        self.completion = completion
    }
    
    /**
     
     Inits the request with a pendingbooking and completion block
     
     - Parameters:
     - pendingbooking: The pending booking to fetch the terms and conditions for
     - completion: The block called after the request completes
     
     */
    init(pendingBooking:PendingBooking,completion:@escaping ([SupplierTerm]?,String?)->()) {
        self.pending = pendingBooking
        self.completion = completion
    }
    
    //MARK: - Network Request Overrides.
    override func endPoint() -> NetworkEndpoint {
        
        if let _ = self.booking {
            return NetworkEndpoint.BookingTerms
        }
        return NetworkEndpoint.SupplierTerms
    }
    
    override func params() -> [String : Any] {
        
        var paramsDict = [String:Any]()
        
        if let booking = self.booking {
            paramsDict["bookingID"] = booking.identifier
            return paramsDict
        }
        
        guard let pending = self.pending else { return [:] }
        
        paramsDict["supplier"] = pending.supplier.code
        
        paramsDict["pickUpDate"] = pending.dateRange.start.apiFormattedDateString()
        paramsDict["pickUpTime"] = pending.dateRange.start.apiFormattedTimeString()
        paramsDict["returnDate"] = pending.dateRange.end.apiFormattedDateString()
        paramsDict["returnTime"] = pending.dateRange.end.apiFormattedTimeString()
        paramsDict["countryOfResidence"] = pending.residency.code
        paramsDict["driverAge"] = pending.age.rawValue
        paramsDict["pickUpLocationCode"] = pending.depots.pickupDepot.code
        paramsDict["returnLocationCode"] = pending.depots.returnDepot.code
        paramsDict["carCategoryCode"] = pending.code
        paramsDict["rateID"] = pending.rateId
        
        return paramsDict
    }
    
    override func responseHandler() -> NetworkResponseHandler {
        return { (response,error) -> Void in
 
            guard let json = response else {
                self.completion(nil,"Unknown error occured")
                return
            }
            
            if let result = self.map(jsonData: json) {
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
    
    override func method() -> APIMethod {
        return .get
    }
    
}

extension TermsAndConditionsRequest {
    
    func map(jsonData:Any) -> [SupplierTerm]? {
        
        guard let jsonDict = jsonData as? [String:Any],
            let data = jsonDict["data"] as? [String:Any],
            let array = data["terms"] as? [[String:Any]] else { return nil }

        var termArray = [SupplierTerm]()
        
        for object in array {
            guard let term = SupplierTerm(jsonData: object) else { continue }
            termArray.append(term)
        }
        
        termArray.sort { (term1, term2) -> Bool in
            return term1.order < term2.order
        }
        
        return termArray
    }
    
    func error(json:Any) -> String? {
        guard let jsonDict = json as? [String:Any],
            let message = jsonDict["message"] as? String else { return nil }
        return message
    }
}

