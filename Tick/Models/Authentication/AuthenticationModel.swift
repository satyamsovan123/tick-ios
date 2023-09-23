//
//  AuthenticationModel.swift
//  Tick
//
//  Created by Satyam Sovan Mishra on 14/09/23.
//

import Foundation

struct AuthenticationRequest: Codable {
    let email: String
    let password: String
}

struct AuthenticationResponse: Codable {
    var message: String
}
