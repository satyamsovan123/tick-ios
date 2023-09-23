//
//  AuthenticationManager.swift
//  Tick
//
//  Created by Satyam Sovan Mishra on 14/09/23.
//

import Foundation

protocol AuthenticationManagerDelegate {
    func didCompleteAuthentication(_ authenticationManager: AuthenticationManager, authenticationResponse: AuthenticationResponse, token: String)
    func didFailWithError(error: Error)
}

struct AuthenticationManager {
    let serverUrl = K.App.serverUrl
    
    var delegate: AuthenticationManagerDelegate?
    
    func authenticate(authenticationRequest: AuthenticationRequest, action: String) {
    
        if(action == "") {
            return
        }
        
        if let serverUrl = URL(string: "\(serverUrl)\(action)") {
            var request = URLRequest(url: serverUrl)
            request.httpMethod = "POST"
            request.httpBody = JSONToDataConverter(json: authenticationRequest)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request, completionHandler: completionHandler)
            task.resume()
        }
    }
    
    func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        var token = ""
        if(error != nil) {
            delegate?.didFailWithError(error: error!)
        }
        
        if let safeResponse = response {
            if let rawToken = (safeResponse as! HTTPURLResponse).value(forHTTPHeaderField: K.App.authenticationHeader) {
                token = rawToken.components(separatedBy: " ")[1]
            }
        }

        if let safeData = data {
            if let authenticationResponse = dataToJSONConverter(data: safeData) {
                delegate?.didCompleteAuthentication(self, authenticationResponse: authenticationResponse, token: token)
            }
        }
    }
    
    func JSONToDataConverter(json: AuthenticationRequest) -> Data? {
        let encoder = JSONEncoder()
        do {
            let authenticationRequest = try encoder.encode(json)
            return authenticationRequest
        } catch {
            return nil
        }
    }
    
    func dataToJSONConverter(data: Data) -> AuthenticationResponse? {
        let decoder = JSONDecoder()
        do {
            let authenticationResponse = try decoder.decode(AuthenticationResponse.self, from: data)
            return authenticationResponse
        } catch {
            return nil
        }
    }
}
