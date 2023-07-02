//
//  AllCategoriesResponse.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 08/06/23.
//

import Foundation

struct AllCategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let items: [Category]
}

struct Category: Codable {
    let icons: [APIImage]
    let id: String
    let name: String
}
