import SwiftUI

// MARK: - Full Screen Player View
struct FullScreenPlayerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Bar
                topBar
                
                Spacer()
                
                // Album Art
                albumArtSection
                
                Spacer()
                
                // Track Info
                trackInfoSection
                
                // Action Buttons (Heart & Share)
                actionButtonsSection
                
                // Progress Bar
                progressSection
                
                // Controls
                controlsSection
                
                // Lyrics Section
                lyricsSection
                
                Spacer(minLength: 34) // Account for home indicator
            }
            .padding(.horizontal, 24)
            .background {
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.6, blue: 0.8),
                        Color(red: 0.1, green: 0.4, blue: 0.7),
                        Color(red: 0.05, green: 0.2, blue: 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            .offset(y: dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 100 {
                            viewModel.collapse()
                        }
                        dragOffset = .zero
                    }
            )
        }
        .ignoresSafeArea()
    }
    
    // MARK: - View Components
    private var topBar: some View {
        HStack {
            Button(action: viewModel.collapse) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Now playing")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {} label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var albumArtSection: some View {
        AsyncImage(url: URL(string: viewModel.currentTrack.albumArt)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.2))
        }
        .frame(width: 280, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
    }
    
    private var trackInfoSection: some View {
        VStack(spacing: 6) {
            Text(viewModel.currentTrack.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(viewModel.currentTrack.artist)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 60) {
            Button {} label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            Button {} label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
    }
    
    private var progressSection: some View {
        VStack(spacing: 8) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.3))
                        .frame(height: 4)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white)
                        .frame(width: max(0, geometry.size.width * viewModel.progressPercentage), height: 4)
                    
                    // Scrubber Handle
                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .offset(x: max(0, geometry.size.width * viewModel.progressPercentage) - 8)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newTime = (value.location.x / geometry.size.width) * viewModel.currentTrack.duration
                            viewModel.seek(to: max(0, min(newTime, viewModel.currentTrack.duration)))
                        }
                )
            }
            .frame(height: 16)
            
            // Time Labels
            HStack {
                Text(viewModel.formattedCurrentTime())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(viewModel.formattedDuration())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.vertical, 15)
    }
    
    private var controlsSection: some View {
        HStack(spacing: 0) {
            // Shuffle
            Button {} label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            
            // Previous
            Button(action: viewModel.previousTrack) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 28))
                    .foregroundColor(viewModel.hasPreviousTrack ? .white : .white.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
            .disabled(!viewModel.hasPreviousTrack)
            
            // Play/Pause (Large circular button)
            Button(action: viewModel.togglePlayPause) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.black)
                        .offset(x: viewModel.isPlaying ? 0 : 2) // Slight offset for play button visual balance
                }
            }
            .scaleEffect(viewModel.isPlaying ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: viewModel.isPlaying)
            .frame(maxWidth: .infinity)
            
            // Next
            Button(action: viewModel.nextTrack) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 28))
                    .foregroundColor(viewModel.hasNextTrack ? .white : .white.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
            .disabled(!viewModel.hasNextTrack)
            
            // Repeat
            Button {} label: {
                Image(systemName: "repeat")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20)
    }
    
    private var lyricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lyrics")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.3, green: 0.7, blue: 0.9))
                .frame(height: 50)
                .overlay(alignment: .leading) {
                    Text(viewModel.currentLyric)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }
}