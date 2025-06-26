//
//  VideoRepositoryImplTests.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import XCTest
@testable import VideoFeed

final class VideoRepositoryImplTests: XCTestCase {
    var mockVideosAPI: MockVideosAPIProtocol! // Using the protocol for the mock
    var sut: VideoRepositoryImpl!

    override func setUpWithError() throws {
        mockVideosAPI = MockVideosAPIForRepo()
        sut = VideoRepositoryImpl(api: mockVideosAPI)
    }

    override func tearDownWithError() throws {
        mockVideosAPI = nil
        sut = nil
    }

    func testFetchVideos_Success() async throws {
        // Given
        let videoDTOs = [
            VideoDTO.mock(id: "repo_1"),
            VideoDTO.mock(id: "repo_2")
        ]
        (mockVideosAPI as! MockVideosAPIForRepo).result = .success(videoDTOs)
        let page = 0

        // When
        let fetchedVideos = try await sut.fetchVideos(page: page)

        // Then
        XCTAssertEqual(fetchedVideos.count, videoDTOs.count)
        XCTAssertEqual(fetchedVideos[0].id, videoDTOs[0].id)
        XCTAssertEqual(fetchedVideos[1].id, videoDTOs[1].id)
        XCTAssertEqual((mockVideosAPI as! MockVideosAPIForRepo).fetchVideosCallCount, 1)
        XCTAssertEqual((mockVideosAPI as! MockVideosAPIForRepo).lastPagePassed, page)
    }

    func testFetchVideos_Failure() async throws {
        // Given
        let expectedError = APIError.invalidResponse
        (mockVideosAPI as! MockVideosAPIForRepo).result = .failure(expectedError)
        let page = 0

        // When
        do {
            _ = try await sut.fetchVideos(page: page)
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            // Then
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
            XCTAssertEqual((mockVideosAPI as! MockVideosAPIForRepo).fetchVideosCallCount, 1)
            XCTAssertEqual((mockVideosAPI as! MockVideosAPIForRepo).lastPagePassed, page)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Mocks for VideoRepositoryImplTests
protocol MockVideosAPIProtocol: VideosAPI {}

fileprivate class MockVideosAPIForRepo: MockVideosAPIProtocol {
    var result: Result<[VideoDTO], Error> = .success([])
    var fetchVideosCallCount = 0
    var lastPagePassed: Int?

    func fetchVideos(page: Int) async throws -> [VideoDTO] {
        fetchVideosCallCount += 1
        lastPagePassed = page
        switch result {
        case .success(let dtos):
            return dtos
        case .failure(let error):
            throw error
        }
    }
}

fileprivate extension VideoDTO {
    static func mock(id: String) -> VideoDTO {
        VideoDTO(
            id: id,
            creator: CreatorDTO(id: "creator_dto_\(id)", name: "Creator DTO \(id)", avatarURL: "https://example.com/avatar_dto/\(id).png"),
            shortVideoURL: "https://example.com/short_dto_\(id).mp4",
            fullVideoURL: "https://example.com/full_dto_\(id).mp4",
            description: "Description for video DTO \(id)",
            likes: Int.random(in: 1...1000),
            comments: Int.random(in: 1...200)
        )
    }
}
