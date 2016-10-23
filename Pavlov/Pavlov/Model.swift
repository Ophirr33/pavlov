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
    
    private var amount = 0.00
    private var increment = 1.00
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
    
    func testRest(field: UITextView) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            var text = ""
            
            guard error == nil else {
                text = (error as! String!)
                return
            }
            guard let data = data else {
                text = ("Data is empty")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                
                for (key, val) in json {
                    text += key + " : " + String(describing: val) + "\n"
                }
            } catch {
                text = "FAILURE"
            }
            
            OperationQueue.main.addOperation {
                field.text = text
            }
        }
        
        task.resume()
    }
}
