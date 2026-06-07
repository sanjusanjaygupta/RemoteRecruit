//
//  Job.swift
//  RemoteRecruit
//
//  Domain models. These are decoded from the data source and consumed
//  directly by the view models. Kept as immutable value types.
//

import Foundation

/// A single job posting.
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

    /// Convenience text used in list rows and the detail header.
    var locationDisplay: String {
        isRemote ? "\(location) · Remote" : location
    }
}

/// Information about the hiring company.
struct Company: Equatable, Codable {
    let name: String
    let about: String
    let website: String
    let size: String
}

/// A salary range with a currency and pay period.
struct SalaryRange: Equatable, Codable {
    let min: Int
    let max: Int
    let currency: String
    let period: String // e.g. "year", "hour"

    /// Human-readable salary, e.g. "$120,000 – $150,000 / year".
    var display: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        // Pin the grouping so salaries render consistently regardless of the
        // device locale (e.g. "120,000" rather than "1,20,000").
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3

        let minString = formatter.string(from: NSNumber(value: min)) ?? "\(min)"
        let maxString = formatter.string(from: NSNumber(value: max)) ?? "\(max)"
        let symbol = Self.symbol(for: currency)

        return "\(symbol)\(minString) – \(symbol)\(maxString) / \(period)"
    }

    private static func symbol(for currency: String) -> String {
        switch currency.uppercased() {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        default: return "\(currency) "
        }
    }
}
