//
//  Supplier.swift
//  VVV
//
//  Created by James Swiney on 17/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** A simple object representing a Supplier.  Must have a SupplierType that exists in the enum */
@objc(VVVSupplier) public class Supplier : NSObject {
    
    /** The supplier code used to identify the supplier in API requests */
    public let code : String
    
    /** The supplier logo image url. */
    public let logoUrl : String
    
    /** The name of the Supplier eg. "Hertz" */
    public let name : String
    
    /**
     
     Init a supplier object with a supplier json object.
     
     - Parameters:
     - json: the json object
     
     */
    init?(json:[String:Any]) {
        guard let code = json["code"] as? String,
            let name = json["name"] as? String,
            let imageUrl = json["image"] as? String else { return nil }
        
        self.code = code
        self.name = name
        self.logoUrl = imageUrl
        
        super.init()
    }

}
