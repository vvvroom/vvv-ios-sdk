//
//  SupplierListRequest.swift
//  VVV
//
//  Created by James Swiney on 27/3/17.
//  Copyright © 2017 James Swiney. All rights reserved.
//

import UIKit

class SupplierListRequest: APIRequest {

    /** completion block called after request with the supplier array and an error message if failed */
    let completion : ([Supplier],String?)->()
    
    /**
     
     Inits the request with completion block
     
     - Parameters:
     - completion: The block called after the request completes
     
     */
    init(completion:@escaping ([Supplier],String?)->()) {
        self.completion = completion
    }
    
    override func endPoint() -> NetworkEndpoint {
        return .SupplierList
    }
    
    override func method() -> APIMethod {
        return .get
    }
    
    override func responseHandler() -> NetworkReponseHandler {
        return {(response,error) -> Void in
            
            if let suppliers = self.map(json: response) {
                self.completion(suppliers,nil)
                return
            }
            
            if let error = self.error(json: response) {
                self.completion([],error)
                return
            }
            self.completion([],"An unknown error occured cancelling the booking")
        }
    }
    
    func map(json:Any?) -> [Supplier]? {
        guard let jsonDict = json as? [String:Any],
            let array = jsonDict["data"] as? [[String:Any]] else { return nil }
        
        var suppliers = [Supplier]()
        
        for object in array {
            guard let supplier = Supplier(json: object) else { continue }
            suppliers.append(supplier)
        }
        
        return suppliers
    }
    
    func error(json:Any?) -> String? {
        guard let jsonDict = json as? [String:Any],
            let message = jsonDict["message"] as? String else { return nil }
        return message
    }
    
}
