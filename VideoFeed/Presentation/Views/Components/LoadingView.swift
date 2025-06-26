//
//  LoadingView.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView("Loading Videos…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
