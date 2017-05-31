//
//  FetchBookingRequest.swift
//  VVV
//
//  Created by James Swiney on 10/3/17.
//  Copyright © 2017 James Swiney. All rights reserved.
//

import UIKit

/** Finds a booking matching a lastname and supplier confirmation */
class FetchBookingRequest: APIRequest {

    /** The last name of the driver in the booking */
    let lastName : String
    
    /** The Confirmation number of the booking. */
    let confirmation : String
    
    /** completion block called after request with a a booking object or an error */
    let completion : (Booking?,String?)->()
    
    /**
     
     Inits the request with a lastname and confirmation number
     
     - Parameters:
     - lastName: The last name of the driver in the booking
     - confirmation: The Confirmation number of the booking.
     - completion: Called with a booking if found otherwise an error
     
     */
    init(lastName:String,confirmation:String,completion:@escaping (Booking?,String?)->()) {
        self.lastName = lastName
        self.confirmation = confirmation
        self.completion = completion
    }
    
    override func endPoint() -> NetworkEndpoint {
        return .GetBooking
    }
    
    override func params() -> [String : Any] {
        return ["supplierConfirmation":self.confirmation,"lastName":self.lastName]
    }
    
    override func responseHandler() -> NetworkReponseHandler {
        return { (response,error) -> Void in
            
            if let booking = self.map(json: response) {
                self.completion(booking,nil)
                return
            }
            
            if let error = self.error(json: response) {
                self.completion(nil,error)
                return
            }
            
            self.completion(nil,"Unknown error occured fetching the booking")
        }
    }
    
    override func method() -> APIMethod {
        return .get
    }
    
    override func encoding() -> APIParameter {
        return .url
    }
    
    func map(json:Any?) -> Booking? {
        guard let jsonDict = json as? [String:Any],
         let dataObject = jsonDict["data"] as? [String:Any] else { return nil }
        return Booking(json: dataObject)
    }
    
    func error(json:Any?) -> String? {
        guard let jsonDict = json as? [String:Any],
            let message = jsonDict["message"] as? [String:Any] else { return nil }
        
        let supplierErrors = message["supplierConfirmation"] as? [String]
        let lastNameErrors = message["lastName"] as? [String]
        
        var error = ""
        if let supplier = supplierErrors {
            if supplier.count > 0 {
                error = "No matching booking for Booking confirmation number"
                
            }
        }
        
        if let name = lastNameErrors {
            if name.count > 0 {
                error = "No matching booking for Lastname"
                
            }
        }
        if error.isEmpty {
            error = "No Booking found, please try again."
        }

        
        return error
    }
}
