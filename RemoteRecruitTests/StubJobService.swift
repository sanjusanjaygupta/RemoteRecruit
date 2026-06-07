//
//  StubJobService.swift
//  RemoteRecruitTests
//
//  Created by Sanjay Gupta on 05/06/26.
//

import Foundation
@testable import RemoteRecruit

// Test double for JobService. Each test sets the behaviour it needs:
// a fixed list, an empty list, or a thrown error.
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

enum JobFixtures {
    static func make(
        id: String = "1",
        title: String = "iOS Engineer",
        companyName: String = "Finbox Technologies"
    ) -> Job {
        Job(
            id: id,
            title: title,
            company: Company(
                name: companyName,
                about: "A great company.",
                website: "https://example.com",
                size: "201–500 employees"
            ),
            location: "Bengaluru, Karnataka",
            employmentType: "Full-time",
            isRemote: true,
            salary: SalaryRange(min: 1200000, max: 2000000, currency: "INR", period: "year"),
            description: "Build great things.",
            postedAt: Date(timeIntervalSince1970: 0)
        )
    }

    static let sample: [Job] = [
        make(id: "1", title: "Senior iOS Engineer", companyName: "Finbox Technologies"),
        make(id: "2", title: "Backend Engineer", companyName: "NorthPay Solutions"),
        make(id: "3", title: "iOS Engineer, Payments", companyName: "NorthPay Solutions")
    ]
}
