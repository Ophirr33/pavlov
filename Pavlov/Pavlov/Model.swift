//
//  Model.swift
//  Pavlov
//
//  Created by Ceridwen Driskill on 10/22/16.
//  Copyright © 2016 Ceridwen Driskill. All rights reserved.
//

import Foundation

class Model {
    
    static let INSTANCE = Model()
    
    private var amount = 0.00
    private var increment = 1.00
    
    func sendTextForAnalysis(s: String) -> Bool {
        return arc4random_uniform(2) == 1
    }
    
    func getAmount() -> Double {
        return amount
    }
    
    func incrementAmount() {
        amount += increment
    }
    
    func setIncrement(d: Double) {
        increment = d
    }
}
