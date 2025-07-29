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

// MARK: - Music Player Container with Custom ViewModel
struct MusicPlayerContainerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
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

// MARK: - Music Player with Shared ViewModel Access
struct SharedMusicPlayerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @Binding var isVisible: Bool
    
    var body: some View {
        Group {
            if isVisible {
                ZStack(alignment: .bottom) {
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
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.isExpanded)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}

// MARK: - Music Player Overlay (For Integration)
struct MusicPlayerOverlay: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    let bottomPadding: CGFloat
    
    init(viewModel: MusicPlayerViewModel, bottomPadding: CGFloat = 0) {
        self.viewModel = viewModel
        self.bottomPadding = bottomPadding
    }
    
    var body: some View {
        ZStack {
            if viewModel.isExpanded {
                // Full screen player covers everything
                FullScreenPlayerView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .zIndex(2)
            } else {
                // Mini player at bottom
                VStack {
                    Spacer()
                    MiniPlayerView(viewModel: viewModel)
                        .padding(.bottom, bottomPadding)
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.isExpanded)
    }
}

// MARK: - Music Player with Custom Background
struct CustomBackgroundMusicPlayer: View {
    @StateObject private var viewModel = MusicPlayerViewModel()
    let backgroundColor: Color
    
    init(backgroundColor: Color = .black) {
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Custom background
            backgroundColor.ignoresSafeArea()
            
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

// MARK: - Music Player with State Management
struct StateManagedMusicPlayer: View {
    @StateObject private var stateManager = MusicPlayerStateManager()
    
    var body: some View {
        ZStack {
            SharedMusicPlayerView(
                viewModel: stateManager.viewModel,
                isVisible: $stateManager.isPlayerVisible
            )
        }
        .environmentObject(stateManager)
    }
}

// MARK: - Preview
#Preview("Standard") {
    MusicPlayerView()
        .preferredColorScheme(.dark)
}

#Preview("With Custom Background") {
    CustomBackgroundMusicPlayer(backgroundColor: .gray.opacity(0.1))
        .preferredColorScheme(.dark)
}

#Preview("State Managed") {
    StateManagedMusicPlayer()
        .preferredColorScheme(.dark)
}