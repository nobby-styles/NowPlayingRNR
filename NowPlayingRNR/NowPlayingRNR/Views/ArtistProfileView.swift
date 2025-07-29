//
//  ArtistProfileView.swift
//  NowPlayingRNR
//
//  Created by Robert Redmond on 29/07/2025.
//


import SwiftUI


// MARK: - With Custom Background Transition
struct ArtistProfileWithTransition: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background gradient that extends through entire view
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Image
                    Image("boy_pablo_header")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                    
                    // Track List with gradient background
                    LazyVStack(spacing: 0) {
                        ForEach(Array(Track.mockTracks.enumerated()), id: \.element.id) { index, track in
                            TrackRowView(
                                track: track,
                                isCurrentTrack: track.id == viewModel.currentTrack.id,
                                isPlaying: viewModel.isPlaying && track.id == viewModel.currentTrack.id
                            ) {
                                viewModel.selectTrack(track)
                                viewModel.togglePlayPause()

                            }

                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
        .navigationBarHidden(true)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.85, blue: 0.6),
                Color(red: 0.9, green: 0.75, blue: 0.4),
                Color(red: 0.8, green: 0.7, blue: 0.3),
                Color(red: 0, green: 0, blue: 0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview("With Transition") {
    ArtistProfileWithTransition(viewModel: MusicPlayerViewModel())
}
