//
//  AutoCompleteLocalSearchDelegate.swift
//  VVV
//
//  Created by James Swiney on 14/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

/**
 An object to become the MKLocalSearchCompleterDelegate and return the reponses in a block format
 */
@available(iOS 9.3, *)
class AutoCompleteLocalSearchDelegate : NSObject,MKLocalSearchCompleterDelegate {
    
     /** Block to be call on MKlocal search delegate callbacks */
    var delegateCompletion:(([MKLocalSearchCompletion]) -> ())?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        guard let completion = self.delegateCompletion else { return }
        
        if completer.results.count < 0 {
            completion([])
            return
        }
        
        completion(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        guard let completion = self.delegateCompletion else { return }
        completion([])
    }
}
