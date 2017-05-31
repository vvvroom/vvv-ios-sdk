//
//  Utils.swift
//  VVV
//
//  Created by James Swiney on 14/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation
import CoreLocation

/**
 A collection of Utilities and convenience extensions.
 */
class Utils {
    
    /**
     
     Converts a Data object into a JSON object represented as Any
     
     - Parameters:
        - data:  The data object wishing to be converted
     -Return:
        - Any: The json object or json array if conversion was successful.

     */
    static func convertDataToJson(data:Data?) -> Any? {
        
        guard let data = data else { return nil }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject
        } catch {
            print("failed to parse json")
            if let string = String(data: data, encoding: .utf8) {
                print("error dump \(string)")
            }
            return nil
        }
    }
    
    /**
     
     Validates that a flight number has at 2 letters characters followed by at least 3 number characters and doesn't exceed 7 characters.
     Example valid flight number is "QA123"
     
     - Parameters:
        - flightNumber:  The flight number to be checked
     -Return:
        - Bool: True if flightnumber is valid false if not.
     
     */
    static func validate(flightNumber:String) -> Bool {
        
        //First we check overall length of flight number
        if flightNumber.characters.count < 5 || flightNumber.characters.count > 7 {
            return false
        }
        
        //Now we get the first 2 letters and the letters characterset
        let lettersIndex = flightNumber.index(flightNumber.startIndex, offsetBy: 2)
        let firstTwo = flightNumber.substring(to: lettersIndex)
        
        //Now we check that the first 2 characters are letters.
        if !firstTwo.containsOnlyLetters() {
            return false
        }
        
        //Now we check that the 3 characters after the first 2 to make sure they are numbers
        let start = flightNumber.index(flightNumber.startIndex, offsetBy: 2)
        let end = flightNumber.index(start, offsetBy: 3)
        let range = Range(uncheckedBounds: (lower: start, upper: end))
        let numbersString = flightNumber.substring(with: range)
        
        //Now we check that the these characters are numbers.
        if !numbersString.containsOnlyNumbers() {
            return false
        }
        
        return true
    }
}

extension CLLocation {
    
    /**
     
     Creates a comma seperated string on latitude and longitude eg. "-27.12457,154.2337". This is the format the API requests expect locations.
     
     -Return:
     - String: The comma seperated string of the locations
     
     */
    func commaSeperatedText() -> String {
        return "\(self.coordinate.latitude),\(self.coordinate.longitude)"
    }
    
}

extension NSNumber {
    
    /** Returns if an nsnumber value is a boolean ie 1 or 0 used in */
    var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

extension Dictionary where Key : ExpressibleByStringLiteral {
    
    /**
     
     Will return the value or the default value for a type for a key.  For Example return the bool value of a key or default of false.
     - Parameters:
        - key:  The key to extract the value out of the dictionary
        - type: The type you want to check the key for
     -Return:
        - T: Will return the value of the object for the key if it exists otherwise will return the default value for the type.
     
     */
    func typeValueFor<T:DefaultValueType>(key:String,type:T.Type) -> T {
        guard let convertedkey = key as? Key,
            let value = self[convertedkey] as? T else { return type.defaultValue() }
        return value
    }
}

/**
Protocol for types that can be used in the above extension.  This protocol simply enforces a default value for a type.
 */
protocol DefaultValueType {
    static func defaultValue<T:DefaultValueType>() -> T
}

extension Bool : DefaultValueType {
    
    /** Default value for a Bool is false */
    static func defaultValue<T:DefaultValueType>() -> T {
        return false as! T
    }
}

extension String : DefaultValueType {
    
    /** Default value for a String is "" */
    static func defaultValue<T:DefaultValueType>() -> T {
        return "" as! T
    }
    
    /**
     
     Checking that a string contains only numbers
     
     -Return:
     - Bool: Returns true is the string only contains numbers
     
     */
    func containsOnlyNumbers() -> Bool {
        guard let _ = self.rangeOfCharacter(from: NSCharacterSet.decimalDigits) else { return false }
        
        let nonCharactersSet = NSMutableCharacterSet.letter()
        nonCharactersSet.formUnion(with: .illegalCharacters)
        nonCharactersSet.formUnion(with: .punctuationCharacters)
        nonCharactersSet.formUnion(with: .whitespacesAndNewlines)
        
        if let _ = self.rangeOfCharacter(from: nonCharactersSet as CharacterSet) {
            return false
        }
        return true
    }
    
    /**
     
     Checking that a string contains only numbers
     
     -Return:
     - Bool: Returns true is the string only contains numbers
     
     */
    func containsOnlyLetters() -> Bool {
        guard let _ = self.rangeOfCharacter(from: NSCharacterSet.letters) else { return false }
        
        let nonCharactersSet = NSMutableCharacterSet.decimalDigit()
        nonCharactersSet.formUnion(with: .illegalCharacters)
        nonCharactersSet.formUnion(with: .punctuationCharacters)
        nonCharactersSet.formUnion(with: .whitespacesAndNewlines)
        
        if let _ = self.rangeOfCharacter(from: nonCharactersSet as CharacterSet) {
            return false
        }
        return true
    }
    
    /**
     
     Removes whitespaces then checks if string is empty
     
     -Return:
     - Bool: Returns true if string is empty after removing whitespace
     
     */
    func isBlankSpace() -> Bool {
        let newString = self.replacingOccurrences(of: " ", with: "")
        return newString.isEmpty
    }
}

extension Int : DefaultValueType {
    
    /** Default value for a Int is 0 */
    static func defaultValue<T:DefaultValueType>() -> T {
        return 0 as! T
    }
}

extension Decimal {
    
    /**
     
     Returns a formatted number string for a Decimal to 2 decimal places
     
     -Return:
        - String: Returns a formatted number string
     
     */
    func currencyNumberOnlyString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        guard let numberString = numberFormatter.string(from: self as NSNumber) else {
            return ""
        }
        return numberString
    }
    
}

extension Locale {
    
    /**
     
     Returns Country Objects for Country Codes, it can take some time to perform. It should happen on a background thread.
     
     - Parameters:
        - supportedCodes:  An array of country codes to create the country objects from.
        - phonePrefixes: Phone prefixes to be mapped to the country objects.
     -Return:
        - [Country]: Returns all country objects created.
     
     */
    static func countryList(supportedCodes:[String],phonePrefixes:[String:String]) -> [Country] {
        
        let currentLocale = Locale(identifier: "en_US")
        let codes = Locale.isoRegionCodes
        
        var countries = [Country]()
        
        for code in codes {
            //Skip any not in our list of supported residencies
            if !supportedCodes.contains(code) {
                continue
            }
            guard let name = (currentLocale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: code) else { continue }
            let country = Country(name: name, code: code)
            country.phonePrefix = phonePrefixes[code.uppercased()]
            countries.append(country)
        }
        
        countries.sort { (country1, country2) -> Bool in
            return country1.name < country2.name
        }
        
        return countries
    }
}

extension Location {
    
    /**
     
     Returns the search type for a location.
     
     -Return:
        - Int: Returns the type of search to perform for the location 1 is only airports 2 is everywhere but airports.
     
     */
    func searchtype() -> Int {
        var type = 2
        if self.isAirport {
            type = 1
        }
        return type
    }
}
