//
//  RemoteRecruitApp.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 01/06/26.
//

import SwiftUI

@main
struct RemoteRecruitApp: App {
    private let container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            JobListView(viewModel: container.makeJobListViewModel())
                .environmentObject(container)
        }
    }
}
