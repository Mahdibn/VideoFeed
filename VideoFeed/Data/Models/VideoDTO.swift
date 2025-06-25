//
//  VideoDTO.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

import Foundation

struct VideoDTO: Decodable {
    let id: String
    let creator: CreatorDTO
    let shortVideoURL: String
    let fullVideoURL: String
    let description: String
    let likes: Int
    let comments: Int
}
