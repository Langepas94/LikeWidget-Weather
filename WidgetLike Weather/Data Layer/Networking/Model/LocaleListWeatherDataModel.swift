//
//  LocaleListWeatherDataModel.swift
//  WidgetLike Weather
//
//  Created by Artem on 06.03.2023.
//

import Foundation

struct WelcomeElement: Codable {
    let id: Int?
    let name, state, country: String?
    let coord: Coords?
}

// MARK: - Coord
struct Coords: Codable {
    let lon, lat: Double?
}
