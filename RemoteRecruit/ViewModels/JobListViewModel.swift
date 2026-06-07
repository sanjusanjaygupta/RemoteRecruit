//
//  JobListViewModel.swift
//  RemoteRecruit
//
//  Drives the job listing screen. Owns the full list of jobs, applies the
//  search filter, and exposes a single `ViewState` the view renders from.
//  Marked @MainActor so all published mutations happen on the main thread.
//

import Foundation

@MainActor
final class JobListViewModel: ObservableObject {
    /// The state the list screen renders. The associated value is the
    /// *filtered* list currently shown to the user.
    @Published private(set) var state: ViewState<[Job]> = .loading

    /// Two-way bound to the search bar.
    @Published var searchText: String = "" {
        didSet { applyFilter() }
    }

    private let service: JobService
    private var allJobs: [Job] = []

    init(service: JobService) {
        self.service = service
    }

    /// Loads jobs from the service and updates `state`. Safe to call again
    /// for pull-to-refresh / retry.
    func loadJobs() async {
        state = .loading
        do {
            allJobs = try await service.fetchJobs()
            applyFilter()
        } catch {
            state = .failed(message: Self.message(for: error))
        }
    }

    /// Recomputes the visible list from `allJobs` + `searchText` without
    /// re-hitting the service.
    private func applyFilter() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let filtered: [Job]
        if query.isEmpty {
            filtered = allJobs
        } else {
            filtered = allJobs.filter { job in
                job.title.localizedCaseInsensitiveContains(query) ||
                job.company.name.localizedCaseInsensitiveContains(query)
            }
        }

        state = filtered.isEmpty ? .empty : .loaded(filtered)
    }

    private static func message(for error: Error) -> String {
        (error as? LocalizedError)?.errorDescription ?? "Something went wrong. Please try again."
    }
}
