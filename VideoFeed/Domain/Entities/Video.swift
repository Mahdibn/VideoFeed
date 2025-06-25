//
//  Video.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

import Foundation

struct Video: Identifiable {
    let id: String
    let creator: Creator
    let shortVideoURL: URL
    let fullVideoURL: URL
    let description: String
    var likes: Int
    var comments: Int
    var isLiked: Bool = false
}
