//
//  VVVConfig.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2016 James Swiney. All rights reserved.
//

import Foundation

enum VVVAPIMode : String {
    case prod = "--PRODUCTION--"
    case staging = "--STAGING--"
    case test = "--TEST--"
    case dev = "--DEVELOPMENT--"
    
    static var allStringValues : [String] { get {
        return [VVVAPIMode.prod.rawValue,VVVAPIMode.staging.rawValue,VVVAPIMode.test.rawValue,VVVAPIMode.dev.rawValue]
        }
    }
}

class VVVConfig {
    
    static let sharedInstance = VVVConfig()
    
    var authToken : String?
    var mode = VVVAPIMode.test
    
}
