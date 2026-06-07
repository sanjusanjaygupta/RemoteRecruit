//
//  LocalJobService.swift
//  RemoteRecruit
//
//  Created by Sanjay Gupta on 02/06/26.
//

import Foundation

// Reads jobs from the bundled jobs.json. Stands in for a real API for now -
// swapping in a URLSession-based service later only touches AppContainer.
final class LocalJobService: JobService {
    private let bundle: Bundle
    private let fileName: String
    private let artificialDelay: Duration
    private let decoder: JSONDecoder

    init(
        bundle: Bundle = .main,
        fileName: String = "jobs",
        artificialDelay: Duration = .milliseconds(600)
    ) {
        self.bundle = bundle
        self.fileName = fileName
        self.artificialDelay = artificialDelay

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func fetchJobs() async throws -> [Job] {
        // Small delay so the loading state is actually visible. Tests pass
        // .zero to skip it.
        if artificialDelay > .zero {
            try? await Task.sleep(for: artificialDelay)
        }

        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw JobServiceError.notFound
        }

        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([Job].self, from: data)
        } catch is DecodingError {
            throw JobServiceError.decodingFailed
        } catch {
            throw JobServiceError.underlying(error.localizedDescription)
        }
    }
}
