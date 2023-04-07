//
//  CellDataModel.swift
//  WidgetLike Weather
//
//  Created by Artem on 04.04.2023.
//

import Foundation
import UIKit

struct CellDataModel {
     
    
        let cityName: String?
        let degrees: String?
        let icon: String?
        let descriptionDegrees: String?
        let timeZone: Int?
    
    init(cityName: String? = nil, degrees: String? = nil, icon: String? = nil, descriptionDegrees: String? = nil, timeZone: Int? = nil) {
       self.cityName = cityName
       self.degrees = degrees
       self.icon = icon
       self.descriptionDegrees = descriptionDegrees
       self.timeZone = timeZone
   }
    
        init?(currentData: WeatherDataModel) {
            self.cityName = currentData.city?.name ?? ""
            self.degrees = String(currentData.list?[0].main?.temp ?? 0.0)
            self.descriptionDegrees = currentData.list?[0].weather?[0].description ?? ""

            self.icon = currentData.list?[0].weather?[0].icon
            self.timeZone = currentData.city?.timezone
        }
       
 
    }

