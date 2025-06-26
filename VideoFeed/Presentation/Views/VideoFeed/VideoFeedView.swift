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
    private let scrollDetectionThreshold: CGFloat = 0.5

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.videos.isEmpty && viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.retryLoading()
                        }
                    }
                } else if viewModel.videos.isEmpty {
                   EmptyViewPlaceholder()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            LazyVStack(spacing: 0) { // Set spacing to 0 for full-page effect
                                ForEach(viewModel.videos) { video in
                                    VideoCardView(video: video, isActive: .constant(activeVideoId == video.id))
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .onAppear {
                                            viewModel.loadMoreContentIfNeeded(currentItem: video)
                                        }
                                        .id(video.id)
                                        .background(
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .preference(key: VideoCardFramePreferenceKey.self, value: [video.id: geometry.frame(in: .named("ScrollView"))])
                                            }
                                        )
                                }

                                if viewModel.isLoading && !viewModel.videos.isEmpty {
                                    ProgressView()
                                        .padding()
                                }
                            }
                            // This preference change listener will detect which video is most visible
                            .onPreferenceChange(VideoCardFramePreferenceKey.self) { preferences in
                                let screenCenterY = geometry.size.height / 2
                                var closestVideoId: String?
                                var minDistance: CGFloat = .infinity

                                for (id, frame) in preferences {
                                    // Check if the video is significantly visible
                                    let visibleHeight = max(0, min(frame.maxY, geometry.size.height) - max(frame.minY, 0))
                                    if visibleHeight >= frame.height * scrollDetectionThreshold {
                                        let videoCenterY = frame.midY
                                        let distance = abs(videoCenterY - screenCenterY)
                                        if distance < minDistance {
                                            minDistance = distance
                                            closestVideoId = id
                                        }
                                    }
                                }

                                if let newActiveVideoId = closestVideoId,
                                   newActiveVideoId != activeVideoId {
                                    activeVideoId = newActiveVideoId
                                    // Snap to the closest video
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo(newActiveVideoId, anchor: .center)
                                    }
                                }
                            }
                            .onAppear {
                                // Initial scroll to the first video if available
                                if let firstVideo = viewModel.videos.first {
                                    activeVideoId = firstVideo.id
                                    proxy.scrollTo(firstVideo.id, anchor: .center)
                                }
                            }
                        }
                    }
                    .clipped()
                    .coordinateSpace(name: "ScrollView")
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

fileprivate struct VideoCardFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { (current, new) in new }
    }
}
