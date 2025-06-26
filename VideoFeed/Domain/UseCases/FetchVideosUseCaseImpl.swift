//
//  FetchVideosUseCaseImpl.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

final class FetchVideosUseCaseImpl: FetchVideosUseCase {
    private let videoRepository: VideosRepository
    
    init(videoRepository: VideosRepository = VideoRepositoryImpl()) {
        self.videoRepository = videoRepository
    }

    func execute(page: Int) async throws -> [Video] {
        try await videoRepository.fetchVideos(page: page)
    }
}
