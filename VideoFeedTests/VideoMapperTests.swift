//
//  VideoMapperTests.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import XCTest
@testable import VideoFeed

final class VideoMapperTests: XCTestCase {
    func testMapVideoDTOToVideo_Success() {
        // Given
        let videoDTO = VideoDTO(
            id: "123",
            creator: CreatorDTO(id: "creator456", name: "Test Creator", avatarURL: "https://example.com/avatar.png"),
            shortVideoURL: "https://example.com/short_video.mp4",
            fullVideoURL: "https://example.com/full_video.mp4",
            description: "This is a test video description.",
            likes: 1234,
            comments: 567
        )

        // When
        let video = VideoMapper.map(dto: videoDTO)

        // Then
        XCTAssertEqual(video.id, videoDTO.id)
        XCTAssertEqual(video.creator.id, videoDTO.creator.id)
        XCTAssertEqual(video.creator.name, videoDTO.creator.name)
        XCTAssertEqual(video.creator.avatarURL.absoluteString, videoDTO.creator.avatarURL)
        XCTAssertEqual(video.shortVideoURL.absoluteString, videoDTO.shortVideoURL)
        XCTAssertEqual(video.fullVideoURL.absoluteString, videoDTO.fullVideoURL)
        XCTAssertEqual(video.description, videoDTO.description)
        XCTAssertEqual(video.likes, videoDTO.likes)
        XCTAssertEqual(video.comments, videoDTO.comments)
    }

    func testMapVideoDTOToVideo_InvalidURLs() {
        let videoDTO = VideoDTO(
            id: "invalid_urls",
            creator: CreatorDTO(id: "creator_invalid", name: "Invalid Creator", avatarURL: "not-a-valid-url"),
            shortVideoURL: "another invalid url",
            fullVideoURL: "yet another invalid url",
            description: "Video with invalid URLs.",
            likes: 10,
            comments: 2
        )

        XCTAssertNoThrow(VideoMapper.map(dto: videoDTO)) // This test fails if it crashes
    }
}
