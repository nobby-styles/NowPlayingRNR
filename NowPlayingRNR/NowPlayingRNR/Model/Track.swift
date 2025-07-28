//
//  Track.swift
//  NowPlayingRNR
//
//  Created by Robert Redmond on 28/07/2025.
//


import Foundation

// MARK: - Track Model
struct Track: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String
    let albumArt: String
    let duration: TimeInterval
    let lyrics: [String]
    
    init(title: String, artist: String, albumArt: String, duration: TimeInterval, lyrics: [String] = []) {
        self.title = title
        self.artist = artist
        self.albumArt = albumArt
        self.duration = duration
        self.lyrics = lyrics.isEmpty ? Track.defaultLyrics : lyrics
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data
extension Track {
    static let defaultLyrics = [
        "Lyrics loading...",
        "Please wait a moment",
        "Music is playing",
        "Enjoy the song"
    ]
    
    static let mockTracks = [
        Track(
            title: "Feeling Lonely", 
            artist: "Soy Pablo", 
            albumArt: "album1", 
            duration: 218,
            lyrics: [
                "I woke up this morning",
                "Feeling so alone",
                "In this empty room",
                "Waiting by the phone",
                "The silence is deafening",
                "My heart feels so cold",
                "These feelings I'm having",
                "Are getting too old"
            ]
        ),
        Track(
            title: "Sick Feeling", 
            artist: "Soy Pablo", 
            albumArt: "album2", 
            duration: 195,
            lyrics: [
                "There's something inside me",
                "That doesn't feel right",
                "This sick feeling growing",
                "Throughout the night",
                "I can't shake this mood",
                "It's taking control",
                "This darkness consuming",
                "My heart and my soul"
            ]
        ),
        Track(
            title: "EvryTime", 
            artist: "Soy Pablo", 
            albumArt: "album3", 
            duration: 167,
            lyrics: [
                "Every time I see you",
                "My heart skips a beat",
                "Every time you're near me",
                "I feel so complete",
                "Every time we talk",
                "I lose track of time",
                "Every time you smile",
                "I know you're mine"
            ]
        ),
        Track(
            title: "Summer Nights", 
            artist: "Soy Pablo", 
            albumArt: "album4", 
            duration: 201,
            lyrics: [
                "Summer nights are calling",
                "The warm breeze feels so right",
                "Dancing under starlight",
                "Everything's so bright",
                "These moments last forever",
                "In my memory they'll stay",
                "Summer nights together",
                "Take my breath away"
            ]
        ),
        Track(
            title: "City Dreams", 
            artist: "Soy Pablo", 
            albumArt: "album5", 
            duration: 189,
            lyrics: [
                "Walking through the city",
                "Neon lights so bright",
                "Chasing all my dreams",
                "Through the endless night",
                "Streets are full of stories",
                "People passing by",
                "City Dreams and hopes",
                "Reaching for the sky"
            ]
        ),
        Track(
            title: "Midnight Drive",
            artist: "Soy Pablo",
            albumArt: "album6",
            duration: 233,
            lyrics: [
                "Driving through the midnight hour",
                "Radio playing soft and low",
                "City lights blur past my window",
                "Where this road leads, I don't know",
                "Freedom calls from every mile",
                "Stars above light up my way",
                "This midnight drive, this endless smile",
                "Could keep on going till the day"
            ]
        )
    ]
}