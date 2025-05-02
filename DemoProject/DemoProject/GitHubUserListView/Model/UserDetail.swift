//
//  UserDetail.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import Foundation

// MARK: - UserDetailModel
struct UserDetail: Codable {
    let login : String?
    let name: String?
    let id : Int?
    let avatarUrl : String?
    let url : String?
    let htmlUrl : String?
    let location : String?
    let followers : Int?
    let following : Int?
    let blog : String?
    
    enum CodingKeys: String, CodingKey {
        
        case login = "login"
        case name = "name"
        case id = "id"
        case avatarUrl = "avatar_url"
        case url = "url"
        case htmlUrl = "html_url"
        case location = "location"
        case followers = "followers"
        case following = "following"
        case blog = "blog"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        login = try values.decodeIfPresent(String.self, forKey: .login)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        htmlUrl = try values.decodeIfPresent(String.self, forKey: .htmlUrl)
        location = try values.decodeIfPresent(String.self, forKey: .location)
        followers = try values.decodeIfPresent(Int.self, forKey: .followers)
        following = try values.decodeIfPresent(Int.self, forKey: .following)
        blog = try values.decodeIfPresent(String.self, forKey: .blog)
    }
    
    init() {
        login = ""
        name = ""
        id = 0
        avatarUrl = ""
        url = ""
        htmlUrl = ""
        location = ""
        followers = 0
        following = 0
        blog = ""
    }
    
    func getUserFollowers() -> String {
        guard let followers = followers else {
            return "0"
        }
        return "\(followers)"
    }
    
    func getUserFollowing() -> String {
        guard let following = following else {
            return "0"
        }
        return "\(following)"
    }
}
