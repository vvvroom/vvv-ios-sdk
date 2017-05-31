//
//  SearchResults.swift
//  VVV
//
//  Created by James Swiney on 20/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation


/**
 An object that consolodates all results from all suppliers
 */
@objc(VVVSearchResults) public class SearchResults : NSObject {
    
    /** All the responses from the search requests  */
    var responses = [SearchResponse]()
    
    /** An array of all the search results from each response consolodated into one array and sorted by prices.  */
    public var all : [SearchResult] { get {
        
        var results = [SearchResult]()
        for response in responses {
            results.append(contentsOf: response.results)
        }
        
        //Sort by price
        results.sort { (result1, result2) -> Bool in
            
            let total1 = result1.cost.total as NSDecimalNumber
            let total2 = result2.cost.total as NSDecimalNumber
            return total1.floatValue < total2.floatValue
        }
        return results
        }
        
    }
    
    /** Convenience method returning a response for a search result.  */
    func responseFor(result:SearchResult) -> SearchResponse? {
        
        for response in self.responses {
            if response.depots.supplier == result.supplier {
                return response
            }
        }
        
        return nil
    }
    
}
