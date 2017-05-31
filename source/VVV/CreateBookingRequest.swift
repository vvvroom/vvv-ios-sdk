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
    
    override func responseHandler() -> NetworkReponseHandler {
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
        
        paramsDict["requestURL"] = "iphone"
        
        //Standard booking info
        paramsDict["alias"] = Config.shared.alias ?? ""

        paramsDict["supplierCode"] = pending.depots.supplier.code
        paramsDict["pickUpDate"] = pending.dateRange.start.apiFormattedDateString()
        paramsDict["pickUpTime"] = pending.dateRange.start.apiFormattedTimeString()
        paramsDict["returnDate"] = pending.dateRange.end.apiFormattedDateString()
        paramsDict["returnTime"] = pending.dateRange.end.apiFormattedTimeString()
        paramsDict["countryOfResidence"] = pending.residency.code
        paramsDict["driverAge"] = pending.age.rawValue
        
        paramsDict["pickUpDepotCode"] = pending.depots.pickupDepot.code
        paramsDict["returnDepotCode"] = pending.depots.returnDepot.code
        
        paramsDict["carCategoryCode"] = pending.code
        
        paramsDict["agree"] = true
        paramsDict["newsletter"] = false
        
        paramsDict["sendSms"] = true
        paramsDict["sendEmail"] = true
        
        paramsDict["sippID"] = pending.sippID
        
        //Driver details
        paramsDict["title"] = pending.driver.title
        paramsDict["firstName"] = pending.driver.firstName
        paramsDict["lastName"] = pending.driver.lastName
        paramsDict["phoneNumber"] = self.createPhoneNumber()
        paramsDict["email"] = pending.driver.email
        
        //Cost
        paramsDict["totalCost"] = pending.cost.total.currencyNumberOnlyString()
        paramsDict["currencyCode"] = pending.cost.currency
        
        paramsDict["rateID"] = pending.rateId
        
        ///Extra Vehicle details
        paramsDict["vehicleImage"] = pending.imageUrl
        paramsDict["mileage"] = pending.mileage
        
        //TODO add loyaltyNumber
        if let flightNumber = pending.flightNumber {
            paramsDict["flightNumber"] = flightNumber
        }
        
        //Sub Objects
        paramsDict["vehicleDetails"] = createVehicleDetails()
        if let extraParams = createExtraParams() {
            paramsDict["equipmentList"] = extraParams
        } else {
            paramsDict["equipmentList"] = "null"
        }
        
        if let fees = createFeesParams() {
            paramsDict["fees"] = fees
        } else {
            paramsDict["fees"] = "null"
        }
        
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
    
    /**
     
     Creates the vehicle details param object.
     
     - Return:
        - [String:Any]: Params dictionary to be added to the params main dictionary under "vehicleDetails" key.
     
     */
    func createVehicleDetails() -> [String:Any] {
        
        var vehicleDetails = [String:Any]()
        vehicleDetails["vehicleClassID"] = pending.classID
        vehicleDetails["vehicleCategoryID"] = pending.categoryID
        vehicleDetails["transmissionType"] = pending.features.transmission.code
        vehicleDetails["airConditioned"] = pending.features.aircon
        
        return vehicleDetails
    }
    
    /**
     
     Creates the extras param object, to request any params with an amount with the booking
     
     - Return:
        - [String:Any]: Params dictionary to be added to the params main dictionary under "extras" key. Can be nil.
     
     */
    func createExtraParams() -> [String:Any]? {
        
        var extras = [String:Any]()
        
        for extra in pending.extras {
            
            var extraParams = [String:Any]()
            extraParams["extrasID"] = extra.identifier
            extraParams["equipmentCode"] = extra.code
            if let max = extra.maxPrice {
                extraParams["maxPrice"] = max.currencyNumberOnlyString()
            }
            extraParams["name"] = extra.extraName
            extraParams["price"] = extra.price.currencyNumberOnlyString()
            
            //I don't understand this format yet
            var maxQuantityObject = [String:Any]()
            for i in 0..<extra.maxQuantity {
                maxQuantityObject["\(i)"] = "null"
            }
            
            extraParams["maxQuantity"] = maxQuantityObject
            extraParams["quantity"] = extra.quatityRequested
            
            extras["\(extra.code)"] = extraParams
        }
        
        return extras
    }
    
    /**
     
     Creates the fees param object.  This is actually double encoded so a encoded string is provided
     
     - Return:
        - String: Params dictionary to be added to the params main dictionary under "fees" key. Can be nil.
     
     */
    func createFeesParams() -> String? {
        
        var fees = [Any]()
        
        for fee in pending.fees {
            
            var feeDict = [String:Any]()
            feeDict["amount"] = fee.amount.currencyNumberOnlyString()
            feeDict["description"] = fee.details
            feeDict["xrsBaseAmount"] = fee.amount.currencyNumberOnlyString()
            
            fees.append(feeDict)
        }
        
        if fees.count == 0 {
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: fees, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
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
