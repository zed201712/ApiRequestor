//
//  ContentView.swift
//  ApiRequestor
//
//  Created by Zed on 2025/5/27.
//

import SwiftUI

struct MainView: View {
    @StateObject var manager = APIManager()
    @StateObject var vm = APIRequestViewModel()
    
    var body: some View {
//        NavigationSplitView {
//            SidebarView(manager: manager)
//        } detail: {
            APIRequestView(vm: vm, manager: manager)
//        }
    }
}
