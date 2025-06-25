//
//  FeedViewModel.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

import Combine

@MainActor
class FeedViewModel: ObservableObject {
    // MARK: - Variables
    @Published private(set) var videos: [Video] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var videoVersions: [String: VideoVersion] = [:]

    private let useCase: FetchVideosUseCase
    private var currentPage = 1
    private var isFetching = false

    // MARK: - Init
    init(useCase: FetchVideosUseCase) {
        self.useCase = useCase
    }

    // MARK: - Methods
    func fetchNextPage() async {
        guard !isFetching else { return }
        isFetching = true
        isLoading = true
        
        defer {
            isLoading = false
            isFetching = false
        }

        errorMessage = nil

        do {
            let newVideos = try await useCase.execute(page: currentPage)
            videos.append(contentsOf: newVideos)
            currentPage += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleLike(for video: Video) {
        guard let index = videos.firstIndex(where: { $0.id == video.id }) else { return }
        var updatedVideo = video
        updatedVideo.isLiked.toggle()
        updatedVideo.likes += (updatedVideo.isLiked ? 1 : -1)
        videos[index] = updatedVideo
    }

    func toggleVersion(for video: Video) {
        let current = videoVersions[video.id] ?? .short
        videoVersions[video.id] = (current == .short ? .full : .short)
    }

    func version(for video: Video) -> VideoVersion {
        videoVersions[video.id] ?? .short
    }
}

enum VideoVersion {
    case short, full
}
