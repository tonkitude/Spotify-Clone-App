//
//  UserProfile.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 07/04/23.
//

import Foundation

struct UserProfile: Codable {
    let country: String
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    //let followers: [String: Codable?]
    let id: String
    let product: String
    let images: [APIImage]
}

