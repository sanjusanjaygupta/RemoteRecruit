//
//  JobService.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 02/06/26.
//

import Foundation

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

// View models talk to this protocol, not a concrete type. That's what lets
// the tests swap in a stub instead of hitting the real data source.
protocol JobService {
    func fetchJobs() async throws -> [Job]
    func fetchJob(id: String) async throws -> Job
}

extension JobService {
    // Default detail lookup built on fetchJobs(). A real networked service
    // could override this with a dedicated endpoint.
    func fetchJob(id: String) async throws -> Job {
        guard let job = try await fetchJobs().first(where: { $0.id == id }) else {
            throw JobServiceError.notFound
        }
        return job
    }
}
