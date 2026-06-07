//
//  JobDetailViewModel.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 04/06/26.
//

import Foundation

@MainActor
final class JobDetailViewModel: ObservableObject {
    @Published private(set) var state: ViewState<Job>

    private let jobID: String
    private let service: JobService

    // Common path: the list already has the full Job, so show it right away.
    init(job: Job, service: JobService) {
        self.jobID = job.id
        self.service = service
        self.state = .loaded(job)
    }

    // For when we only have an id (e.g. a deep link) and need to load it.
    init(jobID: String, service: JobService) {
        self.jobID = jobID
        self.service = service
        self.state = .loading
    }

    func reload() async {
        state = .loading
        do {
            let job = try await service.fetchJob(id: jobID)
            state = .loaded(job)
        } catch {
            state = .failed(message: Self.message(for: error))
        }
    }

    private static func message(for error: Error) -> String {
        (error as? LocalizedError)?.errorDescription ?? "Something went wrong. Please try again."
    }
}
