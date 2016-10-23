//
//  SettingsViewController.swift
//  Pavlov
//
//  Created by Ceridwen Driskill on 10/22/16.
//  Copyright © 2016 Ceridwen Driskill. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var familyAccount: UITextField!
    @IBOutlet weak var individualAccounts: UITextField!
    @IBOutlet weak var signIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frameRect = individualAccounts.frame;
        frameRect.size.height = 358; // <-- Specify the height you want here.
        individualAccounts.frame = frameRect;
        
        signIn.addTarget(self, action: #selector(signingIn), for: .touchUpInside)
    }
    
    func signingIn() {
        familyAccount.endEditing(true)
        
        if familyAccount.text == nil || familyAccount.text == "" {
            let alertController = UIAlertController(title: "Pavlov", message:
                "Account number must be provided to fully utilize this app.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        Model.INSTANCE.setFamilyAccount(familyAccount.text!)
        return
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["account":familyAccount.text], options: .prettyPrinted)
        } catch {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            OperationQueue.main.addOperation {
                self.individualAccounts.text = ""
            }
            
            guard error == nil else {
                print(error)
                return
            }
            guard let data = data else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                
                var text = ""
                let list = json["accounts"] as! [String]
                for account in list {
                    text += (account + "\n")
                }
                OperationQueue.main.addOperation {
                    self.individualAccounts.text = text
                }
                Model.INSTANCE.setFamilyAccount(self.familyAccount.text!)
            } catch { }
        }
        task.resume()
    }
}
