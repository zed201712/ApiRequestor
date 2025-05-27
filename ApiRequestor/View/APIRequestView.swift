//
//  APIRequestView.swift
//  ApiRequestor
//
//  Created by Zed on 2025/5/24.
//

import SwiftUI

struct APIRequestView: View {
    @ObservedObject var vm: APIRequestViewModel
    @ObservedObject var manager: APIManager
    
    var body: some View {
        //VStack {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // 環境切換
//                        Picker("環境", selection: $manager.currentEnvironment) {
//                            ForEach(manager.environments) { env in
//                                Text(env.name).tag(Optional(env))
//                            }
//                        }
//                        .pickerStyle(.menu)
//                        .onChange(of: manager.currentEnvironment) { newEnv in
//                            if let env = newEnv {
//                                vm.request.url = env.baseURL
//                                // vm.request.headers += token ...
//                            }
//                        }
                        // ... 請求設定、Header、Body
                        // 發送時自動帶入 token/baseURL 等
                        
                        Group {
                            TextField("請輸入API URL", text: $vm.request.url)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .textFieldStyle(.roundedBorder)
                            
                            Picker("HTTP方法", selection: $vm.request.method) {
                                ForEach(HTTPMethod.allCases) { method in
                                    Text(method.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Header 輸入
                        Section(header: Text("Header")) {
                            ForEach($vm.request.headers) { $header in
                                HStack {
                                    TextField("Key", text: $header.key)
                                    TextField("Value", text: $header.value)
                                    Button(action: {
                                        vm.request.headers.removeAll { $0.id == header.id }
                                    }) {
                                        Image(systemName: "minus.circle")
                                    }
                                }
                            }
                            Button("新增Header") {
                                vm.request.headers.append(APIKeyValue())
                            }
                        }
                        
                        // Body 輸入
                        Section(header: Text("Body")) {
                            Toggle("直接輸入Raw Body", isOn: $vm.request.useRawBody)
                            if vm.request.useRawBody {
                                TextEditor(text: $vm.request.rawBody)
                                    .frame(height: 100)
                                    .font(.system(.body, design: .monospaced))
                                    .border(Color.gray)
                            } else {
                                ForEach($vm.request.body) { $param in
                                    HStack {
                                        TextField("Key", text: $param.key)
                                        TextField("Value", text: $param.value)
                                        Button(action: {
                                            vm.request.body.removeAll { $0.id == param.id }
                                        }) {
                                            Image(systemName: "minus.circle")
                                        }
                                    }
                                }
                                Button("新增Body參數") {
                                    vm.request.body.append(APIKeyValue())
                                }
                            }
                        }
                        
                        Button(action: {
                            vm.sendRequest()
                        }) {
                            if vm.isLoading {
                                ProgressView()
                            } else {
                                Text("發送請求")
                                    .bold()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                        
                        // 回應顯示
                        if let response = vm.response {
                            Section(header: Text("回應")) {
                                if let code = response.statusCode {
                                    Text("狀態碼: \(code)")
                                }
                                if let headers = response.headers {
                                    DisclosureGroup("Headers") {
                                        ForEach(headers.keys.sorted(by: { "\($0)" < "\($1)" }), id: \.self) { key in
                                            Text("\(key): \(headers[key] ?? "")")
                                                .font(.caption)
                                        }
                                    }
                                }
                                if let body = response.body {
                                    TextEditor(text: .constant(body))
                                        .frame(height: 180)
                                        .font(.system(.body, design: .monospaced))
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(8)
                                }
                                if let duration = response.duration {
                                    Text("耗時: \(String(format: "%.2f", duration)) 秒")
                                        .font(.caption)
                                }
                                if let size = response.size {
                                    Text("大小: \(size) bytes")
                                        .font(.caption)
                                }
                                if let error = response.error {
                                    Text("錯誤: \(error)")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("API 測試工具")
            }
        }
    //}
}
