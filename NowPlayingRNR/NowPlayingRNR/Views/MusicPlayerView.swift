//
//  MusicPlayerView.swift
//  NowPlayingRNR
//
//  Created by Robert Redmond on 28/07/2025.
//


import SwiftUI

// MARK: - Music Player Container View
struct MusicPlayerView: View {
    @StateObject private var viewModel = MusicPlayerViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background content
            Color.black.ignoresSafeArea()
            
            if viewModel.isExpanded {
                FullScreenPlayerView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))

            } else {
                MiniPlayerView(viewModel: viewModel)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}


// MARK: - Music Player State Manager
@MainActor
class MusicPlayerStateManager: ObservableObject {
    @Published var isPlayerVisible = false
    @Published var viewModel = MusicPlayerViewModel()
    
    func showPlayer() {
        isPlayerVisible = true
    }
    
    func hidePlayer() {
        if viewModel.isPlaying {
            viewModel.togglePlayPause()
        }
        isPlayerVisible = false
    }
    
    func playTrack(_ track: Track) {
        viewModel.selectTrack(track)
        if !viewModel.isPlaying {
            viewModel.togglePlayPause()
        }
        showPlayer()
    }
}



// MARK: - Preview
#Preview("Standard") {
    MusicPlayerView()
        .preferredColorScheme(.dark)
}

