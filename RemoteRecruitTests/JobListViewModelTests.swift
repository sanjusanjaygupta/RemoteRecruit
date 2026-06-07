//
//  JobListViewModelTests.swift
//  RemoteRecruitTests
//
//  Created by Sanjay Gupta on 05/06/26.
//

import XCTest
@testable import RemoteRecruit

@MainActor
final class JobListViewModelTests: XCTestCase {

    func testInitialStateIsLoading() {
        let sut = JobListViewModel(service: StubJobService(behavior: .success([])))
        XCTAssertEqual(sut.state, .loading)
    }

    func testLoadJobsSuccessSetsLoaded() async {
        let sut = JobListViewModel(service: StubJobService(behavior: .success(JobFixtures.sample)))

        await sut.loadJobs()

        XCTAssertEqual(sut.state.value?.count, 3)
    }

    func testLoadJobsWithNoResultsSetsEmpty() async {
        let sut = JobListViewModel(service: StubJobService(behavior: .success([])))

        await sut.loadJobs()

        XCTAssertEqual(sut.state, .empty)
    }

    func testLoadJobsFailureSetsFailedWithMessage() async {
        let sut = JobListViewModel(service: StubJobService(behavior: .failure(JobServiceError.notFound)))

        await sut.loadJobs()

        guard case .failed(let message) = sut.state else {
            return XCTFail("Expected failed state, got \(sut.state)")
        }
        XCTAssertEqual(message, JobServiceError.notFound.errorDescription)
    }

    func testSearchFiltersByTitle() async {
        let sut = JobListViewModel(service: StubJobService(behavior: .success(JobFixtures.sample)))
        await sut.loadJobs()

        sut.searchText = "payments"

        XCTAssertEqual(sut.state.value?.map(\.id), ["3"])
    }

    func testSearchFiltersByCompany() async {
        let sut = JobListViewModel(service: StubJobService(behavior: .success(JobFixtures.sample)))
        await sut.loadJobs()

        sut.searchText = "northpay"

        XCTAssertEqual(sut.state.value?.map(\.id), ["2", "3"])
    }

    func testSearchIsCaseInsensitiveAndTrimmed() async {
        let sut = JobListViewModel(service: StubJobService(behavior: .success(JobFixtures.sample)))
        await sut.loadJobs()

        sut.searchText = "  SENIOR  "

        XCTAssertEqual(sut.state.value?.map(\.id), ["1"])
    }

    func testSearchWithNoMatchSetsEmpty() async {
        let sut = JobListViewModel(service: StubJobService(behavior: .success(JobFixtures.sample)))
        await sut.loadJobs()

        sut.searchText = "doesnotexist"

        XCTAssertEqual(sut.state, .empty)
    }

    func testClearingSearchRestoresFullList() async {
        let sut = JobListViewModel(service: StubJobService(behavior: .success(JobFixtures.sample)))
        await sut.loadJobs()
        sut.searchText = "senior"

        sut.searchText = ""

        XCTAssertEqual(sut.state.value?.count, 3)
    }

    func testRetryAfterFailureSucceeds() async {
        let service = StubJobService(behavior: .failure(JobServiceError.decodingFailed))
        let sut = JobListViewModel(service: service)
        await sut.loadJobs()

        service.behavior = .success(JobFixtures.sample)
        await sut.loadJobs()

        XCTAssertEqual(sut.state.value?.count, 3)
    }
}
