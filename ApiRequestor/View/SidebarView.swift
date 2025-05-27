//
//  SidebarView.swift
//  ApiRequestor
//
//  Created by Zed on 2025/5/24.
//

import Foundation
import SwiftUI

struct SidebarView: View {
    @ObservedObject var manager: APIManager
    
    var body: some View {
        List {
            Section(header: Text("環境變數")) {
                ForEach(manager.environments) { env in
                    HStack {
                        Text(env.name)
                        if env == manager.currentEnvironment {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
                        }
                    }.onTapGesture {
                        manager.switchEnv(env)
                    }
                }
            }
            
            Section(header: Text("收藏夾")) {
                ForEach(manager.favorites) { record in
                    Text(record.request.url)
                }
            }
            
            Section(header: Text("歷史紀錄")) {
                ForEach(manager.history) { record in
                    VStack(alignment: .leading) {
                        Text(record.request.url).font(.body)
                        Text(record.date, style: .time).font(.caption)
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
}
