//
//  ContentView.swift
//  ApiRequestor
//
//  Created by A on 2025/5/27.
//

import SwiftUI

struct KeyValue: Identifiable, Codable, Hashable {
    let id: UUID = UUID()
    var key: String
    var value: String
}

enum HTTPMethod: String, CaseIterable, Identifiable {
    case GET, POST, PUT, DELETE
    var id: String { rawValue }
}

class ApiRequestorViewModel: ObservableObject {
    @AppStorage("http_url") var savedUrl: String = ""
    @AppStorage("http_method") var savedMethod: String = HTTPMethod.GET.rawValue
    @AppStorage("http_headers") var savedHeaders: Data = Data()
    @AppStorage("http_body") var savedBody: Data = Data()
    
    @Published var url: String = ""
    @Published var method: HTTPMethod = .GET
    @Published var headers: [KeyValue] = []
    @Published var body: [KeyValue] = []
    @Published var responseText: String = ""
    @Published var isLoading: Bool = false
    
    init() {
        loadPersisted()
    }
    
    func loadPersisted() {
        url = savedUrl
        method = HTTPMethod(rawValue: savedMethod) ?? .GET
        headers = (try? JSONDecoder().decode([KeyValue].self, from: savedHeaders)) ?? [KeyValue(key: "", value: "")]
        body = (try? JSONDecoder().decode([KeyValue].self, from: savedBody)) ?? [KeyValue(key: "", value: "")]
    }
    
    func persist() {
        savedUrl = url
        savedMethod = method.rawValue
        savedHeaders = (try? JSONEncoder().encode(headers.filter{ !$0.key.isEmpty })) ?? Data()
        savedBody = (try? JSONEncoder().encode(body.filter{ !$0.key.isEmpty })) ?? Data()
    }
    
    func updateHeader(at idx: Int, key: String, value: String) {
        headers[idx].key = key
        headers[idx].value = value
        persist()
    }
    
    func updateBody(at idx: Int, key: String, value: String) {
        body[idx].key = key
        body[idx].value = value
        persist()
    }
    
    func addHeader() {
        headers.append(KeyValue(key: "", value: ""))
        persist()
    }
    func removeHeader(at idx: Int) {
        headers.remove(at: idx)
        persist()
    }
    func addBody() {
        body.append(KeyValue(key: "", value: ""))
        persist()
    }
    func removeBody(at idx: Int) {
        body.remove(at: idx)
        persist()
    }
    func clearHeaders() {
        headers = [KeyValue(key: "", value: "")]
        persist()
    }
    func clearBody() {
        body = [KeyValue(key: "", value: "")]
        persist()
    }
    func clearResponse() {
        responseText = ""
    }
    
    func requestJsonString() -> String {
        let hDict = Dictionary(uniqueKeysWithValues: headers.filter{ !$0.key.isEmpty }.map { ($0.key, $0.value) })
        let bDict = Dictionary(uniqueKeysWithValues: body.filter{ !$0.key.isEmpty }.map { ($0.key, $0.value) })
        let json: [String: Any] = [
            "url": url,
            "method": method.rawValue,
            "headers": hDict,
            "body": bDict
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let s = String(data: data, encoding: .utf8) else { return "{}" }
        return s
    }
    
    func sendRequest() {
        //MOCK DATA
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            [weak self] in guard let self else {return}
            self.isLoading = false
            self.responseText = requestJsonString()
        }
        
        
        //TODO
//        guard let reqUrl = URL(string: url), !url.isEmpty else {
//            responseText = "❗️URL 格式錯誤"
//            return
//        }
//        isLoading = true
//        responseText = ""
//
//        var request = URLRequest(url: reqUrl)
//        request.httpMethod = method.rawValue
//
//        for h in headers where !h.key.isEmpty {
//            request.setValue(h.value, forHTTPHeaderField: h.key)
//        }
//
//        if method == .POST || method == .PUT {
//            let bDict = Dictionary(uniqueKeysWithValues: body.filter{ !$0.key.isEmpty }.map{ ($0.key, $0.value) })
//            if !bDict.isEmpty, let data = try? JSONSerialization.data(withJSONObject: bDict, options: []) {
//                request.httpBody = data
//                if request.value(forHTTPHeaderField: "Content-Type") == nil {
//                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                }
//            }
//        }
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, resp, err in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                if let err = err {
//                    self?.responseText = "❗️\(err.localizedDescription)"
//                    return
//                }
//                if let data = data,
//                   let obj = try? JSONSerialization.jsonObject(with: data),
//                   let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
//                   let prettyStr = String(data: pretty, encoding: .utf8) {
//                    self?.responseText = prettyStr
//                } else if let data = data, let str = String(data: data, encoding: .utf8) {
//                    self?.responseText = str
//                } else {
//                    self?.responseText = "（無回應內容）"
//                }
//            }
//        }.resume()
    }
}

struct ContentView: View {
    @StateObject var vm = ApiRequestorViewModel()
    @FocusState private var focus: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // URL 與 Method
                HStack {
                    Picker("", selection: $vm.method) {
                        ForEach(HTTPMethod.allCases) { m in Text(m.rawValue).tag(m) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80)
                    TextField("請輸入 URL", text: $vm.url)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focus)
                        .onChange(of: vm.url) { _ in vm.persist() }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Header 管理
                Section(header: HStack {
                    Text("Header").bold()
                    Spacer()
                    Button("清除") { vm.clearHeaders() }.font(.caption)
                }.padding(.horizontal, 10)) {
                    ForEach(Array(vm.headers.enumerated()), id: \.1.id) { idx, kv in
                        HStack {
                            TextField("Key", text: Binding(
                                get: { kv.key },
                                set: { vm.updateHeader(at: idx, key: $0, value: kv.value) }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Value", text: Binding(
                                get: { kv.value },
                                set: { vm.updateHeader(at: idx, key: kv.key, value: $0) }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: { vm.removeHeader(at: idx) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    Button(action: vm.addHeader) {
                        Label("新增 Header", systemImage: "plus.circle")
                            .font(.caption)
                    }.padding(.horizontal, 10)
                }
                
                // Body 管理
                Section(header: HStack {
                    Text("Body").bold()
                    Spacer()
                    Button("清除") { vm.clearBody() }.font(.caption)
                }.padding(.horizontal, 10)) {
                    ForEach(Array(vm.body.enumerated()), id: \.1.id) { idx, kv in
                        HStack {
                            TextField("Key", text: Binding(
                                get: { kv.key },
                                set: { vm.updateBody(at: idx, key: $0, value: kv.value) }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Value", text: Binding(
                                get: { kv.value },
                                set: { vm.updateBody(at: idx, key: kv.key, value: $0) }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: { vm.removeBody(at: idx) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    Button(action: vm.addBody) {
                        Label("新增 Body", systemImage: "plus.circle")
                            .font(.caption)
                    }.padding(.horizontal, 10)
                }
                
                // 發送與清除
                HStack {
                    Button(action: {
                        focus = false
                        withAnimation(.easeInOut(duration: 0.3)) {
                            vm.sendRequest()
                        }
                    }) {
                        HStack {
                            if vm.isLoading { ProgressView() }
                            Text("發送請求")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(12)
                    }
                    Button("清除回應") { withAnimation { vm.clearResponse() } }
                        .font(.caption)
                }
                .padding(.top, 5)
                
                // 雙區塊顯示
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Request JSON")
                                .font(.caption2).bold()
                                .padding(.horizontal, 10)
                                .padding(.top, 6)
                            ScrollView {
                                selectionTextView(vm.requestJsonString(), foregroundColor: .blue)
                            }
                        }
                        .frame(width: geo.size.width/2)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Response JSON")
                                    .font(.caption2).bold()
                                Spacer()
                                Button("複製") {
                                    UIPasteboard.general.string = vm.responseText
                                }
                                .font(.caption2)
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 6)
                            ScrollView {
                                selectionTextView(vm.responseText, foregroundColor: .green)
                                    .animation(.easeIn(duration: 0.25), value: vm.responseText)
                            }
                        }
                        .frame(width: geo.size.width/2)
                    }
                }
            }
            .navigationTitle("Api Requestor")
        }
    }
    
    private func selectionTextView(_ text: String, foregroundColor: Color) -> some View {
        TextEditor(text: .constant(text))
            .font(.system(size: 13, design: .monospaced))
            .foregroundColor(foregroundColor)
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal, 10)
            .disabled(true)
            .textSelection(.enabled)
    }
}
