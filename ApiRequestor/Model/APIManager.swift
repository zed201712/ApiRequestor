//
//  APIManager.swift
//  ApiRequestor
//
//  Created by Zed on 2025/5/24.
//

import Foundation

class APIManager: ObservableObject {
    @Published var environments: [APIEnvironment] = [
        .init(name: "本地", baseURL: "http://localhost:8080", token: ""),
    ]
    @Published var currentEnvironment: APIEnvironment?
    
    @Published var history: [APIRequestRecord] = []
    @Published var favorites: [APIRequestRecord] = []
    
    // Load/Save from UserDefaults (簡化範例)
    private let envKey = "APIEnvironments"
    private let hisKey = "APIHistory"
    
    init() {
        loadData()
    }
    
    func addHistory(_ request: APIRequest) {
        let record = APIRequestRecord(request: request, date: Date(), isFavorite: false)
        history.insert(record, at: 0)
        saveData()
    }
    func addFavorite(_ record: APIRequestRecord) {
        var fav = record
        fav.isFavorite = true
        favorites.insert(fav, at: 0)
        saveData()
    }
    func removeFavorite(_ record: APIRequestRecord) {
        favorites.removeAll { $0.id == record.id }
        saveData()
    }
    
    // Data persistence
    private func loadData() {
        // decode from UserDefaults...
    }
    private func saveData() {
        // encode to UserDefaults...
    }
    
    // 環境切換
    func switchEnv(_ env: APIEnvironment) {
        currentEnvironment = env
    }
}
