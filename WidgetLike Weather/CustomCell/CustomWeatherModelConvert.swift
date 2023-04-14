//
//  WeatherCellModel.swift
//  WidgetLike Weather
//
//  Created by Artem on 22.03.2023.
//

import Foundation
import UIKit

struct CustomWeatherModelConvert {
    let city: String
    let degrees: String
    let descriptionWeather: String
    let descrptionDegrees: String
    let icon: String?
    let timeZone: Int?
    
    init?(currentData: WeatherDataModel) {
        self.city = currentData.city?.name ?? ""
        self.degrees = String(currentData.list?[0].main?.temp ?? 0.0)
        self.descriptionWeather = currentData.list?[0].weather?[0].description ?? ""
        self.descrptionDegrees = String((currentData.list?[0].main?.tempMax ?? 0/0))
        self.icon = currentData.list?[0].weather?[0].icon
        self.timeZone = currentData.city?.timezone
    }
}
