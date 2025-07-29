//
//  MiniPlayerView.swift
//  NowPlayingRNR
//
//  Created by Robert Redmond on 29/07/2025.
//

import SwiftUI

// MARK: - Mini Player View 
struct MiniPlayerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Main player content
            HStack(spacing: 12) {
                // Album Art
                AsyncImage(url: URL(string: viewModel.currentTrack.albumArt)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.opacity(0.6))
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Track Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentTrack.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)

                    Text(viewModel.currentTrack.artist)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }

                Spacer()

                // Play/Pause Button - Large circular button like Image 1
                Button(action: viewModel.togglePlayPause) {
                    ZStack {
                        Circle()
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 44, height: 44)

                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .offset(x: viewModel.isPlaying ? 0 : 2) // Slight offset for play button visual balance
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Progress bar positioned at album art bottom, stretching to play button bottom
            HStack(alignment: .bottom, spacing: 12) {
                // Spacer for album art width
                Rectangle()
                    .fill(.clear)
                    .frame(width: 60, height: 1)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(height: 4)

                        // Progress fill
                        Rectangle()
                            .fill(.white)
                            .frame(width: max(0, geometry.size.width * viewModel.progressPercentage), height: 4)

                        // Scrubber handle
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                            .offset(x: max(0, geometry.size.width * viewModel.progressPercentage) - 6)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newTime = (value.location.x / geometry.size.width) * viewModel.currentTrack.duration
                                viewModel.seek(to: max(0, min(newTime, viewModel.currentTrack.duration)))
                            }
                    )
                }
                .frame(height: 12)

                // Spacer for play button width
                Rectangle()
                    .fill(.clear)
                    .frame(width: 44, height: 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(0.7))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.1))
                }
        }

        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            viewModel.expand()
        }
    }
}
