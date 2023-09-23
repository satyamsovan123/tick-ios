//
//  TodoModel.swift
//  Tick
//
//  Created by Satyam Sovan Mishra on 09/09/23.
//

import Foundation

struct TodoResponse: Codable {
    let data: [TodoRequest]?
    let message: String
}

struct TodoRequest: Codable {
    let isComplete: Bool
    let todo: String
}
