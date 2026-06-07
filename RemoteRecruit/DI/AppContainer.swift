//
//  AppContainer.swift
//  RemoteRecruit
//
//  The composition root / dependency-injection container. It owns the
//  concrete service and knows how to build view models. Views ask the
//  container for view models rather than constructing services themselves,
//  which keeps wiring in one place and makes the graph easy to swap in
//  tests or previews.
//

import Foundation

@MainActor
final class AppContainer: ObservableObject {
    private let jobService: JobService

    init(jobService: JobService) {
        self.jobService = jobService
    }

    /// The real container used by the running app.
    static func live() -> AppContainer {
        AppContainer(jobService: LocalJobService())
    }

    // MARK: - View model factories

    func makeJobListViewModel() -> JobListViewModel {
        JobListViewModel(service: jobService)
    }

    func makeJobDetailViewModel(for job: Job) -> JobDetailViewModel {
        JobDetailViewModel(job: job, service: jobService)
    }
}
