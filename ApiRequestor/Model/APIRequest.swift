//
//  APIRequest.swift
//  ApiRequestor
//
//  Created by Zed on 2025/5/24.
//

import Foundation

enum HTTPMethod: String, CaseIterable, Identifiable, Codable {
    case GET, POST, PUT, DELETE, PATCH
    var id: String { self.rawValue }
}

struct APIKeyValue: Identifiable, Hashable, Codable {
    var id = UUID()
    var key: String = ""
    var value: String = ""
}

struct APIRequest: Identifiable, Codable {
    var id = UUID()
    var url: String = ""
    var method: HTTPMethod = .GET
    var headers: [APIKeyValue] = []
    var body: [APIKeyValue] = []
    var rawBody: String = ""
    var useRawBody: Bool = false
}

struct APIResponse {
    var statusCode: Int?
    var headers: [AnyHashable: Any]?
    var body: String?
    var error: String?
    var duration: TimeInterval?
    var size: Int?
}

class APIRequestViewModel: ObservableObject {
    @Published var request = APIRequest()
    @Published var response: APIResponse?
    @Published var isLoading = false
    
    func sendRequest() {
        guard let url = URL(string: request.url) else {
            self.response = APIResponse(error: "無效的URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // Header
        for header in request.headers where !header.key.isEmpty {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Body
        if request.method != .GET {
            if request.useRawBody {
                urlRequest.httpBody = request.rawBody.data(using: .utf8)
            } else if !request.body.isEmpty {
                let dict = Dictionary(uniqueKeysWithValues: request.body.compactMap {
                    !$0.key.isEmpty ? ($0.key, $0.value) : nil
                })
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: dict)
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    self.response = APIResponse(error: "JSON格式錯誤")
                    return
                }
            }
        }
        
        self.isLoading = true
        let start = Date()
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, res, error in
            DispatchQueue.main.async {
                self.isLoading = false
                let duration = Date().timeIntervalSince(start)
                if let error = error {
                    self.response = APIResponse(error: error.localizedDescription, duration: duration)
                    return
                }
                guard let httpRes = res as? HTTPURLResponse else {
                    self.response = APIResponse(error: "無法解析回應", duration: duration)
                    return
                }
                let size = data?.count
                let body = data.flatMap { String(data: $0, encoding: .utf8) }
                self.response = APIResponse(
                    statusCode: httpRes.statusCode,
                    headers: httpRes.allHeaderFields,
                    body: body,
                    duration: duration,
                    size: size
                )
            }
        }
        task.resume()
    }
}
