//
//  Model.swift
//  Pavlov
//
//  Created by Ceridwen Driskill on 10/22/16.
//  Copyright © 2016 Ceridwen Driskill. All rights reserved.
//

import Foundation
import UIKit

class Model {
    
    static let INSTANCE = Model()
    
    var amount = 0.00
    var increment = 1.00
    var familyAccount = ""
    
    func getAmount() -> Double {
        return amount
    }
    
    func isAccountSet() -> Bool {
        return familyAccount != ""
    }
    
    func setFamilyAccount(_ s: String) {
        familyAccount = s
    }
    
    func incrementAmount() {
        amount += increment
    }
    
    func setIncrement(d: Double) {
        increment = d
    }
}
