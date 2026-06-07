//
//  Job.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 01/06/26.
//

import Foundation

struct Job: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let company: Company
    let location: String
    let employmentType: String
    let isRemote: Bool
    let salary: SalaryRange
    let description: String
    let postedAt: Date

    var locationDisplay: String {
        isRemote ? "\(location) · Remote" : location
    }
}

struct Company: Equatable, Codable {
    let name: String
    let about: String
    let website: String
    let size: String
}

struct SalaryRange: Equatable, Codable {
    let min: Int
    let max: Int
    let currency: String
    let period: String   // "year", "month", "hour"

    // e.g. "₹12,00,000 – ₹25,00,000 / year"
    var display: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true

        // Indian rupees use the lakh/crore grouping (12,00,000), so let the
        // en_IN locale handle it. Other currencies use the regular 3-digit
        // grouping. Pinning the locale keeps the output the same on every
        // device regardless of the user's region settings.
        if currency.uppercased() == "INR" {
            formatter.locale = Locale(identifier: "en_IN")
        } else {
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.groupingSeparator = ","
            formatter.groupingSize = 3
        }

        let minText = formatter.string(from: NSNumber(value: min)) ?? "\(min)"
        let maxText = formatter.string(from: NSNumber(value: max)) ?? "\(max)"
        let symbol = Self.symbol(for: currency)

        return "\(symbol)\(minText) – \(symbol)\(maxText) / \(period)"
    }

    private static func symbol(for currency: String) -> String {
        switch currency.uppercased() {
        case "INR": return "₹"
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        default:    return "\(currency) "
        }
    }
}
