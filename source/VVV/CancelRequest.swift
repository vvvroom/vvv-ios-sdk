//
//  CancelRequest.swift
//  VVV
//
//  Created by James Swiney on 23/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import UIKit

/** Cancels a booking with the specified supplier and marks it as cancelled in Vroom if successful */
class CancelRequest: APIRequest {

    /** The booking to cancel */
    let booking : Booking
    
    /** completion block called after request with a success boolean and an error message if success is false */
    let completion : (Bool,String?)->()
    
    /**
     
     Inits the request with a booking object and completion block
     
     - Parameters:
        - booking: The pending booking object to cancel
        - completion: The block called after the request completes
     
     */
    init(booking:Booking,completion:@escaping (Bool,String?)->()) {
        self.booking = booking
        self.completion = completion
    }
    
    
    override func endPoint() -> NetworkEndpoint {
        return .CancelBooking
    }
    
    override func method() -> APIMethod {
        return .post
    }
    
    override func encoding() -> APIParameter {
        return .url
    }
    
    override func params() -> [String : Any] {
        var paramsDict = [String:Any]()
        
        paramsDict["bookingID"] = booking.identifier
        paramsDict["supplierConfirmation"] = booking.supplierConfirmation
        
        return paramsDict
    }
    
    override func responseHandler() -> NetworkReponseHandler {
        return {(response,error) -> Void in
            
            if self.map(json: response) {
                self.completion(true,nil)
                return
            }
            
            if let error = self.error(json: response) {
                self.completion(false,error)
                return
            }
            self.completion(false,"An unknown error occured cancelling the booking")
        }
    }
    
    func map(json:Any?) -> Bool {
        guard let jsonDict = json as? [String:Any] else { return false }
        return jsonDict.typeValueFor(key: "success", type: Bool.self)
    }
    
    func error(json:Any?) -> String? {
        guard let jsonDict = json as? [String:Any],
            let message = jsonDict["message"] as? String else { return nil }
        return message
    }
}
