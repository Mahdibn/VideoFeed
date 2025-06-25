//
//  VideosRepository.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

protocol VideosRepository {
    func fetchVideos(page: Int) async throws -> [Video]
}
