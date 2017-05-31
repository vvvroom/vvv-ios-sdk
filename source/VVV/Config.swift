//
//  VVVConfig.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation


/** A singleton object to hold the core configuration details for the SDK. */
public class Config : APIRequestPerformer {
    
    /** The singleton accessor */
    static let shared = Config()
    
    /** The API key will be here after APIClient.setupWith(key:) */
    var authToken : String?
    
    /** Will be fetched after the authToken is set via setup */
    var alias : String?
    
    /** The current API environment, will affect all requests */
    var domain : String?
    
    /** Fetch the alias attrib from the site details. */
    func fetchAlias(completion:@escaping (Bool)->()) {
        let request = AliasRequest { (alias, error) in
            self.alias = alias
            completion(alias != nil)
        }
        self.perform(apiRequest: request)
    }
}
