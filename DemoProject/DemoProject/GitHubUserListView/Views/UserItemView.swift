//
//  UserItemView.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage

struct UserItemView: View {
    var user: User
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack (alignment: .top){
                // avatar part
                avatarView
                // info part
                infoView
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 120)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

extension UserItemView {
    private var avatarView: some View {
        Group {
//            WebImage(url: URL(string: user.avatarUrl ?? "")) { image in
//                image
//                    .resizable()
//                    .scaledToFit()
//            } placeholder: {
//                Image("man-user-circle-icon")
//                    .resizable()
//                    .scaledToFit()
//            }
            
            AsyncImage(url: URL(string: user.avatarUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure, .empty:
                    Image(systemName: "man-user-circle-icon")
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    Image(systemName: "man-user-circle-icon")
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .frame(maxWidth: 100, maxHeight: 100)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding([.leading, .top, .bottom], 10)
    }
}

extension UserItemView {
    private var infoView: some View {
        VStack(alignment: .leading) {
            Text(user.login ?? "" .uppercased())
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.black)
                .font(.system(size: 15, weight: .bold))
            
            Divider()
            
            if let urlString = user.url, let url = URL(string: urlString) {
                Link(urlString, destination: url)
                    .font(.system(size: 12))
            } else {
                Text("Invalid URL")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.blue)
                    .font(.system(size: 12))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
    }
}

