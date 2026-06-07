//
//  ModelAndServiceTests.swift
//  RemoteRecruitTests
//
//  Covers value-type formatting logic and JSON decoding via a service
//  pointed at the test bundle.
//

import XCTest
@testable import RemoteRecruit

final class ModelAndServiceTests: XCTestCase {

    func testSalaryDisplayFormatsYearlyUSD() {
        let salary = SalaryRange(min: 120000, max: 150000, currency: "USD", period: "year")
        XCTAssertEqual(salary.display, "$120,000 – $150,000 / year")
    }

    func testSalaryDisplayFormatsHourlyAndGBP() {
        let hourly = SalaryRange(min: 80, max: 110, currency: "GBP", period: "hour")
        XCTAssertEqual(hourly.display, "£80 – £110 / hour")
    }

    func testLocationDisplayAppendsRemote() {
        let remote = JobFixtures.make()
        XCTAssertEqual(remote.locationDisplay, "Remote · Remote")
    }

    func testDecodingFromJSON() async throws {
        let json = """
        [{
          "id": "1",
          "title": "iOS Engineer",
          "company": { "name": "Aurora", "about": "x", "website": "https://a.com", "size": "small" },
          "location": "Remote",
          "employmentType": "Full-time",
          "isRemote": true,
          "salary": { "min": 100000, "max": 120000, "currency": "USD", "period": "year" },
          "description": "Build things.",
          "postedAt": "2026-05-21T09:00:00Z"
        }]
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let jobs = try decoder.decode([Job].self, from: Data(json.utf8))

        XCTAssertEqual(jobs.count, 1)
        XCTAssertEqual(jobs.first?.company.name, "Aurora")
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
