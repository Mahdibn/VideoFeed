//
//  Video.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 25.06.25.
//

import Foundation

struct Video: Identifiable, Equatable {
    let id: String
    let creator: Creator
    let shortVideoURL: URL
    let fullVideoURL: URL
    let description: String
    let likes: Int
    let comments: Int

    static func == (lhs: Video, rhs: Video) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
