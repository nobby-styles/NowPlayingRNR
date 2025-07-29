//
//  TrackListView.swift
//  NowPlayingRNR
//
//  Created by Robert Redmond on 29/07/2025.
//


import SwiftUI

// MARK: - Track List View
struct TrackListView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(Track.mockTracks.enumerated()), id: \.element.id) { index, track in
                    TrackRowView(
                        track: track,
                        isCurrentTrack: track.id == viewModel.currentTrack.id,
                        isPlaying: viewModel.isPlaying && track.id == viewModel.currentTrack.id
                    ) {
                        // Select and play track
                        viewModel.selectTrack(track)
                        if !viewModel.isPlaying {
                            viewModel.togglePlayPause()
                        }
                    }
                }
            }
            .navigationTitle("Now Playing")
            .background(.black)
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: - Track Row View
struct TrackRowView: View {
    let track: Track
    let isCurrentTrack: Bool
    let isPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Album Art
            AsyncImage(url: URL(string: track.albumArt)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.gradient)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Track Info
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(track.artist)
                        .font(.system(size: 14))
                        .foregroundColor( .white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formatDuration(track.duration))
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // Pay or play button

            Button(action: onTap) {
                Image(systemName: isCurrentTrack && isPlaying  ? "pause.circle" : "play.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
            }

        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .background(isCurrentTrack ? Color.white.opacity(0.2) : .clear)

    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


// MARK: - Preview
#Preview("Standard") {
    TrackListView(viewModel: MusicPlayerViewModel())
        .preferredColorScheme(.dark)
}


