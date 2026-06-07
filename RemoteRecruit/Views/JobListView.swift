//
//  JobListView.swift
//  RemoteRecruit
//
//  The job listing screen. Renders from the view model's ViewState and
//  hosts the search bar. Navigation pushes the detail screen, building its
//  view model from the shared container.
//

import SwiftUI

struct JobListView: View {
    @StateObject private var viewModel: JobListViewModel
    @EnvironmentObject private var container: AppContainer

    init(viewModel: JobListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Jobs")
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search by title or company"
                )
        }
        .task { await viewModel.loadJobs() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingStateView()

        case .loaded(let jobs):
            List(jobs) { job in
                NavigationLink {
                    JobDetailView(viewModel: container.makeJobDetailViewModel(for: job))
                } label: {
                    JobRowView(job: job)
                }
            }
            .listStyle(.plain)
            .refreshable { await viewModel.loadJobs() }

        case .empty:
            EmptyStateView(
                title: viewModel.searchText.isEmpty ? "No jobs available" : "No matches",
                message: viewModel.searchText.isEmpty
                    ? "Check back later for new opportunities."
                    : "Try a different title or company name."
            )

        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.loadJobs() }
            }
        }
    }
}
