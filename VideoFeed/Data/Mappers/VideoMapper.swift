//
//  VideoMapper.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

import Foundation

enum VideoMapper {
    // TODO: Consider using Optional for better safety in the real app
    static func map(dto: VideoDTO) -> Video {
        Video(
            id: dto.id,
            creator: Creator(
                id: dto.creator.id,
                name: dto.creator.name,
                avatarURL: URL(string: dto.creator.avatarURL)!
            ),
            shortVideoURL: URL(string: dto.shortVideoURL)!,
            fullVideoURL: URL(string: dto.fullVideoURL)!,
            description: dto.description,
            likes: dto.likes,
            comments: dto.comments
        )
    }
}
