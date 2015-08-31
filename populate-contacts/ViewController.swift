//
//  ViewController.swift
//  populate-contacts
//
//  Created by Kinkoi Lo  on 8/31/15.
//  Copyright (c) 2015 Kinkoi Lo . All rights reserved.
//

import UIKit
import SwiftCSV

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func populateContacts(sender: UIButton) {
        csvImportHelper()
    }
    
    func csvImportHelper() {
        let path = NSBundle.mainBundle().pathForResource("contacts", ofType: "csv")
        var error:NSErrorPointer = nil
        if let url = NSURL.fileURLWithPath(path!) {
            
            if let csv = CSV(contentsOfURL: url, error: error) {
                let rows = csv.rows
                println(rows)
            }
        }
    }
    


}

