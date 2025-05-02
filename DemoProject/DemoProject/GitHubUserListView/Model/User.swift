//
//  User.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import Foundation

struct User: Decodable, Identifiable {
    var id: Int?
    var login: String?
    var avatarUrl: String?
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case login = "login"
        case avatarUrl = "avatar_url"
        case url = "url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        login = try values.decodeIfPresent(String.self, forKey: .login)
        avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
        url = try values.decodeIfPresent(String.self, forKey: .url)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
