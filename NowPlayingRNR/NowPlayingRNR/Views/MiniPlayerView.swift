import SwiftUI

// MARK: - Mini Player View (Fixed Layout)
struct MiniPlayerView: View {
@ObservedObject var viewModel: MusicPlayerViewModel

```
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
                
                Text(viewModel.currentTrack.artist)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .lineLimit(1)
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
        .padding(.vertical, 12)
        
        // Progress bar at the bottom (like Image 1)
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
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    .background {
        Rectangle()
            .fill(.black.opacity(0.95))
            .overlay {
                Rectangle()
                    .fill(.white.opacity(0.05))
            }
    }
    .onTapGesture {
        viewModel.expand()
    }
}
```

}