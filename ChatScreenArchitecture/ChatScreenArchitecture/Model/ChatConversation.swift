//
//  ChatConversation.swift
//  ChatScreenArchitecture
//
//  Created by Jageloo Yadav on 19/12/21.
//

import Foundation

struct ChatConversation: Codable {
    var conversationid: String?
    var loggedUser: User?
    var otherUser: User?
    var lastMessage: String?
    var dateString: String?
    var messageType: String?
    var unReadMsgCount = 0
    var lastChatVisitTime: String
    var conversationtype: String
    var groupName: String
    var groupPic: String
    var lastMessageOwner: String = ""
    var groupAdmin = ""
}
