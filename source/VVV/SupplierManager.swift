//
//  SupplierManager.swift
//  VVV
//
//  Created by James Swiney on 27/3/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** A class to manager and fetch all the supported suppliers. */
class SupplierManager : APIRequestPerformer {
    
    /** Singleton accessor for the supplier manager */
    static let shared = SupplierManager()
    
    /** all the suppliers that can be used  */
    var allSuppliers = [Supplier]()
    
    /** Init of the singleton triggers the loading of supported suppliers.  */
    init() {
        loadSuppliers(completion: nil)
    }
    
    /**
     
     Fetch a supported supplier with a supplier code
     
     - Parameters:
        - code: The supplier code eg. "HZ"
     - Return:
        - Supplier : The supplier object if found.
     
     */
    func supplierFor(code:String) -> Supplier? {
        
        for supplier in allSuppliers {
            if supplier.code == code {
                return supplier
            }
        }
        return nil
    }
    
    /**
     
     If suppliers have already been fetched this calls back immediately stating that the supplier list is ready, otherwise calls load supplier.
     
     - Parameters:
     - completion: The completion object letting you know the Supplier manager has loaded suppliers.
     
     */
    func loadSuppliersIfNeeded(completion:@escaping ()->()) {
        
        if self.allSuppliers.count > 0 {
            completion()
            return
        }
        
        loadSuppliers { 
            completion()
        }
    }
    
    /**
     
    Loads and replaces the supplier array
     
     - Parameters:
     - completion: The completion object letting you know the Supplier manager has loaded suppliers.
     
     */
    func loadSuppliers(completion:(()->())?) {
        
        let request = SupplierListRequest { (suppliers, error) in
            self.allSuppliers = suppliers
            if let block = completion {
                block()
            }
        }
        self.perform(apiRequest: request)
        
    }
}
