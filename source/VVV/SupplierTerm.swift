//
//  SupplierTerm.swift
//  VVV
//
//  Created by James Swiney on 14/3/17.
//  Copyright © 2017 James Swiney. All rights reserved.
//

import UIKit

@objc(VVVSupplierTerm) public class SupplierTerm: NSObject {

    /** A url link to the suppliers terms and conditions website if available */
    public let supplierURL : String?
    
    /** The Title of the term eg. "Additional Drivers" */
    public let title : String
    
     /** The text detailing the information regarding the title, may be long. */
    public let termText : String
    
     /** The order in which to display in the array of terms. */
    public let order : Int
    
    
    /**
     
     Standard mapping init method for the Supplier term
     
     - Parameters:
     - json: The json object in the array from the Terms and Conditions request.
     
     */
    init?(jsonData:[String:Any]) {
        
        guard let title = jsonData["title"] as? String,
            let termText = jsonData["description"] as? String else {
                return nil
        }
        
        self.supplierURL = jsonData["supplierURL"] as? String
        self.order = jsonData.typeValueFor(key: "ordinal", type: Int.self)
        self.title = title
        self.termText = termText
        
    }

    
}
