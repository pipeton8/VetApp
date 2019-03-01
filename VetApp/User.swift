//
//  User.swift
//  VetApp
//
//  Created by Felipe Del Canto Monge on 2/28/19.
//  Copyright © 2019 Felipe Del Canto. All rights reserved.
//

import Foundation

enum UserCreationError: Error {
    case shortPassword
    case lowComplexity
    case invalidCharacters
}

struct PasswordSecurity {
    let minimumLength : Int = 10
    let acceptedSpecialCharacters : String = " !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
}

class User {
    
    var username : String = ""
    var password : String = ""
    
    init(newUser : String, newPassword : String) {
        username = newUser
        password = newPassword
    }
}
