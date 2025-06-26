//
//  FetchVideosUseCaseImpleTests.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import XCTest
@testable import VideoFeed

final class FetchVideosUseCaseImplTests: XCTestCase {
    private var mockVideosRepository: MockVideosRepository!
    private var sut: FetchVideosUseCaseImpl!

    override func setUpWithError() throws {
        mockVideosRepository = MockVideosRepository()
        sut = FetchVideosUseCaseImpl(videoRepository: mockVideosRepository)
    }

    override func tearDownWithError() throws {
        mockVideosRepository = nil
        sut = nil
    }

    func testExecute_Success() async throws {
        // Given
        let expectedVideos = [
            Video.mock(id: "usecase_1"),
            Video.mock(id: "usecase_2")
        ]
        mockVideosRepository.result = .success(expectedVideos)
        let page = 0

        // When
        let fetchedVideos = try await sut.execute(page: page)

        // Then
        XCTAssertEqual(fetchedVideos, expectedVideos)
        XCTAssertEqual(mockVideosRepository.fetchVideosCallCount, 1)
        XCTAssertEqual(mockVideosRepository.lastPagePassed, page)
    }

    func testExecute_Failure() async throws {
        // Given
        let expectedError = APIError.networkError(URLError(.notConnectedToInternet))
        mockVideosRepository.result = .failure(expectedError)
        let page = 0

        // When
        do {
            _ = try await sut.execute(page: page)
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            // Then
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
            XCTAssertEqual(mockVideosRepository.fetchVideosCallCount, 1)
            XCTAssertEqual(mockVideosRepository.lastPagePassed, page)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Mocks for FetchVideosUseCaseImplTests
fileprivate class MockVideosRepository: VideosRepository {
    var result: Result<[Video], Error> = .success([])
    var fetchVideosCallCount = 0
    var lastPagePassed: Int?

    func fetchVideos(page: Int) async throws -> [Video] {
        fetchVideosCallCount += 1
        lastPagePassed = page
        switch result {
        case .success(let videos):
            return videos
        case .failure(let error):
            throw error
        }
    }
}

fileprivate extension Video {
    static func mock(id: String) -> Video {
        Video(
            id: id,
            creator: Creator(id: "creator_dto_\(id)", name: "Creator DTO \(id)", avatarURL: URL(string: "https://example.com/avatar_dto/\(id).png")!),
            shortVideoURL: URL(string: "https://example.com/short_dto_\(id).mp4")!,
            fullVideoURL: URL(string: "https://example.com/full_dto_\(id).mp4")!,
            description: "Description for video DTO \(id)",
            likes: Int.random(in: 1...1000),
            comments: Int.random(in: 1...200)
        )
    }
}
