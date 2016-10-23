//
//  SettingsViewController.swift
//  Pavlov
//
//  Created by Ceridwen Driskill on 10/22/16.
//  Copyright © 2016 Ceridwen Driskill. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var jsonText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testRest()
        // Do any additional setup after loading the view.
    }
    
    func testRest() {
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
                self.jsonText.text = text
            }
        }
        
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
