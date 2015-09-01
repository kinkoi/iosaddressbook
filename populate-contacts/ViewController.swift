//
//  ViewController.swift
//  populate-contacts
//
//  Created by Kinkoi Lo  on 8/31/15.
//  Copyright (c) 2015 Kinkoi Lo . All rights reserved.
//

import UIKit
import SwiftCSV
import AddressBook

class ViewController: UIViewController {

    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

    override func viewDidLoad() {
        super.viewDidLoad()
        grantAddress()
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
                for row in rows {
                    let contact = Contact()
                    contact.email = row["email"]!
                    contact.firstName = row["first name"]!
                    contact.lastName = row["last name"]!
                    contact.photo = row["image"]!
                    addContact2AddressBook(contact)
                }
                if ABAddressBookHasUnsavedChanges(addressBookRef) {
                    var err: Unmanaged<CFErrorRef>? = nil
                    // Use "&err" instead of "err", otherwise it will crash.
                    let result = ABAddressBookSave(addressBookRef, &err)
                    if result {
                        println("Data saved to address book")
                    } else {
                        println("Failed to update address book")
                    }
                    
                }
            }
        }
    }
    
    func grantAddress() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted:Bool, error: CFError!) in dispatch_async(dispatch_get_main_queue()) {
                if granted {
                    println("Granted access to address book")
                } else {
                    println("Address book access declined")
                }
            }
        }
    }
    
    func addContact2AddressBook(contact: Contact) {
        println(contact)
        let addressRecord: ABRecordRef = ABPersonCreate().takeRetainedValue()
        ABRecordSetValue(addressRecord, kABPersonFirstNameProperty, contact.firstName, nil)
        ABRecordSetValue(addressRecord, kABPersonLastNameProperty, contact.lastName, nil)
        // need to use ABMultiValueCreateMutable for email
        let emailAddress:ABMutableMultiValue = ABMultiValueCreateMutable(
            ABPropertyType(kABStringPropertyType)).takeRetainedValue()
        ABMultiValueAddValueAndLabel(emailAddress, contact.email, kABHomeLabel, nil)
        ABRecordSetValue(addressRecord, kABPersonEmailProperty, emailAddress, nil)
        ABPersonSetImageData(addressRecord, contact.photoImage(), nil)
        ABAddressBookAddRecord(addressBookRef, addressRecord, nil);
    }


}

