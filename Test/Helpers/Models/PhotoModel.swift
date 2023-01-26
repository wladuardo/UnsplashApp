//
//  PhotoModel.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import Foundation

struct Results: Codable {
    var total: Int
    var results: [Result]
}

struct Result: Codable {
    var urls: URLs
}

struct URLs: Codable {
    var regular: String
}
