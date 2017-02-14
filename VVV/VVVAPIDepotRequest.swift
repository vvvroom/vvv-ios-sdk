//
//  VVVAPIDepotRequest.swift
//  VVV
//
//  Created by James Swiney on 14/12/16.
//  Copyright © 2016 James Swiney. All rights reserved.
//

import Foundation

class VVVAPIDepotRequest : VVVAPIRequest {
    
    override func endPoint() -> VVVNetworkEndpoint {
        return .NearestDepot
    }
    
    override func method() -> VVVAPIMethod {
        return .get
    }
    
    override func params() -> [String:Any] {
        let paramsDict : [String:Any] = ["alias":"carhire-ios","pickupCoordinate":"-27.3866933,153.0395594","returnCoordinate":"-27.3866933,153.0395594",
                                               "pickUpLocationType":"2","returnLocationType":"2",
            "byPassDefaultRadius":"0","showByPassedDepots":"0"]
        
        return paramsDict
    }
    
    override func isFormData() -> Bool {
        return false
    }
    
    override func encoding() -> VVVAPIParameter {
        return .url
    }
    
    override func responseHandler() -> VVVNetworkReponseHandler {
        return {(response,error) -> Void in
            
            guard let json = response else {
                print("no data in response")
                return
            }
            print("string response \(json)")
        }
    }
    
    override func appendToUrl() -> String {
        return ""
    }
    
}
