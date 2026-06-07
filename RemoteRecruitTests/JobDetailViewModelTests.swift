//
//  JobDetailViewModelTests.swift
//  RemoteRecruitTests
//
//  Created by Sanjay Gupta on 05/06/26.
//

import XCTest
@testable import RemoteRecruit

@MainActor
final class JobDetailViewModelTests: XCTestCase {

    func testSeededWithJobStartsLoaded() {
        let job = JobFixtures.make()
        let sut = JobDetailViewModel(job: job, service: StubJobService(behavior: .success([job])))

        XCTAssertEqual(sut.state, .loaded(job))
    }

    func testSeededWithIDStartsLoading() {
        let sut = JobDetailViewModel(jobID: "1", service: StubJobService(behavior: .success([])))
        XCTAssertEqual(sut.state, .loading)
    }

    func testReloadByIDFindsJob() async {
        let job = JobFixtures.make(id: "42")
        let sut = JobDetailViewModel(jobID: "42", service: StubJobService(behavior: .success([job])))

        await sut.reload()

        XCTAssertEqual(sut.state.value?.id, "42")
    }

    func testReloadMissingJobSetsFailed() async {
        let sut = JobDetailViewModel(jobID: "999", service: StubJobService(behavior: .success(JobFixtures.sample)))

        await sut.reload()

        guard case .failed = sut.state else {
            return XCTFail("Expected failed state, got \(sut.state)")
        }
    }
}
