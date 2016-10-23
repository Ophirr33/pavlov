//
//  StartViewController.swift
//  Pavlov
//
//  Created by Ceridwen Driskill on 10/22/16.
//  Copyright © 2016 Ceridwen Driskill. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var startTrainingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startTrainingButton.isEnabled = Model.INSTANCE.isAccountSet()
        if startTrainingButton.isEnabled {
            startTrainingButton.alpha = 1
        } else {
            startTrainingButton.alpha = 0.5
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
