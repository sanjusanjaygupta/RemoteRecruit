//
//  JobRowView.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 04/06/26.
//

import SwiftUI

// A single row in the jobs list: title, company, location and salary.
struct JobRowView: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.title)
                .font(.headline)

            Text(job.company.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                Text(job.locationDisplay)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Text(job.salary.display)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tint)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
