//
//  LibraryAlbumResponse.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 11/06/23.
//

import Foundation

struct LibraryAlbumResponse: Codable {
    let items: [SavedAlbums]
}

struct SavedAlbums: Codable {
    let added_at: String
    let album: Album
}
