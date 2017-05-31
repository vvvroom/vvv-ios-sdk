//
//  VVVAPIEndpoint.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/**
 All available network endpoints used by API Requests are specified with this enum, its value is the

 */
enum NetworkEndpoint : String {
    
    case NearestDepot = "v1.2/search/nearest-depot-pair"
    case SearchVehicles = "v1.2/search/vehicles"
    case SearchVehicle = "v1.2/search/vehicle"
    case CreateBooking = "v1.2/booking/create"
    case CancelBooking = "v1.2/booking/cancel"
    case AllBookings = "v1.2/booking/all"
    case GetBooking = "v1.2/booking"
    case SupplierTerms = "v1.2/supplier/terms"
    case SupplierList = "v1.2/supplier/list"
    case BookingTerms = "v1.2/booking/terms"
    case TopLocations = "v1.2/search/toplocations"
    case Details = "v1.2"

    /**
     
     Appends the network endpoint to the domeain to create the full endpoint url
     
     - Return:
        - String: Returns the full url with the endpoint eg. "https://domain.com/json/v1.2/booking/create"
     
     */
    func fullUrl() -> String {
        guard let domain = Config.shared.domain else {
            print("*** VVV domain not set, please call APIClient.setupWith to set domain ***")
            return ""
        }
        return "\(domain)/json/\(self.rawValue)"
    }
    
}
