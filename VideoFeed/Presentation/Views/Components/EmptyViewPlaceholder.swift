//
//  EmptyViewPlaceholder.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import SwiftUI

struct EmptyViewPlaceholder: View {
    var body: some View {
        Text("No videos available")
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
