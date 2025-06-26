//
//  VideoPlayerView.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    var isPlaying: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        if isPlaying {
            controller.player?.play()
        } else {
            controller.player?.pause()
        }
    }
}
