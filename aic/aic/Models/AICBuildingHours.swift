//
//  AICBuildingHours.swift
//  aic
//
//  Created by David Bireta on 3/2/26.
//  Copyright © 2026 Art Institute of Chicago. All rights reserved.
//

import Foundation

struct AICBuildingHours: Decodable {
    let data: [ResponseData]
    
    struct ResponseData: Decodable {
        let id: Int
        let additional_text: String
        let updated_at: String
        let monday_is_closed: Bool
        let monday_member_open: String
        let monday_member_close: String
        let monday_public_open: String
        let monday_public_close: String
        let tuesday_is_closed: Bool
        let tuesday_member_open: String?
        let tuesday_member_close: String?
        let tuesday_public_open: String?
        let tuesday_public_close: String?
        let wednesday_is_closed: Bool
        let wednesday_member_open: String
        let wednesday_member_close: String
        let wednesday_public_open: String
        let wednesday_public_close: String
        let thursday_is_closed: Bool
        let thursday_member_open: String
        let thursday_member_close: String
        let thursday_public_open: String
        let thursday_public_close: String
        let friday_member_open: String
        let friday_member_close: String
        let friday_public_open: String
        let friday_public_close: String
        let friday_is_closed: Bool
        let saturday_is_closed: Bool
        let saturday_member_open: String
        let saturday_member_close: String
        let saturday_public_open: String
        let saturday_public_close: String
        let sunday_is_closed: Bool
        let sunday_member_open: String
        let sunday_member_close: String
        let sunday_public_open: String
        let sunday_public_close: String
    }
    
    func displayString(for day: Locale.Weekday) -> String {
        switch day {
            case .monday:
                guard data.first?.monday_is_closed == false else { return "Closed" }
                return "\(openHour(for: .monday)?.hour, default: "") - \(closeHour(for: .monday)?.hour, default: "")"
            case .tuesday:
                guard data.first?.tuesday_is_closed == false else { return "Closed" }
                return "\(openHour(for: .tuesday)?.hour, default: "") - \(closeHour(for: .tuesday)?.hour, default: "")"
            case .wednesday:
                guard data.first?.wednesday_is_closed == false else { return "Closed" }
                return "\(openHour(for: .wednesday)?.hour, default: "") - \(closeHour(for: .wednesday)?.hour, default: "")"
            case .thursday:
                guard data.first?.thursday_is_closed == false else { return "Closed" }
                return "\(openHour(for: .thursday)?.hour, default: "") - \(closeHour(for: .thursday)?.hour, default: "")"
            case .friday:
                // This includes Friday - Sunday
                guard data.first?.friday_is_closed == false else { return "Closed" }
                return "\(openHour(for: .friday)?.hour, default: "") - \(closeHour(for: .sunday)?.hour, default: "")"
            default:
                return ""
        }
    }
    
    func openHour(for day: Locale.Weekday) -> DateComponents? {
        timeString(for: day, isOpen: true).flatMap { parse($0) }
    }

    func closeHour(for day: Locale.Weekday) -> DateComponents? {
        timeString(for: day, isOpen: false).flatMap { parse($0) }
    }

    private func timeString(for day: Locale.Weekday, isOpen: Bool) -> String? {
        guard let row = data.first else { return nil }
        
        switch day {
            case .monday:
                return isOpen ? row.monday_public_open : row.monday_public_close
            case .tuesday:
                return isOpen ? row.tuesday_public_open : row.tuesday_public_close
            case .wednesday:
                return isOpen ? row.wednesday_public_open : row.wednesday_public_close
            case .thursday:
                return isOpen ? row.thursday_public_open : row.thursday_public_close
            case .friday:
                return isOpen ? row.friday_public_open : row.friday_public_close
            case .saturday:
                return isOpen ? row.saturday_public_open : row.saturday_public_close
            case .sunday:
                return isOpen ? row.sunday_public_open : row.sunday_public_close
            @unknown default:
                return nil
        }
    }

    private func parse(_ timeString: String) -> DateComponents? {
        let pattern = #/PT(\d+)H(\d+)M/#

        if let match = timeString.firstMatch(of: pattern) {
            let hour = Int(match.1)
            let minute = Int(match.2)

            return DateComponents(hour: hour, minute: minute)
        }

        return nil
    }
}

extension AICBuildingHours {
    static var preview: AICBuildingHours {
        AICBuildingHours(data: [
            ResponseData(
                id: 1,
                additional_text: "The first hour of every day, 10-11 a.m., is reserved for member-only viewing.",
                updated_at: "2026-04-01T00:00:00Z",
                monday_is_closed: false,
                monday_member_open: "PT10H00M",
                monday_member_close: "PT17H00M",
                monday_public_open: "PT10H00M",
                monday_public_close: "PT17H00M",
                tuesday_is_closed: true,
                tuesday_member_open: "PT9H00M",
                tuesday_member_close: "PT17H00M",
                tuesday_public_open: "PT10H00M",
                tuesday_public_close: "PT17H00M",
                wednesday_is_closed: false,
                wednesday_member_open: "PT9H00M",
                wednesday_member_close: "PT17H00M",
                wednesday_public_open: "PT10H00M",
                wednesday_public_close: "PT17H00M",
                thursday_is_closed: false,
                thursday_member_open: "PT9H00M",
                thursday_member_close: "PT20H00M",
                thursday_public_open: "PT10H00M",
                thursday_public_close: "PT20H00M",
                friday_member_open: "PT9H00M",
                friday_member_close: "PT17H00M",
                friday_public_open: "PT10H00M",
                friday_public_close: "PT17H00M",
                friday_is_closed: false,
                saturday_is_closed: false,
                saturday_member_open: "PT9H00M",
                saturday_member_close: "PT17H00M",
                saturday_public_open: "PT10H00M",
                saturday_public_close: "PT17H00M",
                sunday_is_closed: false,
                sunday_member_open: "PT9H00M",
                sunday_member_close: "PT17H00M",
                sunday_public_open: "PT10H00M",
                sunday_public_close: "PT17H00M"
            )
        ])
    }
}
