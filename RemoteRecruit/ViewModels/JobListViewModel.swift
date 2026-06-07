//
//  JobListViewModel.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 03/06/26.
//

import Foundation

@MainActor
final class JobListViewModel: ObservableObject {
    // The state the list screen renders. Its value is the filtered list
    // currently shown to the user.
    @Published private(set) var state: ViewState<[Job]> = .loading

    @Published var searchText: String = "" {
        didSet { applyFilter() }
    }

    private let service: JobService
    private var allJobs: [Job] = []

    init(service: JobService) {
        self.service = service
    }

    // Safe to call again for retry / pull-to-refresh.
    func loadJobs() async {
        state = .loading
        do {
            allJobs = try await service.fetchJobs()
            applyFilter()
        } catch {
            state = .failed(message: Self.message(for: error))
        }
    }

    // Filter in memory so typing stays instant and we don't re-hit the
    // service on every keystroke.
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
