//
//  VideoCardViewModel.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import AVKit
import Combine

class VideoCardViewModel: ObservableObject {
    @Published var player: AVPlayer = AVPlayer()

    private var failureObserver: AnyCancellable?
    var onFailure: (() -> Void)?

    deinit {
        cleanup()
    }

    func setVideo(url: URL) {
        cleanup()
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)

        // Observe failure
        failureObserver = NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: item)
            .sink { [weak self] _ in
                self?.player.pause()
                self?.onFailure?()
            }

        // Loop
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: item,
                                               queue: .main) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func seekToStart() {
        player.seek(to: .zero)
    }

    func cleanup() {
        pause()
        failureObserver?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    func observeTime(update: @escaping (Double, Double) -> Void) {
        _ = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: 600), queue: .main) { [weak self] time in
            let current = time.seconds
            let total = self?.player.currentItem?.duration.seconds ?? 1
            update(current, total)
        }
    }
}
