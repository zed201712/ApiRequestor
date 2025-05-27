//
//  APIRequestRecord.swift
//  ApiRequestor
//
//  Created by Zed on 2025/5/24.
//

import Foundation

struct APIEnvironment: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var baseURL: String
    var token: String?
}

struct APIRequestRecord: Identifiable, Codable {
    var id = UUID()
    var request: APIRequest
    var date: Date
    var isFavorite: Bool
    var groupName: String?
}
