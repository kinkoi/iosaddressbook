//
//  ViewController.swift
//  populate-contacts
//
//  Created by Kinkoi Lo  on 8/31/15.
//
//  Copyright (c) 2015 Kinkoi Lo 
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import SwiftCSV
import AddressBook

struct Constants {
    struct HEADER {
        static let email = "email"
        static let firstName = "first name"
        static let lastName = "last name"
        static let imageName = "image"
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

    override func viewDidLoad() {
        super.viewDidLoad()
        grantAddress()
    }


    @IBAction func populateContacts(sender: UIButton) {
        textView.text! = "";
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
                    if let email = row[Constants.HEADER.email]?.stringByReplacingOccurrencesOfString(" ", withString: "") {
                        contact.email = email
                    }
                    if let firstName = row[Constants.HEADER.firstName]?.stringByReplacingOccurrencesOfString(" ", withString: "") {
                        contact.firstName = firstName
                    }
                    if let lastName = row[Constants.HEADER.lastName]?.stringByReplacingOccurrencesOfString(" ", withString: "") {
                        contact.lastName = lastName
                    }
                    if let imageName = row[Constants.HEADER.imageName]?.stringByReplacingOccurrencesOfString(" ", withString: "") {
                        contact.photo = imageName
                    }
                    addContact2AddressBook(contact)
                }
                if ABAddressBookHasUnsavedChanges(addressBookRef) {
                    var err: Unmanaged<CFErrorRef>? = nil
                    // Use "&err" instead of "err", otherwise it will crash.
                    let result = ABAddressBookSave(addressBookRef, &err)
                    var message = ""
                    if result {
                        message = "Data saved to address book"
                    } else {
                        message = "Failed to update address book"
                    }
                    var alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    presentViewController(alert, animated: true, completion: nil)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
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
                    var alert = UIAlertController(title: "", message: "Need address book access to update record", preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                }
            }
        }
    }
    
    func addContact2AddressBook(contact: Contact) {
        textView.text! += contact.description + "\n";
        let addressRecord: ABRecordRef = ABPersonCreate().takeRetainedValue()
        ABRecordSetValue(addressRecord, kABPersonFirstNameProperty, contact.firstName, nil)
        ABRecordSetValue(addressRecord, kABPersonLastNameProperty, contact.lastName, nil)
        // need to use ABMultiValueCreateMutable for email
        let emailAddress:ABMutableMultiValue = ABMultiValueCreateMutable(
            ABPropertyType(kABStringPropertyType)).takeRetainedValue()
        ABMultiValueAddValueAndLabel(emailAddress, contact.email, kABHomeLabel, nil)
        ABRecordSetValue(addressRecord, kABPersonEmailProperty, emailAddress, nil)
        if let contactImage = contact.photoImage() {
            ABPersonSetImageData(addressRecord, contactImage, nil)
        }
        ABAddressBookAddRecord(addressBookRef, addressRecord, nil);
    }


}

