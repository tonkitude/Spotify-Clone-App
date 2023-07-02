//
//  SettingsModels.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 20/05/23.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: ()->Void
}
