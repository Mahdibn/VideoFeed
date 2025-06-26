//
//  MockVideosAPI.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

import Foundation

protocol VideosAPI {
    func fetchVideos(page: Int) async throws -> [VideoDTO]
}

final class MockVideosAPI: VideosAPI {
    private var allVideos: [VideoDTO] = []
    private let videosPerPage = 5
    private var numberOfCalls = 0

    init() {
        for i in 0..<100 {
            // Simulate 100 videos
            let creator = CreatorDTO(id: "user\(i)", name: "Creator \(i)", avatarURL: "https://picsum.photos/100")
            let video = VideoDTO(
                id: "\(i)",
                creator: creator,
                shortVideoURL: "https://videos.pexels.com/video-files/5538262/5538262-hd_1920_1080_25fps.mp4",
                fullVideoURL: "https://videos.pexels.com/video-files/5538262/5538262-hd_1920_1080_25fps.mp4",
                description: "This is video number \(i) ",
                likes: Int.random(in: 0...1000),
                comments: Int.random(in: 0...200)
            )
            allVideos.append(video)
        }
    }

    func fetchVideos(page: Int) async throws -> [VideoDTO] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        numberOfCalls += 1
        // Simulate network errors for every 3rd request
        if numberOfCalls % 3 == 0 {
            print("Simulating network error for page \(page)")
            throw APIError.simulationError
        }

        let startIndex = page * videosPerPage
        let endIndex = min(startIndex + videosPerPage, allVideos.count)

        guard startIndex < allVideos.count else {
            return [] // There is no more videos
        }

        return Array(allVideos[startIndex..<endIndex])
    }
}
