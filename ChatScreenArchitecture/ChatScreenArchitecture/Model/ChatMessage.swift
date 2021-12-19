//
//  ChatMessage.swift
//  ChatScreenArchitecture
//
//  Created by Jageloo Yadav on 19/12/21.
//

import Foundation

struct User: Codable {
    var username: String
    var userProfile: String?
    var userDisplayName: String?
}

enum ChatType: String, Codable {
    case privateChat
    case groupChat
}

struct ChatMessage: Codable {
    var conversationId: String?
    var from: User?
    var toUser: User?
    var to: String?
    var message: String?
    var link: String?
    var createDate: String?
    var chatType: ChatType
}
