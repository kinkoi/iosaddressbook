//
//  Contact.swift
//  populate-contacts
//
//  Created by Kinkoi Lo  on 8/31/15.
//  Copyright (c) 2015 Kinkoi Lo . All rights reserved.
//

import Foundation
import UIKit

class Contact: Printable{
    var firstName = "null"
    var lastName = "null"
    var email = "null"
    var photo = "null"
    
    var description : String {
        return firstName + " " + lastName + " " + email + " " + photo
    }
    
    func photoImage() -> NSData! {
        return  UIImagePNGRepresentation(UIImage(named: self.photo))
    }
}