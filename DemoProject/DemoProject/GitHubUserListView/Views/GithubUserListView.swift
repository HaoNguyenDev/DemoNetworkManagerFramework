//
//  GithubUserListView.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import SwiftUI

struct GithubUserListView: View {
    @StateObject private var viewModel = GitHubUserListVM()
    @State private var showErrorAlert: Bool = false
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.users) { user in
                    UserItemView(user: user)
                        .onAppear {
                            viewModel.loadMoreDataIfNeed(currentUser: user)
                        }
                }
            }
        }
        .navigationBarTitle("GitHub Users")
//        .task {
//            await viewModel.fetchUsers()
//        }
        .onAppear {
            viewModel.fetchUser2()
        }
        .onReceive(viewModel.$error, perform: { error in
            if error != nil {
                showErrorAlert = true
            }
        })
        .modifier(AlertHandler(showAlert: $showErrorAlert, error: viewModel.error, onDismiss: {
            showErrorAlert = false
        }))
    }
}

#Preview {
    GithubUserListView()
}
