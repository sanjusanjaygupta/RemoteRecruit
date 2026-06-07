//
//  JobService.swift
//  RemoteRecruit
//
//  The service abstraction used by the view models. Depending on an
//  abstraction (not a concrete type) is what makes the view models
//  testable: tests inject a stub, the app injects the JSON-backed service.
//

import Foundation

/// Errors surfaced by a `JobService`.
enum JobServiceError: LocalizedError, Equatable {
    case notFound
    case decodingFailed
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "We couldn't find the jobs file. Please try again."
        case .decodingFailed:
            return "We couldn't read the job data. Please try again."
        case .underlying(let message):
            return message
        }
    }
}

/// Provides access to job postings. Implementations may hit a network API,
/// a mock server, or a bundled JSON file.
protocol JobService {
    /// Returns all available jobs.
    func fetchJobs() async throws -> [Job]

    /// Returns a single job by id, or throws `.notFound`.
    func fetchJob(id: String) async throws -> Job
}

extension JobService {
    /// Default detail lookup built on top of `fetchJobs()`. Concrete
    /// implementations can override this for a more efficient query.
    func fetchJob(id: String) async throws -> Job {
        guard let job = try await fetchJobs().first(where: { $0.id == id }) else {
            throw JobServiceError.notFound
        }
        return job
    }
}
