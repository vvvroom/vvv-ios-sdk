//
//  VVVAPIRequest.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2016 James Swiney. All rights reserved.
//

import Foundation

typealias VVVNetworkReponseHandler = (Any?,String?) -> ()

class VVVAPIRequest {
    
    var rawResponse : AnyObject?
    
    public init() {}
    
    //Must Override
    func endPoint() -> VVVNetworkEndpoint {
        fatalError("must override endpoint")
    }
    
    //Optional overrides the methods as needed.
    func method() -> VVVAPIMethod {
        return .post
    }
    
    func params() -> [String:Any] {
        return [:]
    }
    
    func isFormData() -> Bool {
        return false
    }
    
    func encoding() -> VVVAPIParameter {
        return .json
    }
    
    func responseHandler() -> VVVNetworkReponseHandler {
        return {(response,error) -> Void in }
    }
    
    func appendToUrl() -> String {
        return ""
    }

    
}
