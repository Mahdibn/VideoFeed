//
//  VideoListView.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import SwiftUI

struct VideoListView: View {
    let geometry: GeometryProxy
    let videos: [Video]
    let isLoading: Bool
    @Binding var activeVideoId: String?
    let loadMore: (Video) -> Void
    private let scrollDetectionThreshold: CGFloat = 0.5

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { proxy in
                LazyVStack(spacing: 0) {
                    ForEach(videos) { video in
                        VideoCardView(video: video, isActive: .constant(activeVideoId == video.id))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .onAppear {
                                loadMore(video)
                            }
                            .id(video.id)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: VideoCardFramePreferenceKey.self,
                                            value: [video.id: geo.frame(in: .named("ScrollView"))]
                                        )
                                }
                            )
                    }

                    if isLoading {
                        ProgressView().padding()
                    }
                }
                .onPreferenceChange(VideoCardFramePreferenceKey.self) { preferences in
                    updateActiveVideo(from: preferences, in: geometry, proxy: proxy)
                }
                .onAppear {
                    if let first = videos.first {
                        activeVideoId = first.id
                        proxy.scrollTo(first.id, anchor: .center)
                    }
                }
            }
        }
        .coordinateSpace(name: "ScrollView")
        .clipped()
    }

    private func updateActiveVideo(from preferences: [String: CGRect], in geometry: GeometryProxy, proxy: ScrollViewProxy) {
        let screenCenterY = geometry.size.height / 2
        var closestId: String?
        var minDistance = CGFloat.infinity

        for (id, frame) in preferences {
            let visibleHeight = max(0, min(frame.maxY, geometry.size.height) - max(frame.minY, 0))
            if visibleHeight >= frame.height * scrollDetectionThreshold {
                let centerY = frame.midY
                let distance = abs(centerY - screenCenterY)
                if distance < minDistance {
                    minDistance = distance
                    closestId = id
                }
            }
        }

        if let newId = closestId, newId != activeVideoId {
            activeVideoId = newId
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(newId, anchor: .center)
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
