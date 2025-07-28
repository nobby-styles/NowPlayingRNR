//
//  MusicPlayerViewModelTests.swift
//  NowPlayingRNR
//
//  Created by Robert Redmond on 28/07/2025.
//


import XCTest
import SwiftUI
@testable import NowPlayingRNR

@MainActor
final class MusicPlayerViewModelTests: XCTestCase {
    
    var viewModel: MusicPlayerViewModel!
    var mockTrack: Track!
    var mockPlaylist: [Track]!
    
    override func setUp() {
        super.setUp()
        mockTrack = Track(title: "Test Song", artist: "Test Artist", albumArt: "test_album", duration: 180)
        mockPlaylist = [
            Track(title: "Song 1", artist: "Artist 1", albumArt: "album1", duration: 120),
            Track(title: "Song 2", artist: "Artist 2", albumArt: "album2", duration: 150),
            Track(title: "Song 3", artist: "Artist 3", albumArt: "album3", duration: 180)
        ]
        viewModel = MusicPlayerViewModel(track: mockPlaylist[0], playlist: mockPlaylist)
    }
    
    override func tearDown() {
        // Ensure playback is stopped before cleanup
        if viewModel.isPlaying {
            viewModel.togglePlayPause()
        }
        viewModel = nil
        mockTrack = nil
        mockPlaylist = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(viewModel.currentTrack.title, mockPlaylist[0].title)
        XCTAssertEqual(viewModel.currentTrack.artist, mockPlaylist[0].artist)
        XCTAssertEqual(viewModel.currentTrack.duration, mockPlaylist[0].duration)
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertFalse(viewModel.isExpanded)
        XCTAssertEqual(viewModel.currentTime, 0)
        XCTAssertEqual(viewModel.currentTrackIndex, 0)
        XCTAssertEqual(viewModel.playlistCount, 3)
        XCTAssertNotNil(viewModel.currentLyric)
    }
    
    func testInitializationWithSpecificTrack() {
        let specificTrack = mockPlaylist[1] // Second track
        let customViewModel = MusicPlayerViewModel(track: specificTrack, playlist: mockPlaylist)
        
        XCTAssertEqual(customViewModel.currentTrack.id, specificTrack.id)
        XCTAssertEqual(customViewModel.currentTrackIndex, 1)
        
        // Clean up
        if customViewModel.isPlaying {
            customViewModel.togglePlayPause()
        }
    }
    
    func testInitializationWithDefaultTrack() {
        let defaultViewModel = MusicPlayerViewModel()
        XCTAssertEqual(defaultViewModel.currentTrack.title, Track.mockTracks[0].title)
        XCTAssertEqual(defaultViewModel.currentTrack.artist, Track.mockTracks[0].artist)
        XCTAssertEqual(defaultViewModel.currentTrackIndex, 0)
        
        // Clean up
        if defaultViewModel.isPlaying {
            defaultViewModel.togglePlayPause()
        }
    }
    
    // MARK: - Playlist State Tests
    
    func testPlaylistStateProperties() {
        // At first track
        XCTAssertEqual(viewModel.currentTrackIndex, 0)
        XCTAssertFalse(viewModel.hasPreviousTrack)
        XCTAssertTrue(viewModel.hasNextTrack)
        XCTAssertEqual(viewModel.playlistCount, 3)
        
        // Move to middle track
        viewModel.selectTrack(at: 1)
        XCTAssertEqual(viewModel.currentTrackIndex, 1)
        XCTAssertTrue(viewModel.hasPreviousTrack)
        XCTAssertTrue(viewModel.hasNextTrack)
        
        // Move to last track
        viewModel.selectTrack(at: 2)
        XCTAssertEqual(viewModel.currentTrackIndex, 2)
        XCTAssertTrue(viewModel.hasPreviousTrack)
        XCTAssertFalse(viewModel.hasNextTrack)
    }
    
    // MARK: - Track Selection Tests
    
    func testSelectTrackByObject() {
        let targetTrack = mockPlaylist[2]
        let wasPlaying = viewModel.isPlaying
        
        viewModel.selectTrack(targetTrack)
        
        XCTAssertEqual(viewModel.currentTrack.id, targetTrack.id)
        XCTAssertEqual(viewModel.currentTrackIndex, 2)
        XCTAssertEqual(viewModel.currentTime, 0, "Time should reset when selecting new track")
        XCTAssertEqual(viewModel.isPlaying, wasPlaying, "Playing state should be preserved")
    }
    
    func testSelectTrackByIndex() {
        viewModel.selectTrack(at: 1)
        
        XCTAssertEqual(viewModel.currentTrackIndex, 1)
        XCTAssertEqual(viewModel.currentTrack.id, mockPlaylist[1].id)
        XCTAssertEqual(viewModel.currentTime, 0)
    }
    
    func testSelectTrackWithInvalidIndex() {
        let originalTrack = viewModel.currentTrack
        let originalIndex = viewModel.currentTrackIndex
        
        // Test negative index
        viewModel.selectTrack(at: -1)
        XCTAssertEqual(viewModel.currentTrack.id, originalTrack.id)
        XCTAssertEqual(viewModel.currentTrackIndex, originalIndex)
        
        // Test index beyond playlist
        viewModel.selectTrack(at: 99)
        XCTAssertEqual(viewModel.currentTrack.id, originalTrack.id)
        XCTAssertEqual(viewModel.currentTrackIndex, originalIndex)
    }
    
    func testSelectTrackPreservesPlaybackState() async {
        // Start playing
        viewModel.togglePlayPause()
        XCTAssertTrue(viewModel.isPlaying)
        
        // Select new track
        viewModel.selectTrack(at: 1)
        
        XCTAssertTrue(viewModel.isPlaying, "Should continue playing after track selection")
        XCTAssertEqual(viewModel.currentTime, 0, "Time should reset to 0")
        
        // Wait to verify playback continues
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        XCTAssertGreaterThan(viewModel.currentTime, 0, "Time should progress in new track")
        
        // Clean up
        viewModel.togglePlayPause()
    }
    
    // MARK: - Track Navigation Tests
    
    func testNextTrack() {
        // From first track
        viewModel.nextTrack()
        XCTAssertEqual(viewModel.currentTrackIndex, 1)
        XCTAssertEqual(viewModel.currentTrack.id, mockPlaylist[1].id)
        
        // From middle track
        viewModel.nextTrack()
        XCTAssertEqual(viewModel.currentTrackIndex, 2)
        XCTAssertEqual(viewModel.currentTrack.id, mockPlaylist[2].id)
        
        // From last track (should wrap to first)
        viewModel.nextTrack()
        XCTAssertEqual(viewModel.currentTrackIndex, 0)
        XCTAssertEqual(viewModel.currentTrack.id, mockPlaylist[0].id)
    }
    
    func testPreviousTrack() {
        // Start at first track, should wrap to last
        viewModel.previousTrack()
        XCTAssertEqual(viewModel.currentTrackIndex, 2)
        XCTAssertEqual(viewModel.currentTrack.id, mockPlaylist[2].id)
        
        // From last track to middle
        viewModel.previousTrack()
        XCTAssertEqual(viewModel.currentTrackIndex, 1)
        XCTAssertEqual(viewModel.currentTrack.id, mockPlaylist[1].id)
        
        // From middle to first
        viewModel.previousTrack()
        XCTAssertEqual(viewModel.currentTrackIndex, 0)
        XCTAssertEqual(viewModel.currentTrack.id, mockPlaylist[0].id)
    }
    
    func testNavigationPreservesPlaybackState() async {
        viewModel.togglePlayPause()
        XCTAssertTrue(viewModel.isPlaying)
        
        viewModel.nextTrack()
        XCTAssertTrue(viewModel.isPlaying, "Should continue playing after next track")
        XCTAssertEqual(viewModel.currentTime, 0, "Time should reset")
        
        // Wait to verify playback continues
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        XCTAssertGreaterThan(viewModel.currentTime, 0)
        
        viewModel.previousTrack()
        XCTAssertTrue(viewModel.isPlaying, "Should continue playing after previous track")
        XCTAssertEqual(viewModel.currentTime, 0, "Time should reset again")
        
        // Clean up
        viewModel.togglePlayPause()
    }
    
    // MARK: - Play/Pause Tests
    
    func testTogglePlayPause() {
        XCTAssertFalse(viewModel.isPlaying)
        
        viewModel.togglePlayPause()
        XCTAssertTrue(viewModel.isPlaying)
        
        viewModel.togglePlayPause()
        XCTAssertFalse(viewModel.isPlaying)
    }
    
    func testPlayingUpdatesTime() async {
        let initialTime = viewModel.currentTime
        
        viewModel.togglePlayPause()
        XCTAssertTrue(viewModel.isPlaying)
        
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        XCTAssertGreaterThan(viewModel.currentTime, initialTime)
        
        viewModel.togglePlayPause()
    }
    
    func testPausingStopsTimeUpdate() async {
        viewModel.togglePlayPause()
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        let timeWhenPaused = viewModel.currentTime
        viewModel.togglePlayPause()
        
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        let timeDifference = abs(viewModel.currentTime - timeWhenPaused)
        XCTAssertLessThan(timeDifference, 1.0, "Time should not progress after pausing")
    }
    
    // MARK: - Seek Tests
    
    func testSeekToTime() {
        let seekTime: TimeInterval = 90
        viewModel.seek(to: seekTime)
        XCTAssertEqual(viewModel.currentTime, seekTime)
    }
    
    func testSeekWithBoundsChecking() {
        // Test seeking to negative time
        viewModel.seek(to: -10)
        XCTAssertEqual(viewModel.currentTime, 0)
        
        // Test seeking beyond track duration
        viewModel.seek(to: viewModel.currentTrack.duration + 100)
        XCTAssertEqual(viewModel.currentTime, viewModel.currentTrack.duration)
    }
    
    func testSeekUpdatesLyrics() {

        viewModel.seek(to: 60) // 1 minute
        let seekLyric = viewModel.currentLyric
        
        XCTAssertNotNil(seekLyric)
        XCTAssertFalse(seekLyric.isEmpty)
    }
    
    // MARK: - Expand/Collapse Tests
    
    func testExpand() {
        XCTAssertFalse(viewModel.isExpanded)
        viewModel.expand()
        XCTAssertTrue(viewModel.isExpanded)
    }
    
    func testCollapse() {
        viewModel.expand()
        XCTAssertTrue(viewModel.isExpanded)
        
        viewModel.collapse()
        XCTAssertFalse(viewModel.isExpanded)
    }
    
    func testExpandCollapseDoesNotAffectPlayback() async {
        viewModel.togglePlayPause()
        XCTAssertTrue(viewModel.isPlaying)
        
        viewModel.expand()
        XCTAssertTrue(viewModel.isExpanded)
        XCTAssertTrue(viewModel.isPlaying)
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        viewModel.collapse()
        XCTAssertFalse(viewModel.isExpanded)
        XCTAssertTrue(viewModel.isPlaying)
        
        viewModel.togglePlayPause()
    }
    
    // MARK: - Lyrics Tests
    
    func testLyricsUpdateBasedOnTime() {
        viewModel.seek(to: 0)
        let lyricAt0 = viewModel.currentLyric
        
        viewModel.seek(to: 30)
        let lyricAt30 = viewModel.currentLyric
        
        viewModel.seek(to: 60)
        let lyricAt60 = viewModel.currentLyric
        
        // All lyrics should be valid
        XCTAssertFalse(lyricAt0.isEmpty)
        XCTAssertFalse(lyricAt30.isEmpty)
        XCTAssertFalse(lyricAt60.isEmpty)
    }
    
    func testLyricsChangeWithTracks() {

        viewModel.selectTrack(at: 1)
        let secondTrackLyric = viewModel.currentLyric
        
        // Lyrics should be updated for new track
        XCTAssertNotNil(secondTrackLyric)
        XCTAssertFalse(secondTrackLyric.isEmpty)
    }
    
    // MARK: - Track End Behavior Tests
    
    func testPlaybackStopsAtTrackEnd() async {
        // Create short track for faster testing
        let shortTrack = Track(title: "Short", artist: "Test", albumArt: "test", duration: 2)
        let shortPlaylist = [shortTrack]
        let shortViewModel = MusicPlayerViewModel(track: shortTrack, playlist: shortPlaylist)
        
        shortViewModel.seek(to: 1.5) // Close to end
        shortViewModel.togglePlayPause()
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        XCTAssertFalse(shortViewModel.isPlaying, "Should auto-stop at track end")
        XCTAssertLessThanOrEqual(shortViewModel.currentTime, shortTrack.duration + 0.1)
        
        if shortViewModel.isPlaying {
            shortViewModel.togglePlayPause()
        }
    }
    
    // MARK: - Integration Tests
    
    func testFullPlaybackCycle() async {
        let seekTime: TimeInterval = 30
        
        viewModel.seek(to: seekTime)
        XCTAssertEqual(viewModel.currentTime, seekTime)
        
        viewModel.togglePlayPause()
        XCTAssertTrue(viewModel.isPlaying)
        
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        XCTAssertGreaterThan(viewModel.currentTime, seekTime)
        
        viewModel.togglePlayPause()
        XCTAssertFalse(viewModel.isPlaying)
        
        let pausedTime = viewModel.currentTime
        
        viewModel.expand()
        XCTAssertTrue(viewModel.isExpanded)
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        let timeDifference = abs(viewModel.currentTime - pausedTime)
        XCTAssertLessThan(timeDifference, 1.0)
        
        viewModel.collapse()
        XCTAssertFalse(viewModel.isExpanded)
    }
    
    func testPlaylistNavigation() async {
        viewModel.togglePlayPause()
        
        // Navigate through entire playlist
        for expectedIndex in 1..<mockPlaylist.count {
            viewModel.nextTrack()
            XCTAssertEqual(viewModel.currentTrackIndex, expectedIndex)
            XCTAssertTrue(viewModel.isPlaying, "Should continue playing during navigation")
            XCTAssertEqual(viewModel.currentTime, 0, "Should reset time for each track")
        }
        
        // Navigate backwards
        for expectedIndex in (0..<mockPlaylist.count-1).reversed() {
            viewModel.previousTrack()
            XCTAssertEqual(viewModel.currentTrackIndex, expectedIndex)
            XCTAssertTrue(viewModel.isPlaying)
            XCTAssertEqual(viewModel.currentTime, 0)
        }
        
        viewModel.togglePlayPause()
    }
    
    // MARK: - Concurrent Operations Tests
    
    func testRapidTrackSwitching() {
        for i in 0..<10 {
            let trackIndex = i % mockPlaylist.count
            viewModel.selectTrack(at: trackIndex)
            XCTAssertEqual(viewModel.currentTrackIndex, trackIndex)
            XCTAssertEqual(viewModel.currentTime, 0)
        }
    }
    
    func testSeekWhilePlaying() async {
        viewModel.togglePlayPause()
        
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        let seekTime: TimeInterval = 60
        viewModel.seek(to: seekTime)
        XCTAssertEqual(viewModel.currentTime, seekTime)
        XCTAssertTrue(viewModel.isPlaying)
        
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        XCTAssertGreaterThan(viewModel.currentTime, seekTime)
        
        viewModel.togglePlayPause()
    }
    

    // MARK: - Memory and Cleanup Tests
    
    func testViewModelDeallocation() async {
        var testViewModel: MusicPlayerViewModel? = MusicPlayerViewModel(track: mockPlaylist[0], playlist: mockPlaylist)
        
        testViewModel?.togglePlayPause()
        weak var weakViewModel = testViewModel
        
        testViewModel = nil
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated")
    }
    
    // MARK: - Edge Cases
    
    func testSingleTrackPlaylist() {
        let singleTrack = [mockPlaylist[0]]
        let singleTrackViewModel = MusicPlayerViewModel(track: singleTrack[0], playlist: singleTrack)
        
        XCTAssertEqual(singleTrackViewModel.playlistCount, 1)
        XCTAssertFalse(singleTrackViewModel.hasNextTrack)
        XCTAssertFalse(singleTrackViewModel.hasPreviousTrack)
        
        // Navigation should wrap around
        singleTrackViewModel.nextTrack()
        XCTAssertEqual(singleTrackViewModel.currentTrackIndex, 0)
        
        singleTrackViewModel.previousTrack()
        XCTAssertEqual(singleTrackViewModel.currentTrackIndex, 0)
        
        if singleTrackViewModel.isPlaying {
            singleTrackViewModel.togglePlayPause()
        }
    }
    
    func testEmptyPlaylist() {
        // This should not crash - defensive programming test
        let emptyPlaylist: [Track] = []
        let emptyViewModel = MusicPlayerViewModel(track: Track.mockTracks[0], playlist: emptyPlaylist)
        
        XCTAssertEqual(emptyViewModel.playlistCount, 0)
        XCTAssertFalse(emptyViewModel.hasNextTrack)
        XCTAssertFalse(emptyViewModel.hasPreviousTrack)
        
        if emptyViewModel.isPlaying {
            emptyViewModel.togglePlayPause()
        }
    }
}
