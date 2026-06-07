//
//  LocalJobService.swift
//  RemoteRecruit
//
//  The production data source. Loads jobs from a bundled JSON file
//  (`jobs.json`) which stands in for a real "Mock API" as allowed by the
//  brief. A small artificial delay is added so the loading state is
//  observable in the UI; it can be set to zero in tests.
//

import Foundation

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
