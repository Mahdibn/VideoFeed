//
//  FetchVideosUseCase.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

protocol FetchVideosUseCase {
    func execute(page: Int) async throws -> [Video]
}
