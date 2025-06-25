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

class MockVideosAPI: VideosAPI {
    private var requestCount = 0

    func fetchVideos(page: Int) async throws -> [VideoDTO] {
        requestCount += 1
        if requestCount % 3 == 0 {
            throw URLError(.badServerResponse)
        }

        return (1...15).map {
            VideoDTO(
                id: UUID().uuidString,
                creator: CreatorDTO(
                    id: "creator\($0)",
                    name: "Creator \($0)",
                    avatarURL: "https://picsum.photos/100"
                ),
                shortVideoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                fullVideoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                description: "Description \($0)",
                likes: Int.random(in: 0...2000),
                comments: Int.random(in: 0...200)
            )
        }
    }
}
