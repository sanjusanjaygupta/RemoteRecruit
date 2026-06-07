//
//  RemoteRecruitApp.swift
//  RemoteRecruit
//
//  App entry point. Wires up the dependency container and injects it
//  into the SwiftUI environment so view models can resolve services.
//

import SwiftUI

@main
struct RemoteRecruitApp: App {
    /// The single composition root for the app. In a larger app this could be
    /// swapped for a different container (e.g. one backed by a live network
    /// service) without touching any view code.
    private let container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            JobListView(viewModel: container.makeJobListViewModel())
                .environmentObject(container)
        }
    }
}
