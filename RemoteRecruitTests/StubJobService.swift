//
//  StubJobService.swift
//  RemoteRecruitTests
//
//  A configurable test double implementing `JobService`. Lets each test
//  control exactly what the view model receives: a fixed list, an empty
//  list, or a thrown error.
//

import Foundation
@testable import RemoteRecruit

final class StubJobService: JobService {
    enum Behavior {
        case success([Job])
        case failure(Error)
    }

    var behavior: Behavior
    private(set) var fetchJobsCallCount = 0

    init(behavior: Behavior) {
        self.behavior = behavior
    }

    func fetchJobs() async throws -> [Job] {
        fetchJobsCallCount += 1
        switch behavior {
        case .success(let jobs):
            return jobs
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Fixtures

enum JobFixtures {
    static func make(
        id: String = "1",
        title: String = "iOS Engineer",
        companyName: String = "Aurora Labs"
    ) -> Job {
        Job(
            id: id,
            title: title,
            company: Company(
                name: companyName,
                about: "A great company.",
                website: "https://example.com",
                size: "51–200 employees"
            ),
            location: "Remote",
            employmentType: "Full-time",
            isRemote: true,
            salary: SalaryRange(min: 100000, max: 130000, currency: "USD", period: "year"),
            description: "Build great things.",
            postedAt: Date(timeIntervalSince1970: 0)
        )
    }

    static let sample: [Job] = [
        make(id: "1", title: "Senior iOS Engineer", companyName: "Aurora Labs"),
        make(id: "2", title: "Backend Engineer", companyName: "Northwind Bank"),
        make(id: "3", title: "iOS Engineer, Payments", companyName: "Northwind Bank")
    ]
}
