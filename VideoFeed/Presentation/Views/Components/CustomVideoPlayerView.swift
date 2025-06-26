//
//  CustomVideoPlayerView.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import SwiftUI
import AVKit

struct CustomVideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        controller.player = player
    }
}
