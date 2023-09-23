//
//  Constants.swift
//  Tick
//
//  Created by Satyam Sovan Mishra on 14/09/23.
//

import Foundation

struct K {
    struct App {
        static let serverUrl = "http://localhost:3000/api/"
        static let authenticationHeader = "Authorization"
    }
    
    struct textField {
        static let email = "Email"
        static let password = "Password"
        static let todo = "Todo"
    }
    
    struct errorMessage {
        static let genericError = "Some error occured. Please try again."
    }
    
    struct successMessage {
        static let signinSuccessful = "You are now signed in."
        static let signupSuccessful = "You are now signed up."
        
        static let todoRetrivalSuccessful =  "Your todos were retrived successfully."
        static let todoAdditionSuccessful =  "Your todo was added successfully."
        static let todoDeletionSuccessful =  "Your todos were deleted successfully."
    }
}
