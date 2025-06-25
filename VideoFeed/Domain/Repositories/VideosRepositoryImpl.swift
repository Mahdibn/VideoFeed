//
//  VideosRepositoryImpl.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

final class VideoRepositoryImpl: VideosRepository {
    private let api: VideosAPI

    init(api: VideosAPI = MockVideosAPI()) {
        self.api = api
    }

    func fetchVideos(page: Int) async throws -> [Video] {
        let dtoList = try await api.fetchVideos(page: page)
        return dtoList.map { VideoMapper.map(dto: $0) }
    }
}
