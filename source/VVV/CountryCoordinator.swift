//
//  CountryCoordinator.swift
//  VVV
//
//  Created by James Swiney on 15/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** A protocol to extend a class which can fetch all the required country objects */
protocol CountryCoordinator {
    
}

extension CountryCoordinator {
    
    /**
     
     Loads all countries. This is performed on the background thread and can vary on load time depending on the device.
     
     - Parameters:
        - completion: Completion block called once completed
            - [[Country]]: 2 dimensional array of Country objects with 2 objects the first is the popular countrys and the second is all countries
     
     */
    func loadPopularAndAll(completion:@escaping ([[Country]])->()) {
        
        let supportedCodes = self.supportedResidencies()
        let phonePrefixes = self.phonePrefixes()
        
        DispatchQueue.global(qos: .default).async {
            
            let popularNames = ["Australia","New Zealand","United Kingdom","United States","Singapore"]
            
            let all = Locale.countryList(supportedCodes: supportedCodes, phonePrefixes: phonePrefixes)
            
            let popular = all.filter { (country) -> Bool in
                popularNames.contains(country.name)
            }
            
            DispatchQueue.main.async {
                completion([popular,all])
            }
        }
    }
}

extension CountryCoordinator {
    
    /**
     
     Taken from the Country List File - these are the supported Driver residencies of Vroom
     
     - Return:
     - [String]: An array of ISO country codes.
     
     */
    func supportedResidencies() -> [String] {
        
        let bundle = Bundle(for: Supplier.self)
        
        guard let filePath = bundle.path(forResource: "countrylist", ofType: "csv"),
            let fileData = FileManager.default.contents(atPath: filePath),
            let dataString = String(data: fileData, encoding: String.Encoding.utf8) else { return [] }
        
        let codes = dataString.components(separatedBy: "\r\n")
        print("country code count \(codes.count)")
        return codes
    }
    

    /**
     
     Load the phone-codes.json file
     
     - Return:
     - [String:String]: A Dictionary of ISO code key to phone country prefix as value eg. ["AU":"+61"]
     
     */
    func phonePrefixes() -> [String:String] {
        
        let bundle = Bundle(for: Supplier.self)
        
        guard let filePath = bundle.path(forResource: "phone-codes", ofType: "json"),
            let fileData = FileManager.default.contents(atPath: filePath),
            let objectArray = Utils.convertDataToJson(data: fileData) as? [[String:Any]] else { return [:] }
        
        var prefixes = [String:String]()
        
        for object in objectArray {
            guard let countryCode = object["code"] as? String,
                let prefix = object["dial_code"] as? String else { continue }
            prefixes[countryCode] = prefix
        }
        return prefixes
    }
    
    /**
     
     Return only countries with phone prefixes
     - Parameters:
        - countries: Countrys to be filtered
     - Return:
        - [Country]: Only countries containing phone prefixes from the pass in array.
     
     */
    func countriesWithPhonePrefixFrom(countries:[Country]) -> [Country] {
        
        let newCountries = countries.filter { (country) -> Bool in
            return country.phonePrefix != nil
        }
        return newCountries
    }
}
