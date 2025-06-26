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
    @State private var player: AVPlayer?
    @State private var showRetryButton = false
    @State private var isFullVersion = false
    @State private var showLikeAnimation = false

    @State private var playerItemFailedObserver: AnyCancellable?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: video.creator.avatarURL) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                Text(video.creator.name)
                    .font(.headline)
                Spacer()
                Button("Follow") {
                    print("Follow Action")
                }
            }
            .padding(.horizontal)
            .padding(.top)

            ZStack(alignment: .bottomTrailing) {
                if showRetryButton {
                    VStack {
                        Text("Failed to load video")
                            .foregroundColor(.white)
                        Button("Retry") {
                            setupPlayer(url: isFullVersion ? video.fullVideoURL : video.shortVideoURL)
                            showRetryButton = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.7))
                } else {
                    VideoPlayer(player: player)
                        .aspectRatio(16/9, contentMode: .fit) // Video player will fit 16:9 ratio
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .onAppear {
                            setupPlayer(url: isFullVersion ? video.fullVideoURL : video.shortVideoURL)
                        }
                        .onDisappear {
                            // Clean up player resources when the view disappears
                            player?.pause()
                            player = nil
                            playerItemFailedObserver?.cancel()
                        }
                        .onChange(of: isActive) { _, newIsActive in
                            if newIsActive {
                                player?.play()
                            } else {
                                player?.pause()
                                player?.seek(to: .zero) // Reset video when not active
                            }
                        }
                        .overlay(alignment: .center) {
                            if showLikeAnimation {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.red)
                                    .scaleEffect(showLikeAnimation ? 1.5 : 0)
                                    .opacity(showLikeAnimation ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.5), value: showLikeAnimation)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            showLikeAnimation = false
                                        }
                                    }
                            }
                        }
                }
                
                Button(action: {
                    isFullVersion.toggle()
                    setupPlayer(url: isFullVersion ? video.fullVideoURL : video.shortVideoURL)
                }) {
                    Text(isFullVersion ? "Short" : "Full")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .onTapGesture(count: 2) {
                showLikeAnimation = true
            }

            HStack {
                Button { print("Like Action") } label: { Label("\(video.likes)", systemImage: "heart") }
                Button { print("Dislike Action") } label: { Label("", systemImage: "hand.thumbsdown") }
                Button { print("Comment Action") } label: { Label("\(video.comments)", systemImage: "bubble.left") }
                Spacer()
                Image(systemName: "square.and.arrow.up") // Share button
            }
            .font(.title2)
            .padding(.horizontal)
            .padding(.vertical, 5)

            // Video description (bottom)
            Text(video.description)
                .font(.body)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
    }

    private func setupPlayer(url: URL) {
        playerItemFailedObserver?.cancel()
        player = AVPlayer(url: url)
        player?.automaticallyWaitsToMinimizeStalling = false
        player?.currentItem?.preferredForwardBufferDuration = 1.0

        playerItemFailedObserver = NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: player?.currentItem)
            .sink { _ in
                showRetryButton = true
                player?.pause()
            }

        player?.seek(to: .zero)
        if isActive {
            player?.play()
        } else {
            player?.pause()
        }
    }
}
