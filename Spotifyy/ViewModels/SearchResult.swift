//
//  SearchResult.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 08/06/23.
//

import Foundation

enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
