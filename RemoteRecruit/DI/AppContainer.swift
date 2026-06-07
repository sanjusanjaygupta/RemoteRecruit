//
//  AppContainer.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 03/06/26.
//

import Foundation

// Composition root. Owns the service and builds the view models, so all the
// wiring lives in one place and is easy to swap for tests or previews.
@MainActor
final class AppContainer: ObservableObject {
    private let jobService: JobService

    init(jobService: JobService) {
        self.jobService = jobService
    }

    static func live() -> AppContainer {
        AppContainer(jobService: LocalJobService())
    }

    func makeJobListViewModel() -> JobListViewModel {
        JobListViewModel(service: jobService)
    }

    func makeJobDetailViewModel(for job: Job) -> JobDetailViewModel {
        JobDetailViewModel(job: job, service: jobService)
    }
}
