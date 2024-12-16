//
//  MemberCardLoadedEvent.swift
//  aic
//
//  Copyright © 2024 Art Institute of Chicago. All rights reserved.
//

import Foundation

struct MemberCardLoadedEvent {
    private let cardId: String
    private let memberNames: [String]
    private let memberLevel: String
    private let expirationDate: Date

    init(
        cardId: String,
        memberNames: [String],
        memberLevel: String,
        expirationDate: Date
    ) {
        self.cardId = cardId
        self.memberNames = memberNames
        self.memberLevel = memberLevel
        self.expirationDate = expirationDate
    }

    var parameters: [String: String] {
        [
            "constituent_id": cardId,
            "member_names": joinedMemberNames(),
            "member_level": memberLevel,
            "expiration_date": formattedExpirationDate()
        ]
    }

    private func joinedMemberNames() -> String {
        memberNames.joined(separator: ",")
    }

    private func formattedExpirationDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: expirationDate)
    }
}
