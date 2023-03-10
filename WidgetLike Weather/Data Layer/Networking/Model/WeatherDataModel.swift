//
//  WeatherDataModel.swift
//  WidgetLike Weather
//
//  Created by Artem on 28.02.2023.
//


import Foundation


struct WeatherDataModel: Codable {
    let cod: String?
    let message, cnt: Int?    // cnt - A number of days, which will be returned in the API response
    let list: [List]?
    let city: City?
}


struct City: Codable {
    let id: Int?
    let name: String?
    let coord: Coord?
    let country: String?
    let population, timezone, sunrise, sunset: Int?
}


struct Coord: Codable {
    let lat, lon: Double?
}


struct List: Codable {
    let dt: Int?
    let main: Main?
    let weather: [Weather]?
    let clouds: Clouds?
    let wind: Wind?
    let visibility: Int?
    let pop: Double?
    let snow: Snow?
    let sys: Sys?
    let dtTxt: String?

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, snow, sys
        case dtTxt = "dt_txt"
    }
}


struct Clouds: Codable {
    let all: Int?
}


struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double?
    let pressure, seaLevel, grndLevel, humidity: Int?
    let tempKf: Double?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}


struct Snow: Codable {
    let the3H: Double?

    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}


struct Sys: Codable {
    let pod: String?
}


struct Weather: Codable {
    let id: Int?
    let main, description, icon: String?
}


struct Wind: Codable {
    let speed: Double?
    let deg: Int?
    let gust: Double?
}

