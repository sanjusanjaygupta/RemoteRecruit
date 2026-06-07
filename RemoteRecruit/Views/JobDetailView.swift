//
//  JobDetailView.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 05/06/26.
//

import SwiftUI

struct JobDetailView: View {
    @StateObject private var viewModel: JobDetailViewModel

    init(viewModel: JobDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingStateView()
            case .loaded(let job):
                detail(for: job)
            case .empty:
                EmptyStateView(title: "Job unavailable", message: "This job is no longer available.")
            case .failed(let message):
                ErrorStateView(message: message) {
                    Task { await viewModel.reload() }
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detail(for job: Job) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header(for: job)
                Divider()
                section("About the role") {
                    Text(job.description)
                        .font(.body)
                }
                section("Company") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(job.company.name).font(.headline)
                        Text(job.company.about).font(.body)
                        Label(job.company.size, systemImage: "person.3")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        if let url = URL(string: job.company.website) {
                            Link(destination: url) {
                                Label(job.company.website, systemImage: "link")
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func header(for job: Job) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(job.title)
                .font(.title2.bold())
            Text(job.company.name)
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Label(job.locationDisplay, systemImage: "mappin.and.ellipse")
                Label(job.employmentType, systemImage: "clock")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Text(job.salary.display)
                .font(.headline)
                .foregroundStyle(.tint)
                .padding(.top, 4)
        }
    }

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }
}
