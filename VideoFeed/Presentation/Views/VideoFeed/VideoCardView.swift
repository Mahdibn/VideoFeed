//
//  VideoCardView.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import SwiftUI
import AVKit
import Combine

struct VideoCardView: View {
    let video: Video
    @Binding var isActive: Bool

    @State private var showRetryButton = false
    @State private var isFullVersion = false
    @State private var showLikeAnimation = false
    @StateObject private var viewModel = VideoCardViewModel()

    @State private var isPlaying = true
    @State private var isFullscreen = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Creator
            HStack {
                AsyncImage(url: video.creator.avatarURL) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                Text(video.creator.name).font(.headline)
                Spacer()
                Button("Follow") { print("Follow") }
            }
            .padding([.horizontal, .top])

            // Video Section
            ZStack(alignment: .bottomTrailing) {
                if showRetryButton {
                    VStack {
                        Text("Failed to load video")
                            .foregroundColor(.white)
                        Button("Retry") {
                            setupPlayer()
                            showRetryButton = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.7))
                } else {
                    VStack {
                        CustomVideoPlayerView(player: viewModel.player)
                            .aspectRatio(10/16, contentMode: .fit)
                            .onAppear {
                                setupPlayer()
                                observeTime()
                            }
                            .onDisappear {
                                viewModel.cleanup()
                            }
                            .onChange(of: isActive) { _, newValue in
                                if newValue {
                                    viewModel.play()
                                } else {
                                    viewModel.pause()
                                    viewModel.seekToStart()
                                }
                            }
                            .overlay(overlayControls, alignment: .bottom)
                            .overlay(likeHeart, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                }

                // Toggle short/full
                Button(action: {
                    isFullVersion.toggle()
                    setupPlayer()
                }) {
                    Text(isFullVersion ? "Short" : "Full")
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .onTapGesture(count: 2) {
                showLikeAnimation = true
            }

            // Action buttons
            HStack(spacing: 16) {
                Button(action: { print("Like") }) {
                    Label("\(video.likes)", systemImage: "heart")
                }
                Button(action: { print("Dislike") }) {
                    Image(systemName: "hand.thumbsdown")
                }
                Button(action: { print("Comment") }) {
                    Label("\(video.comments)", systemImage: "bubble.left")
                }
                Spacer()
                Button(action: { print("Share") }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .padding([.horizontal, .vertical], 10)

            // Description
            Text(video.description)
                .font(.body)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
    }

    // MARK: - Custom Controls Overlay
    private var overlayControls: some View {
        Group {
            if isFullVersion {
                VStack(spacing: 8) {
                    if duration > 0 {
                        // Prevent invalid range
                        Slider(value: $currentTime, in: 0...max(duration, currentTime), onEditingChanged: { editing in
                            if !editing {
                                let seekTime = CMTime(seconds: currentTime, preferredTimescale: 600)
                                viewModel.player.seek(to: seekTime)
                            }
                        })
                    }

                    HStack {
                        Button {
                            isPlaying.toggle()
                            isPlaying ? viewModel.play() : viewModel.pause()
                        } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        }

                        Spacer()

                        Button {
                            isFullscreen.toggle()
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                        }
                    }
                    .padding(.horizontal)
                    .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.5))
            }
        }
    }

    private var likeHeart: some View {
        Group {
            if showLikeAnimation {
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .scaleEffect(1.5)
                    .opacity(1)
                    .transition(.scale)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showLikeAnimation = false
                        }
                    }
            }
        }
    }

    private func setupPlayer() {
        let url = isFullVersion ? video.fullVideoURL : video.shortVideoURL
        viewModel.setVideo(url: url)
        viewModel.onFailure = { showRetryButton = true }
        if isActive { viewModel.play() }
    }

    private func observeTime() {
        viewModel.observeTime { time, total in
            currentTime = time
            duration = total
        }
    }
}
