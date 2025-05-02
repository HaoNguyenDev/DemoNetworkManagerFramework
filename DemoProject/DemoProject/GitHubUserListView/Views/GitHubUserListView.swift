//
//  GitHubUserListView.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import SwiftUI

struct GitHubUserListView: View {
    @StateObject private var viewModel = GitHubUserListVM()
    @State private var showErrorAlert: Bool = false
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.users) { user in
                    UserItemView(user: user)
                        .onAppear {
                            loadMoreDataIfNeed(currentUser: user)
                        }
                }
            }
        }
        .navigationBarTitle("GitHub Users")
        .task {
            await viewModel.fetchUsers()
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

extension GitHubUserListView {
    func loadMoreDataIfNeed(currentUser: User) {
        guard let lastUser = viewModel.users.last, currentUser == lastUser,
        !viewModel.isLoading,
        !viewModel.users.isEmpty else { return }
        #if DEBUG
        print(">>> Load more data from user withID \(String(describing: currentUser.id))")
        #endif
        /* load more if scroll to the last user */
        Task {
            await viewModel.loadMoreUser()
        }
    }
}

#Preview {
    GitHubUserListView()
}
