//
//  FeedViewModel.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    // MARK: - Variables
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var currentPage = 0
    private var canLoadMorePages = true

    private let useCase: FetchVideosUseCase

    var state: ViewState {
        if isLoading && videos.isEmpty {
            return .loading
        } else if let error = errorMessage {
            return .error(error)
        } else if videos.isEmpty {
            return .empty
        } else {
            return .loaded
        }
    }

    // MARK: - Init
    init(useCase: FetchVideosUseCase = FetchVideosUseCaseImpl()) {
        self.useCase = useCase
    }

    // MARK: - Methods
     func fetchVideos() async {
         guard !isLoading && canLoadMorePages else { return }
         isLoading = true
         errorMessage = nil

         do {
             let newVideos = try await useCase.execute(page: currentPage)
             if newVideos.isEmpty {
                 canLoadMorePages = false
             } else {
                 videos.append(contentsOf: newVideos)
                 currentPage += 1
             }
         } catch {
             errorMessage = "Failed to load videos: \(error.localizedDescription)"
             print("Error fetching videos: \(error)")
         }
         isLoading = false

         if videos.isEmpty && errorMessage == nil {
             errorMessage = "No videos available"
         }
     }
    
    func retryLoading() async {
        errorMessage = nil
        await fetchVideos()
    }
    
    func loadMoreContentIfNeeded(currentItem: Video?) {
        guard let currentItem,
              let lastVideo = videos.last,
              currentItem.id == lastVideo.id,
              !isLoading,
              canLoadMorePages else {
            return
        }
        Task {
            await fetchVideos()
        }
    }
}
