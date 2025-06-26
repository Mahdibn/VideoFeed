//
//  VideoPlayerView.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let video: Video
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showRetryButton = false

    var body: some View {
        VStack {
            if showRetryButton {
                VStack {
                    Text("Failed to load video")
                    Button("Retry") {
                        setupPlayer(url: video.shortVideoURL)
                        showRetryButton = false
                    }
                }
            } else {
                VideoPlayer(player: player)
                    .onAppear {
                        setupPlayer(url: video.shortVideoURL)
                    }
                    .onDisappear {
                        player?.pause()
                        isPlaying = false
                    }
                    .onChange(of: isPlaying) { _, newIsPlaying in
                        if newIsPlaying {
                            player?.play()
                        } else {
                            player?.pause()
                        }
                    }
            }
        }
        .frame(height: 300)
        .onTapGesture(count: 2) {
            print("Double tapped for like!")
        }
    }

    private func setupPlayer(url: URL) {
        player = AVPlayer(url: url)
        player?.automaticallyWaitsToMinimizeStalling = false // To improve autoplay
        player?.currentItem?.preferredForwardBufferDuration = 1.0 // To reduce initial buffer
    }
}
