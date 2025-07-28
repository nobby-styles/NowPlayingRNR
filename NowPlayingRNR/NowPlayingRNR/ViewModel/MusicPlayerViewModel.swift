//
//  MusicPlayerViewModel.swift
//  NowPlayingRNR
//
//  Created by Robert Redmond on 28/07/2025.
//


import SwiftUI
import Combine

// MARK: - Music Player ViewModel
@MainActor
class MusicPlayerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentTrack: Track
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var isExpanded = false
    @Published var currentLyric = ""
    @Published var currentTrackIndex = 0
    
    // MARK: - Private Properties
    private var playbackTask: Task<Void, Never>?
    private let playlist: [Track]
    
    // MARK: - Initialization
    init(track: Track = Track.mockTracks[0], playlist: [Track] = Track.mockTracks) {
        self.playlist = playlist
        self.currentTrack = track
        self.currentTrackIndex = playlist.firstIndex(where: { $0.id == track.id }) ?? 0
        updateLyrics()
    }
    
    // MARK: - Playback Control Methods
    func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            startAsyncTimer()
        } else {
            stopAsyncTimer()
        }
    }
    
    func seek(to time: TimeInterval) {
        currentTime = max(0, min(time, currentTrack.duration))
        updateLyrics()
    }
    
    // MARK: - UI State Methods
    func expand() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isExpanded = true
        }
    }
    
    func collapse() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isExpanded = false
        }
    }
    
    // MARK: - Track Selection Methods
    func selectTrack(_ track: Track) {
        guard let index = playlist.firstIndex(where: { $0.id == track.id }) else { return }
        selectTrack(at: index)
    }
    
    func selectTrack(at index: Int) {
        guard index >= 0 && index < playlist.count else { return }
        
        let wasPlaying = isPlaying
        
        // Stop current playback
        if isPlaying {
            stopAsyncTimer()
            isPlaying = false
        }
        
        // Update track and reset state
        currentTrackIndex = index
        currentTrack = playlist[index]
        currentTime = 0
        updateLyrics()
        
        // Resume playback if it was playing
        if wasPlaying {
            isPlaying = true
            startAsyncTimer()
        }
    }
    
    // MARK: - Track Navigation Methods
    func nextTrack() {
        let nextIndex = (currentTrackIndex + 1) % playlist.count
        selectTrack(at: nextIndex)
    }
    
    func previousTrack() {
        let previousIndex = currentTrackIndex == 0 ? playlist.count - 1 : currentTrackIndex - 1
        selectTrack(at: previousIndex)
    }
    
    // MARK: - Computed Properties
    var hasNextTrack: Bool {
        currentTrackIndex < playlist.count - 1
    }
    
    var hasPreviousTrack: Bool {
        currentTrackIndex > 0
    }
    
    var playlistCount: Int {
        playlist.count
    }
    
    var progressPercentage: Double {
        guard currentTrack.duration > 0 else { return 0 }
        return currentTime / currentTrack.duration
    }
    
    // MARK: - Private Timer Methods
    private func startAsyncTimer() {
        playbackTask?.cancel()
        
        playbackTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }
                
                guard await self.shouldContinuePlayback() else { break }
                
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                self.updatePlaybackTime()
            }
        }
    }
    
    private func stopAsyncTimer() {
        playbackTask?.cancel()
        playbackTask = nil
    }
    
    private func shouldContinuePlayback() async -> Bool {
        return isPlaying && currentTime < currentTrack.duration
    }
    
    private func updatePlaybackTime() {
        guard isPlaying && currentTime < currentTrack.duration else {
            if currentTime >= currentTrack.duration {
                handleTrackEnd()
            }
            return
        }
        
        currentTime = min(currentTime + 1, currentTrack.duration)
        updateLyrics()
        
        if currentTime >= currentTrack.duration {
            handleTrackEnd()
        }
    }
    
    private func handleTrackEnd() {
        isPlaying = false
        stopAsyncTimer()
    }
    
    // MARK: - Lyrics Management
    private func updateLyrics() {
        let lyrics = currentTrack.lyrics
        guard !lyrics.isEmpty else {
            currentLyric = "No lyrics available"
            return
        }
        
        // Calculate lyric index based on time (roughly one lyric per 30 seconds)
        let lyricIndex = min(Int(currentTime / 30), lyrics.count - 1)
        currentLyric = lyrics[lyricIndex]
    }
    
    // MARK: - Utility Methods
    func formattedCurrentTime() -> String {
        formatTime(currentTime)
    }
    
    func formattedDuration() -> String {
        formatTime(currentTrack.duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Debug Methods
    #if DEBUG
    func simulateTrackEnd() {
        currentTime = currentTrack.duration
        handleTrackEnd()
    }
    
    func printPlaylistInfo() {
        print("=== Playlist Info ===")
        print("Current track: \(currentTrack.title) by \(currentTrack.artist)")
        print("Track \(currentTrackIndex + 1) of \(playlist.count)")
        print("Playing: \(isPlaying)")
        print("Time: \(formattedCurrentTime()) / \(formattedDuration())")
        print("Lyrics: \(currentLyric)")
        print("==================")
    }
    #endif
    
    // MARK: - Cleanup
    deinit {
        playbackTask?.cancel()
    }
}
