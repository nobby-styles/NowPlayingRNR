import SwiftUI

// MARK: - Artist Profile View (With Image Header)
struct ArtistProfileView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Image (your design)
            headerImageSection
            
            // Track List Section
            trackListSection
        }
        .background(.black) // Background for track list area
        .navigationBarHidden(true) // Hide nav bar since it's in the image
    }
    
    private var headerImageSection: some View {
        // Replace "boy_pablo_header" with your actual image name
        Image("boy_pablo_header")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipped()
    }
    
    private var trackListSection: some View {
        VStack(spacing: 0) {
            // Songs section continues from image
            List {
                ForEach(Array(Track.mockTracks.enumerated()), id: \.element.id) { index, track in
                    TrackRowView(
                        track: track,
                        isCurrentTrack: track.id == viewModel.currentTrack.id,
                        isPlaying: viewModel.isPlaying && track.id == viewModel.currentTrack.id
                    ) {
                        viewModel.selectTrack(track)
                        if !viewModel.isPlaying {
                            viewModel.togglePlayPause()
                        }
                    }
                    .listRowBackground(Color.black)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(.black)
            
            // Space for mini player
            Spacer(minLength: 100)
        }
    }
}

// MARK: - Alternative with ScrollView (Better for integration)
struct ArtistProfileScrollView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Image
                Image("boy_pablo_header")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                
                // Track List in ScrollView
                LazyVStack(spacing: 0) {
                    ForEach(Array(Track.mockTracks.enumerated()), id: \.element.id) { index, track in
                        TrackRowView(
                            track: track,
                            isCurrentTrack: track.id == viewModel.currentTrack.id,
                            isPlaying: viewModel.isPlaying && track.id == viewModel.currentTrack.id
                        ) {
                            viewModel.selectTrack(track)
                            if !viewModel.isPlaying {
                                viewModel.togglePlayPause()
                            }
                        }
                        .background(.black)
                    }
                }
                
                // Space for mini player
                Spacer(minLength: 100)
            }
        }
        .background(.black)
        .navigationBarHidden(true)
    }
}

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
                                if !viewModel.isPlaying {
                                    viewModel.togglePlayPause()
                                }
                            }
                            .padding(.horizontal, 24)
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
                Color(red: 0.8, green: 0.6, blue: 0.3),
                Color(red: 0.7, green: 0.5, blue: 0.2)
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
#Preview("Simple") {
    ArtistProfileView(viewModel: MusicPlayerViewModel())
}

#Preview("ScrollView") {
    ArtistProfileScrollView(viewModel: MusicPlayerViewModel())
}

#Preview("With Transition") {
    ArtistProfileWithTransition(viewModel: MusicPlayerViewModel())
}