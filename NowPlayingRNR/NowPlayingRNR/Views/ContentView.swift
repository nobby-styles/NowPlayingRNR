import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var musicPlayerViewModel = MusicPlayerViewModel()
    
    var body: some View {
        TabView {
            // Track Library Tab
            TrackListView(viewModel: musicPlayerViewModel)
                .tabItem {
                    Label("Library", systemImage: "music.note.list")
                }
            
            // Browse Tab (Demo content)
            browseView
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
            
            // Profile Tab (Demo content)
            profileView
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .overlay(alignment: .bottom) {
            // Music Player Overlay - shows above all tabs
            if !musicPlayerViewModel.isExpanded {
                MiniPlayerView(viewModel: musicPlayerViewModel)
                    .padding(.bottom, 49) // Account for tab bar height
            }
        }
        .overlay {
            // Full screen player overlay
            if musicPlayerViewModel.isExpanded {
                FullScreenPlayerView(viewModel: musicPlayerViewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Demo Browse View
    private var browseView: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Featured section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Featured Albums")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(0..<5) { index in
                                    VStack(alignment: .leading, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.gray.gradient)
                                            .frame(width: 160, height: 160)
                                        
                                        Text("Album \(index + 1)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("Artist Name")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 160)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Recently played section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recently Played")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(Track.mockTracks.prefix(3), id: \.id) { track in
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.gray.gradient)
                                        .frame(width: 50, height: 50)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(track.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text(track.artist)
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        musicPlayerViewModel.selectTrack(track)
                                        if !musicPlayerViewModel.isPlaying {
                                            musicPlayerViewModel.togglePlayPause()
                                        }
                                    } label: {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .onTapGesture {
                                    musicPlayerViewModel.selectTrack(track)
                                    if !musicPlayerViewModel.isPlaying {
                                        musicPlayerViewModel.togglePlayPause()
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 100) // Space for mini player
                }
            }
            .background(.black)
            .navigationTitle("Browse")
        }
    }
    
    // MARK: - Demo Profile View
    private var profileView: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profile header
                VStack(spacing: 16) {
                    Circle()
                        .fill(.gray.gradient)
                        .frame(width: 100, height: 100)
                    
                    Text("Music Lover")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text("Enjoying Soy Pablo's latest tracks")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // Stats section
                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        Text("\(Track.mockTracks.count)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("Songs")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Text("42")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("Hours")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Text("1")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("Artist")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Quick actions
                VStack(spacing: 16) {
                    Button("Shuffle All Songs") {
                        if let randomTrack = Track.mockTracks.randomElement() {
                            musicPlayerViewModel.selectTrack(randomTrack)
                            if !musicPlayerViewModel.isPlaying {
                                musicPlayerViewModel.togglePlayPause()
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 32)
                    
                    Button("View All Tracks") {
                        // Switch to library tab
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                Spacer(minLength: 100) // Space for mini player
            }
            .background(.black)
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Alternative Simple Content View
struct SimpleContentView: View {
    var body: some View {
        ZStack {
            // Main app content
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(0..<20) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.2))
                            .frame(height: 100)
                            .overlay {
                                Text("Content Item \(index + 1)")
                                    .foregroundColor(.white)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 80) // Account for mini player
            }
            .background(.black)
            
            // Music Player Overlay
            MusicPlayerView()
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

#Preview("Simple") {
    SimpleContentView()
        .preferredColorScheme(.dark)
}