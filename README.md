# 🎵 NowPlayingRNR

A modern SwiftUI music player with smooth animations and gesture-driven interactions.

## Features

- **Mini Player** - Compact bottom overlay with progress bar
- **Full-Screen Player** - Immersive teal gradient interface
- **Track Selection** - Navigate between songs with next/previous
- **Artist Profile** - Golden gradient background with album display
- **Interactive Controls** - Drag-to-seek progress, tap-to-expand
- **Dynamic Lyrics** - Track-specific lyrics synced to playback
- **Smooth Animations** - Spring-based transitions throughout

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 6 compatible

## Installation

1. Clone the repository
1. Open `NowPlayingRNR.xcodeproj` in Xcode
1. Build and run

## Architecture

- **MVVM Pattern** with SwiftUI
- **Async/Await** for timer management
- **Reactive UI** with @Published properties
- **Memory efficient** with proper cleanup

## Project Structure

```
Models/          # Track data model
ViewModels/      # MusicPlayerViewModel business logic  
Views/           # SwiftUI components
Tests/           # Comprehensive unit tests
```

## Key Components

- `MiniPlayerView` - Bottom mini player
- `FullScreenPlayerView` - Full-screen experience
- `ArtistProfileView` - Artist page with gradient
- `TrackListView` - Track selection interface
- `MusicPlayerViewModel` - Core state management

## Usage

```swift
@StateObject private var musicPlayer = MusicPlayerViewModel()

// Basic controls
musicPlayer.togglePlayPause()
musicPlayer.nextTrack()
musicPlayer.selectTrack(someTrack)
```

## Testing

Run tests with `⌘U` in Xcode. Includes unit tests for:

- Playback functionality
- Track navigation
- State management

## License

MIT License

