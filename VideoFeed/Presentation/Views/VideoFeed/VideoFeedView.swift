//
//  VideoFeedView.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import SwiftUI
import AVKit

struct VideoFeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var activeVideoId: String?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                switch viewModel.state {
                case .loading:
                    LoadingView()

                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.retryLoading() }
                    }

                case .empty:
                    EmptyViewPlaceholder()

                case .loaded:
                    VideoListView(
                        geometry: geometry,
                        videos: viewModel.videos,
                        isLoading: viewModel.isLoading,
                        activeVideoId: $activeVideoId,
                        loadMore: viewModel.loadMoreContentIfNeeded
                    )
                }
            }
            .task {
                if viewModel.videos.isEmpty {
                    await viewModel.fetchVideos()
                }
            }
        }
    }
}
