//
//  JobDetailViewModel.swift
//  RemoteRecruit
//
//  Drives the job details screen. The list already holds the full Job, so
//  this can be seeded synchronously; it can also (re)load by id to support
//  deep links or stale data.
//

import Foundation

@MainActor
final class JobDetailViewModel: ObservableObject {
    @Published private(set) var state: ViewState<Job>

    private let jobID: String
    private let service: JobService

    /// Seeds the screen with a job already in hand (the common path from
    /// the list), so the detail renders instantly.
    init(job: Job, service: JobService) {
        self.jobID = job.id
        self.service = service
        self.state = .loaded(job)
    }

    /// Seeds the screen with only an id (e.g. a deep link) and loads on
    /// appear.
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
