//
//  AuthResponse.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 18/05/23.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}


