//
//  Artists.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 07/04/23.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let images: [APIImage]?
    let external_urls: [String: String]
}
