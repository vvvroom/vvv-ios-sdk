//
//  VVVAPIEndpoint.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2016 James Swiney. All rights reserved.
//

import Foundation

enum VVVNetworkHost {
    case Vroom,Hiccup
}

fileprivate let currentHostKey = "currentAPIHost"

fileprivate let APIURL = "https://api.vroomvroomvroom.com/json/"
fileprivate let stagingAPIURL = "https://api.vroomstaging.com/json/"
fileprivate let testAPIURL = "http://test-api.vroomvroomvroom.com/json/"
fileprivate let devAPIURL = "http://dev-api.vroomvroomvroom.com/json/"

let hiccupAPIURL = "https://xapi.hiccup.com.au/api/"
let testHiccupAPIURL = "https://xapi.hiccup-staging.com/api/"

enum VVVNetworkEndpoint : String {
    
    //Vroom
    case NearestDepot = "v1.1/search/nearest-depot-pair"
    case SearchVehicles = "v1.1/search/vehicles"
    case SearchVehicle = "v1.1/search/vehicle"
    case CreateBooking = "v1.1/booking/create"
    case CancelBooking = "v1.1/booking/cancel"
    case AllBookings = "v1.1/booking/all"
    case GetBooking = "v1.1/booking"
    case SupplierTerms = "v1.2/supplier/terms"
    case BookingTerms = "v1.2/booking/terms"
    case TopLocations = "v1.1/search/toplocations"
    case Config = "v1.1"
    
    //Hiccup
    case InsuranceProduct = "product"
    case InsuranceQuote = "quote"
    case InsuranceQuotePersist = "quote/create"
    case InsurancePolicy = "policy"
    case InsurancePolicyByReference = "policy/findByBookingId"
    case InsuranceDislaimer = "disclaimer"
    
    func fullUrl() -> String {
        
        let mode = VVVConfig.sharedInstance.mode
        switch host() {
        case .Vroom:
            return "\(self.currentApiHost(mode:mode))\(self.rawValue)"
        case .Hiccup:
            return "\(self.currentHiccupHost(mode:mode))\(self.rawValue)"
        }
        
    }
    
    func currentApiHost(mode:VVVAPIMode) -> String {

        switch mode {
        case .prod:
            return APIURL
        case .staging:
            return stagingAPIURL
        case .test:
            return testAPIURL
        case .dev:
            return devAPIURL
        }
    }
    
    func currentHiccupHost(mode:VVVAPIMode) -> String {

        switch mode {
        case .prod:
            return hiccupAPIURL
        case .staging:
            return testHiccupAPIURL
        case .test:
            return testHiccupAPIURL
        case .dev:
            return testHiccupAPIURL
        }
    }
    
    func host() -> VVVNetworkHost {
        
        switch self {
        case .NearestDepot,.SearchVehicles,.SearchVehicle,.CreateBooking,.CancelBooking,.AllBookings,.GetBooking,.SupplierTerms,.TopLocations,.Config,.BookingTerms:
            return .Vroom
        case .InsuranceProduct,.InsuranceQuote,.InsuranceQuotePersist,.InsurancePolicy,.InsurancePolicyByReference,.InsuranceDislaimer:
            return .Hiccup
        }
        
    }
}
