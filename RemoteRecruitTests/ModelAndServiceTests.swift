//
//  ModelAndServiceTests.swift
//  RemoteRecruitTests
//
//  Created by Sanjay Gupta on 06/06/26.
//

import XCTest
@testable import RemoteRecruit

final class ModelAndServiceTests: XCTestCase {

    func testSalaryDisplayFormatsINRWithIndianGrouping() {
        let salary = SalaryRange(min: 1200000, max: 2500000, currency: "INR", period: "year")
        XCTAssertEqual(salary.display, "₹12,00,000 – ₹25,00,000 / year")
    }

    func testSalaryDisplayFormatsHourlyINR() {
        let hourly = SalaryRange(min: 1800, max: 2800, currency: "INR", period: "hour")
        XCTAssertEqual(hourly.display, "₹1,800 – ₹2,800 / hour")
    }

    func testSalaryDisplayFormatsNonIndianCurrency() {
        let salary = SalaryRange(min: 120000, max: 150000, currency: "USD", period: "year")
        XCTAssertEqual(salary.display, "$120,000 – $150,000 / year")
    }

    func testLocationDisplayAppendsRemote() {
        let remote = JobFixtures.make()
        XCTAssertEqual(remote.locationDisplay, "Bengaluru, Karnataka · Remote")
    }

    func testDecodingFromJSON() throws {
        let json = """
        [{
          "id": "1",
          "title": "iOS Engineer",
          "company": { "name": "Finbox", "about": "x", "website": "https://a.com", "size": "small" },
          "location": "Bengaluru",
          "employmentType": "Full-time",
          "isRemote": true,
          "salary": { "min": 1200000, "max": 2000000, "currency": "INR", "period": "year" },
          "description": "Build things.",
          "postedAt": "2026-05-21T09:00:00Z"
        }]
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let jobs = try decoder.decode([Job].self, from: Data(json.utf8))

        XCTAssertEqual(jobs.count, 1)
        XCTAssertEqual(jobs.first?.company.name, "Finbox")
        XCTAssertEqual(jobs.first?.salary.currency, "INR")
    }

    func testLocalServiceThrowsNotFoundForMissingFile() async {
        let service = LocalJobService(
            bundle: .main,
            fileName: "does-not-exist",
            artificialDelay: .zero
        )

        do {
            _ = try await service.fetchJobs()
            XCTFail("Expected an error")
        } catch let error as JobServiceError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
