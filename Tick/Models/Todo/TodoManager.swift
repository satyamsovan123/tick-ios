//
//  TodoManager.swift
//  Tick
//
//  Created by Satyam Sovan Mishra on 12/09/23.
//

import Foundation

protocol TodoManagerDelegate {
    func didReceiveTodos(_ todoManager: TodoManager, response: TodoResponse)
    func didUpdateTodos(_ todoManager: TodoManager, response: TodoResponse)
    func didFailWithError(error: Error)
}

struct TodoManager {
    let serverUrl = "\(K.App.serverUrl)todo"
    
    var delegate: TodoManagerDelegate?
    
    func getTodos(token: String) {
       
        if let serverUrl = URL(string: serverUrl) {
            var request = URLRequest(url: serverUrl)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: K.App.authenticationHeader)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request, completionHandler: getTodosCompletionHandler)
            task.resume()
        }
    }
    
    func getTodosCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
        if(error != nil) {
            delegate?.didFailWithError(error: error!)
        }
        
        if let safeData = data {
            if let todoResponse = dataToJSONConverter(data: safeData) {
                delegate?.didReceiveTodos(self, response: todoResponse)
            }
        }
    }
    
    func updateTodos(todoRequest: TodoRequest?, action: String, token: String) {
        var httpMethod = ""
        switch action {
        case "delete":
            httpMethod = "DELETE"
        case "add":
            httpMethod = "POST"
        default:
            httpMethod = ""
        }
        
        
        if let serverUrl = URL(string: serverUrl) {
            var request = URLRequest(url: serverUrl)
            request.httpMethod = httpMethod
            if(action == "add") {
                request.httpBody = JSONToDataConverter(json: todoRequest!)
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: K.App.authenticationHeader)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request, completionHandler: updateTodosCompletionHandler)
            task.resume()
        }
    }
    
    func updateTodosCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {

        if(error != nil) {
            delegate?.didFailWithError(error: error!)
        }
        
        if let safeData = data {
            if let todoResponse = dataToJSONConverter(data: safeData) {
                delegate?.didUpdateTodos(self, response: todoResponse)
            }
        }
    }
    
    func JSONToDataConverter(json: TodoRequest) -> Data? {
        let encoder = JSONEncoder()
        do {
            let todoRequest = try encoder.encode(json)
            return todoRequest
        } catch {
            return nil
        }
    }
    
    func dataToJSONConverter(data: Data) -> TodoResponse? {
        let decoder = JSONDecoder()
        do {
            let todoResponse = try decoder.decode(TodoResponse.self, from: data)
           
            return todoResponse
        } catch {
            return nil
        }
    }
}
